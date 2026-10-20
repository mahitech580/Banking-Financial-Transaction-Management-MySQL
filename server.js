require("dotenv").config();

const crypto = require("node:crypto");
const express = require("express");
const helmet = require("helmet");
const mysql = require("mysql2/promise");
const path = require("node:path");
const { normalizeSearchTerm, parsePagination, parseTransactionStatus, validateTransferPayload } = require("./lib/validation");
const { maskCardNumber } = require("./lib/card-data");
const { hasSufficientFunds } = require("./lib/money");

const app = express();
const PORT = Number(process.env.PORT || 10000);
const DATABASE_NAME = process.env.MYSQL_DATABASE || (process.env.MYSQL_URL ? decodeURIComponent(new URL(process.env.MYSQL_URL).pathname.replace(/^\//, "")) : "") || "banking_financial_management";
const transfersEnabled = String(process.env.ENABLE_DEMO_TRANSFERS).toLowerCase() === "true";

app.disable("x-powered-by");
app.use(helmet({
  crossOriginResourcePolicy: { policy: "same-site" },
  contentSecurityPolicy: {
    directives: {
      styleSrc: ["'self'", "'unsafe-inline'"],
      fontSrc: ["'self'", "data:"],
      scriptSrc: ["'self'"],
      connectSrc: ["'self'"]
    }
  }
}));
// Apply no-store before parsing so even malformed/oversized API requests are not cached.
app.use("/api", (_req, res, next) => {
  res.set("Cache-Control", "no-store");
  next();
});
app.use(express.json({ limit: "20kb", strict: true }));
app.use(express.static(path.join(__dirname, "public"), { extensions: ["html"] }));
app.get("/docs/API.md", (_req, res) => {
  res.type("text/markdown").sendFile(path.join(__dirname, "docs", "API.md"));
});

function makePool() {
  let options;
  if (process.env.MYSQL_URL) {
    const url = new URL(process.env.MYSQL_URL);
    options = {
      host: url.hostname,
      port: Number(url.port || 3306),
      user: decodeURIComponent(url.username),
      password: decodeURIComponent(url.password),
      database: decodeURIComponent(url.pathname.replace(/^\//, "")) || DATABASE_NAME
    };
  } else if (process.env.MYSQL_HOST && process.env.MYSQL_USER && process.env.MYSQL_DATABASE) {
    options = {
      host: process.env.MYSQL_HOST,
      port: Number(process.env.MYSQL_PORT || 3306),
      user: process.env.MYSQL_USER,
      password: process.env.MYSQL_PASSWORD || "",
      database: process.env.MYSQL_DATABASE
    };
  } else {
    return null;
  }

  if (String(process.env.MYSQL_SSL).toLowerCase() === "true") {
    options.ssl = { rejectUnauthorized: true };
  }
  return mysql.createPool({
    ...options,
    waitForConnections: true,
    connectionLimit: Number(process.env.MYSQL_CONNECTION_LIMIT || 10),
    queueLimit: 0,
    decimalNumbers: false,
    timezone: "Z",
    enableKeepAlive: true
  });
}

const pool = makePool();

function asyncRoute(handler) {
  return (req, res, next) => Promise.resolve(handler(req, res, next)).catch(next);
}

function requireDatabase(req, res, next) {
  if (!pool) {
    return res.status(503).json({
      error: "MySQL is not configured.",
      detail: "Set MYSQL_URL or MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD and MYSQL_DATABASE, then restart the server."
    });
  }
  next();
}

app.get("/healthz", (_req, res) => res.status(200).json({ ok: true, service: "running" }));

app.get("/api/health", asyncRoute(async (_req, res) => {
  if (!pool) {
    return res.status(503).json({ ok: false, database: "not_configured", transfersEnabled, message: "Configure the MYSQL_* environment variables." });
  }
  try {
    await pool.query("SELECT 1");
    const [tables] = await pool.query(
      "SELECT COUNT(*) AS table_count FROM information_schema.tables WHERE table_schema = ?",
      [DATABASE_NAME]
    );
    res.json({ ok: true, database: "connected", databaseName: DATABASE_NAME, tableCount: Number(tables[0].table_count), transfersEnabled });
  } catch (error) {
    console.error("[database-health]", error.code || error.name || "Error");
    res.status(503).json({ ok: false, database: "unreachable", transfersEnabled, message: "MySQL connection failed. Check the database host, credentials, TLS settings and schema." });
  }
}));

app.get("/api/overview", requireDatabase, asyncRoute(async (_req, res) => {
  const [[customerRows], [accountRows], [transactionRows], [loanRows], [fraudRows], [recent]] = await Promise.all([
    pool.query("SELECT COUNT(*) AS total FROM customers"),
    pool.query("SELECT COUNT(*) AS total, COALESCE(SUM(current_balance), 0) AS total_balance, SUM(status = 'ACTIVE') AS active FROM accounts"),
    pool.query("SELECT COUNT(*) AS total, COALESCE(SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END), 0) AS successful_value, SUM(status = 'SUCCESS') AS successful FROM transactions"),
    pool.query("SELECT COUNT(*) AS total FROM loans WHERE status = 'ACTIVE'"),
    pool.query("SELECT COUNT(*) AS total FROM fraud_events WHERE action_taken IN ('REVIEW','BLOCK')"),
    pool.query(`SELECT t.transaction_id, t.reference_code, t.transaction_type, t.amount, t.transaction_time, t.status, t.channel,
      a.account_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name
      FROM transactions t JOIN accounts a ON a.account_id = t.account_id
      JOIN customers c ON c.customer_id = a.customer_id
      ORDER BY t.transaction_time DESC, t.transaction_id DESC LIMIT 8`)
  ]);
  res.json({
    metrics: {
      customers: Number(customerRows[0].total),
      accounts: Number(accountRows[0].total),
      activeAccounts: Number(accountRows[0].active || 0),
      totalBalance: String(accountRows[0].total_balance || "0.00"),
      transactions: Number(transactionRows[0].total),
      successfulTransactions: Number(transactionRows[0].successful || 0),
      successfulValue: String(transactionRows[0].successful_value || "0.00"),
      activeLoans: Number(loanRows[0].total),
      flaggedFraudEvents: Number(fraudRows[0].total)
    },
    recentTransactions: recent
  });
}));

app.get("/api/customers", requireDatabase, asyncRoute(async (req, res) => {
  const page = parsePagination(req.query, { defaultLimit: 250, maxLimit: 250 });
  if (!page.ok) return res.status(400).json({ error: page.error });
  const q = normalizeSearchTerm(req.query.q);
  const like = `%${q}%`;
  const [rows] = await pool.query(`
    SELECT c.customer_id, c.customer_number, c.first_name, c.last_name,
      CONCAT(c.first_name, ' ', c.last_name) AS customer_name, c.email, c.phone,
      c.risk_level, c.customer_since, COUNT(DISTINCT a.account_id) AS account_count,
      COUNT(DISTINCT l.loan_id) AS loan_count
    FROM customers c
    LEFT JOIN accounts a ON a.customer_id = c.customer_id
    LEFT JOIN loans l ON l.customer_id = c.customer_id
    WHERE (? = '' OR c.customer_number LIKE ? OR c.first_name LIKE ? OR c.last_name LIKE ? OR c.email LIKE ?)
    GROUP BY c.customer_id, c.customer_number, c.first_name, c.last_name, c.email, c.phone, c.risk_level, c.customer_since
    ORDER BY c.customer_id DESC LIMIT ? OFFSET ?
  `, [q, like, like, like, like, page.limit + 1, page.offset]);
  const hasMore = rows.length > page.limit;
  const data = hasMore ? rows.slice(0, page.limit) : rows;
  res.json({ data, pagination: { limit: page.limit, offset: page.offset, returned: data.length, hasMore, nextOffset: hasMore ? page.offset + data.length : null } });
}));

app.get("/api/accounts", requireDatabase, asyncRoute(async (req, res) => {
  const page = parsePagination(req.query, { defaultLimit: 250, maxLimit: 250 });
  if (!page.ok) return res.status(400).json({ error: page.error });
  const q = normalizeSearchTerm(req.query.q);
  const like = `%${q}%`;
  const [rows] = await pool.query(`
    SELECT a.account_id, a.account_number, a.account_type, a.status, a.current_balance, a.opened_at,
      c.customer_id, c.customer_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
      b.branch_name, b.city AS branch_city
    FROM accounts a JOIN customers c ON c.customer_id = a.customer_id
    LEFT JOIN branches b ON b.branch_id = a.branch_id
    WHERE (? = '' OR a.account_number LIKE ? OR c.customer_number LIKE ? OR c.first_name LIKE ? OR c.last_name LIKE ?)
    ORDER BY a.account_id DESC LIMIT ? OFFSET ?
  `, [q, like, like, like, like, page.limit + 1, page.offset]);
  const hasMore = rows.length > page.limit;
  const data = hasMore ? rows.slice(0, page.limit) : rows;
  res.json({ data, pagination: { limit: page.limit, offset: page.offset, returned: data.length, hasMore, nextOffset: hasMore ? page.offset + data.length : null } });
}));

app.get("/api/transactions", requireDatabase, asyncRoute(async (req, res) => {
  const page = parsePagination(req.query, { defaultLimit: 300, maxLimit: 300 });
  if (!page.ok) return res.status(400).json({ error: page.error });
  const q = normalizeSearchTerm(req.query.q);
  const statusResult = parseTransactionStatus(req.query.status);
  if (!statusResult.ok) return res.status(400).json({ error: statusResult.error });
  const statusFilter = statusResult.value;
  const like = `%${q}%`;
  const [rows] = await pool.query(`
    SELECT t.transaction_id, t.reference_code, t.transaction_type, t.amount, t.transaction_time,
      t.channel, t.status, a.account_number,
      CONCAT(c.first_name, ' ', c.last_name) AS customer_name, m.merchant_name
    FROM transactions t JOIN accounts a ON a.account_id = t.account_id
    JOIN customers c ON c.customer_id = a.customer_id
    LEFT JOIN merchants m ON m.merchant_id = t.merchant_id
    WHERE (? = '' OR t.reference_code LIKE ? OR a.account_number LIKE ? OR c.first_name LIKE ? OR c.last_name LIKE ?)
      AND (? = '' OR t.status = ?)
    ORDER BY t.transaction_time DESC, t.transaction_id DESC LIMIT ? OFFSET ?
  `, [q, like, like, like, like, statusFilter, statusFilter, page.limit + 1, page.offset]);
  const hasMore = rows.length > page.limit;
  const data = hasMore ? rows.slice(0, page.limit) : rows;
  res.json({ data, pagination: { limit: page.limit, offset: page.offset, returned: data.length, hasMore, nextOffset: hasMore ? page.offset + data.length : null } });
}));

app.get("/api/analytics", requireDatabase, asyncRoute(async (_req, res) => {
  const [[daily], [channels], [types], [topCustomers]] = await Promise.all([
    pool.query(`SELECT DATE(transaction_time) AS day, COUNT(*) AS count,
      SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS value
      FROM transactions WHERE transaction_time >= DATE_SUB(CURRENT_DATE, INTERVAL 13 DAY)
      GROUP BY DATE(transaction_time) ORDER BY day`),
    pool.query(`SELECT channel, COUNT(*) AS count,
      SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS value
      FROM transactions GROUP BY channel ORDER BY count DESC`),
    pool.query(`SELECT transaction_type, COUNT(*) AS count,
      SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS value
      FROM transactions GROUP BY transaction_type ORDER BY count DESC`),
    pool.query(`SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
      COUNT(t.transaction_id) AS transaction_count, SUM(t.amount) AS gross_value
      FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
      JOIN transactions t ON t.account_id = a.account_id AND t.status = 'SUCCESS'
      GROUP BY c.customer_id, c.first_name, c.last_name
      ORDER BY gross_value DESC LIMIT 5`)
  ]);
  res.json({ daily, channels, types, topCustomers });
}));

app.get("/api/loans", requireDatabase, asyncRoute(async (_req, res) => {
  const [rows] = await pool.query(`
    SELECT l.loan_id, l.loan_type, l.principal, l.interest_rate, l.tenure_months, l.start_date, l.status,
      CONCAT(c.first_name, ' ', c.last_name) AS customer_name, a.account_number,
      COUNT(lp.payment_id) AS installment_count, COALESCE(SUM(lp.amount_due), 0) AS total_due,
      COALESCE(SUM(lp.amount_paid), 0) AS total_paid
    FROM loans l JOIN customers c ON c.customer_id = l.customer_id
    JOIN accounts a ON a.account_id = l.account_id
    LEFT JOIN loan_payments lp ON lp.loan_id = l.loan_id
    GROUP BY l.loan_id, l.loan_type, l.principal, l.interest_rate, l.tenure_months, l.start_date, l.status,
      c.first_name, c.last_name, a.account_number
    ORDER BY l.loan_id DESC LIMIT 250
  `);
  res.json({ data: rows });
}));

app.get("/api/fraud-events", requireDatabase, asyncRoute(async (_req, res) => {
  const [rows] = await pool.query(`
    SELECT f.fraud_event_id, f.detected_at, f.fraud_type, f.risk_score, f.action_taken,
      t.reference_code, t.amount, t.channel, a.account_number,
      CONCAT(c.first_name, ' ', c.last_name) AS customer_name
    FROM fraud_events f JOIN transactions t ON t.transaction_id = f.transaction_id
    JOIN accounts a ON a.account_id = t.account_id
    JOIN customers c ON c.customer_id = a.customer_id
    ORDER BY f.detected_at DESC LIMIT 250
  `);
  res.json({ data: rows });
}));


app.get("/api/branches", requireDatabase, asyncRoute(async (_req, res) => {
  const [rows] = await pool.query(`
    SELECT b.branch_id, b.branch_code, b.branch_name, b.city, b.state,
      COALESCE(c.customer_count, 0) AS customer_count,
      COALESCE(a.account_count, 0) AS account_count,
      COALESCE(a.total_balance, 0) AS total_balance
    FROM branches b
    LEFT JOIN (SELECT branch_id, COUNT(*) AS customer_count FROM customers GROUP BY branch_id) c
      ON c.branch_id = b.branch_id
    LEFT JOIN (SELECT branch_id, COUNT(*) AS account_count, SUM(current_balance) AS total_balance
      FROM accounts GROUP BY branch_id) a ON a.branch_id = b.branch_id
    ORDER BY b.city, b.branch_name
  `);
  res.json({ data: rows });
}));

app.get("/api/cards", requireDatabase, asyncRoute(async (_req, res) => {
  const [rows] = await pool.query(`
    SELECT cd.card_id, cd.card_number, cd.card_type, cd.issued_at, cd.credit_limit, cd.status,
      CONCAT(c.first_name, ' ', c.last_name) AS customer_name, c.customer_number, a.account_number
    FROM cards cd JOIN customers c ON c.customer_id = cd.customer_id
    JOIN accounts a ON a.account_id = cd.account_id
    ORDER BY cd.card_id DESC LIMIT 250
  `);
  res.json({ data: rows.map((row) => ({ ...row, card_number: maskCardNumber(row.card_number) })) });
}));

app.get("/api/repayments", requireDatabase, asyncRoute(async (_req, res) => {
  const [rows] = await pool.query(`
    SELECT lp.payment_id, lp.due_date, lp.paid_date, lp.amount_due, lp.amount_paid, lp.status,
      l.loan_id, l.loan_type, CONCAT(c.first_name, ' ', c.last_name) AS customer_name
    FROM loan_payments lp JOIN loans l ON l.loan_id = lp.loan_id
    JOIN customers c ON c.customer_id = l.customer_id
    ORDER BY lp.due_date DESC, lp.payment_id DESC LIMIT 300
  `);
  res.json({ data: rows });
}));

app.get("/api/disputes", requireDatabase, asyncRoute(async (_req, res) => {
  const [rows] = await pool.query(`
    SELECT d.dispute_id, d.opened_at, d.reason, d.disputed_amount, d.status,
      t.reference_code, a.account_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name
    FROM disputes d JOIN transactions t ON t.transaction_id = d.transaction_id
    JOIN accounts a ON a.account_id = t.account_id
    JOIN customers c ON c.customer_id = a.customer_id
    ORDER BY d.opened_at DESC LIMIT 250
  `);
  res.json({ data: rows });
}));

app.get("/api/settlements", requireDatabase, asyncRoute(async (_req, res) => {
  const [rows] = await pool.query(`
    SELECT s.settlement_id, s.settled_at, s.settlement_amount, s.status,
      t.reference_code, t.transaction_time, a.account_number,
      CONCAT(c.first_name, ' ', c.last_name) AS customer_name
    FROM settlements s JOIN transactions t ON t.transaction_id = s.transaction_id
    JOIN accounts a ON a.account_id = t.account_id
    JOIN customers c ON c.customer_id = a.customer_id
    ORDER BY s.settlement_id DESC LIMIT 250
  `);
  res.json({ data: rows });
}));

app.post("/api/transfers", requireDatabase, asyncRoute(async (req, res) => {
  if (!transfersEnabled) return res.status(403).json({ error: "Transfers are disabled on this instance. Set ENABLE_DEMO_TRANSFERS=true only for a test database containing synthetic data." });
  const validation = validateTransferPayload(req.body);
  if (!validation.ok) return res.status(400).json({ error: validation.error });
  const { fromAccountId: fromId, toAccountId: toId, amount, amountSql } = validation.value;

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const [accounts] = await connection.query(
      "SELECT account_id, account_number, status, current_balance FROM accounts WHERE account_id IN (?, ?) ORDER BY account_id FOR UPDATE",
      [fromId, toId]
    );
    const from = accounts.find((a) => Number(a.account_id) === fromId);
    const to = accounts.find((a) => Number(a.account_id) === toId);
    if (!from || !to) {
      await connection.rollback();
      return res.status(404).json({ error: "One or both accounts were not found." });
    }
    if (from.status !== "ACTIVE" || to.status !== "ACTIVE") {
      await connection.rollback();
      return res.status(409).json({ error: "Transfers require both accounts to be ACTIVE." });
    }
    if (!hasSufficientFunds(from.current_balance, amountSql)) {
      await connection.rollback();
      return res.status(409).json({ error: "Insufficient available balance." });
    }

    const outgoingRef = `TRF-${crypto.randomBytes(8).toString("hex").toUpperCase()}`;
    const incomingRef = `TRF-${crypto.randomBytes(8).toString("hex").toUpperCase()}`;
    const [outgoing] = await connection.query(
      "INSERT INTO transactions (account_id, transaction_type, amount, transaction_time, reference_code, channel, status) VALUES (?, 'DEBIT', ?, NOW(), ?, 'ONLINE', 'SUCCESS')",
      [fromId, amountSql, outgoingRef]
    );
    await connection.query(
      "INSERT INTO transactions (account_id, transaction_type, amount, transaction_time, reference_code, channel, status) VALUES (?, 'CREDIT', ?, NOW(), ?, 'ONLINE', 'SUCCESS')",
      [toId, amountSql, incomingRef]
    );
    const [debitUpdate] = await connection.query(
      "UPDATE accounts SET current_balance = current_balance - ? WHERE account_id = ? AND current_balance >= ?",
      [amountSql, fromId, amountSql]
    );
    if (debitUpdate.affectedRows !== 1) throw new Error("Debit validation failed while processing transfer.");
    const [creditUpdate] = await connection.query(
      "UPDATE accounts SET current_balance = current_balance + ? WHERE account_id = ?",
      [amountSql, toId]
    );
    if (creditUpdate.affectedRows !== 1) throw new Error("Credit validation failed while processing transfer.");
    const [transfer] = await connection.query(
      "INSERT INTO transfers (transaction_id, from_account_id, to_account_id, transfer_amount, initiated_at, status) VALUES (?, ?, ?, ?, NOW(), 'COMPLETED')",
      [outgoing.insertId, fromId, toId, amountSql]
    );
    await connection.commit();
    res.status(201).json({
      message: "Transfer completed successfully.",
      transferId: transfer.insertId,
      amount: amountSql,
      fromAccount: from.account_number,
      toAccount: to.account_number,
      reference: outgoingRef
    });
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}));

app.get("/api", (_req, res) => {
  res.json({
    name: "Ledgerly Banking API",
    version: "1.0.0",
    documentation: "/docs/API.md",
    health: "/api/health",
    endpoints: [
      { method: "GET", path: "/api/overview", description: "Dashboard summary and recent transactions" },
      { method: "GET", path: "/api/customers", description: "Search customers with the q query parameter" },
      { method: "GET", path: "/api/accounts", description: "Search accounts with the q query parameter" },
      { method: "GET", path: "/api/transactions", description: "Search transactions with q and status query parameters" },
      { method: "GET", path: "/api/analytics", description: "Financial activity aggregates" },
      { method: "GET", path: "/api/branches", description: "Branch summaries" },
      { method: "GET", path: "/api/cards", description: "Card registry" },
      { method: "GET", path: "/api/loans", description: "Loan summaries" },
      { method: "GET", path: "/api/repayments", description: "Scheduled and recorded loan payments" },
      { method: "GET", path: "/api/settlements", description: "Settlement records" },
      { method: "GET", path: "/api/disputes", description: "Transaction disputes" },
      { method: "GET", path: "/api/fraud-events", description: "Recorded fraud events" },
      { method: "POST", path: "/api/transfers", description: "Demo transfer; disabled unless ENABLE_DEMO_TRANSFERS=true" }
    ]
  });
});

app.use("/api", (_req, res) => res.status(404).json({ error: "API endpoint not found." }));

app.use((error, _req, res, _next) => {
  if (res.headersSent) return;
  // Body-parser errors are client input errors, not internal server failures.
  if (error.type === "entity.parse.failed" || error instanceof SyntaxError && error.status === 400 && Object.prototype.hasOwnProperty.call(error, "body")) {
    return res.status(400).json({ error: "Request body must contain valid JSON." });
  }
  if (error.type === "entity.too.large") {
    return res.status(413).json({ error: "Request body exceeds the 20 KB limit." });
  }
  console.error("[api-error]", error.code || error.name || "Error");
  if (error.code === "ER_NO_SUCH_TABLE" || error.code === "ER_BAD_DB_ERROR") {
    return res.status(503).json({ error: "The MySQL schema is missing. Run the project's numbered SQL setup scripts first." });
  }
  if (error.code === "ER_ACCESS_DENIED_ERROR" || error.code === "ECONNREFUSED" || error.code === "ENOTFOUND" || error.code === "ETIMEDOUT") {
    return res.status(503).json({ error: "Cannot reach MySQL. Check database host, credentials, network access and TLS settings." });
  }
  res.status(500).json({ error: "The request could not be completed. Check the server log for details." });
});

const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`Banking dashboard listening on 0.0.0.0:${PORT}; MySQL configured: ${Boolean(pool)}`);
});

async function closePool() {
  if (pool) await pool.end();
}

let shuttingDown = false;
function shutdown(signal) {
  if (shuttingDown) return;
  shuttingDown = true;
  console.log("[shutdown] Received", signal);

  const timeout = setTimeout(() => {
    console.error("[shutdown] Graceful shutdown timed out");
    process.exit(1);
  }, 10_000);
  timeout.unref();

  server.close((serverError) => {
    closePool().then(() => {
      clearTimeout(timeout);
      if (serverError) {
        console.error("[shutdown] HTTP server close failed");
        process.exitCode = 1;
      } else {
        process.exitCode = 0;
      }
    }).catch((error) => {
      clearTimeout(timeout);
      console.error("[shutdown] Database pool close failed", error.code || error.name || "Error");
      process.exitCode = 1;
    });
  });
}

process.once("SIGTERM", () => shutdown("SIGTERM"));
process.once("SIGINT", () => shutdown("SIGINT"));
