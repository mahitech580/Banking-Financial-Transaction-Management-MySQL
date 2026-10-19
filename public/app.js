(() => {
  "use strict";

  const $ = (selector) => document.querySelector(selector);
  const cache = { accounts: [], customers: [], transactions: [], branches: [], cards: [], loans: [], repayments: [], settlements: [], disputes: [], fraud: [], analytics: null };
  let activePage = "overview";
  let searchTimer;
  let transfersAvailable = false;

  const currency = (value) => {
    const n = Number(value || 0);
    return new Intl.NumberFormat("en-IN", { style: "currency", currency: "INR", maximumFractionDigits: 2 }).format(Number.isFinite(n) ? n : 0);
  };
  const number = (value) => new Intl.NumberFormat("en-IN").format(Number(value || 0));
  const safe = (value) => String(value ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const dateTime = (value) => {
    if (!value) return "—";
    const d = new Date(String(value).replace(" ", "T") + (String(value).includes("Z") ? "" : ""));
    return Number.isNaN(d.getTime()) ? safe(value) : d.toLocaleString("en-IN", { day: "2-digit", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit" });
  };
  const dateOnly = (value) => {
    if (!value) return "—";
    const d = new Date(String(value).slice(0, 10) + "T00:00:00");
    return Number.isNaN(d.getTime()) ? safe(value) : d.toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });
  };
  const badge = (value) => {
    const label = String(value || "UNKNOWN").toUpperCase();
    const cls = label.toLowerCase().replace(/[^a-z0-9-]/g, "-");
    return '<span class="status-badge status-' + safe(cls) + '">' + safe(label) + "</span>";
  };
  const initials = (name) => String(name || "?").trim().split(/\s+/).slice(0, 2).map((s) => s[0] || "").join("").toUpperCase();

  async function api(url, options = {}) {
    const response = await fetch(url, {
      ...options,
      headers: { ...(options.body ? { "Content-Type": "application/json" } : {}), ...(options.headers || {}) }
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) {
      const error = new Error(payload.error || payload.message || `Request failed (${response.status})`);
      error.status = response.status;
      throw error;
    }
    return payload;
  }

  function notice(message, tone = "warning") {
    const el = $("#global-notice");
    if (!message) {
      el.hidden = true;
      el.textContent = "";
      el.className = "notice";
      return;
    }
    el.hidden = false;
    el.className = tone === "info" ? "notice notice-info" : "notice";
    el.textContent = message;
  }

  function setTableMessage(id, cols, message, error = false) {
    const el = document.getElementById(id);
    if (el) el.innerHTML = '<tr><td colspan="' + cols + '" class="' + (error ? "table-loading" : "table-loading") + '">' + safe(message) + "</td></tr>";
  }

  function setDbStatus(connected, label, databaseName) {
    const el = $("#connection-status");
    el.classList.toggle("connected", connected);
    el.classList.toggle("disconnected", !connected);
    el.innerHTML = '<span class="status-dot"></span><span>' + safe(label) + "</span>";
    $("#mysql-health").textContent = connected ? "Connected" : "Offline";
    $("#mysql-health").classList.toggle("healthy", connected);
    $("#health-database").textContent = connected ? (databaseName || "MySQL schema available") : "Database unavailable";
  }

  function updateTransferAvailability(enabled) {
    transfersAvailable = Boolean(enabled);
    const button = $("#transfer-submit");
    const message = $("#transfer-message");
    if (button) button.disabled = !enabled;
    if (!enabled && message && message.hidden) {
      message.hidden = false;
      message.className = "form-message error";
      message.textContent = "Transfers are disabled until MySQL is connected and ENABLE_DEMO_TRANSFERS=true is set for a synthetic-data demo.";
    } else if (enabled && message && message.textContent.startsWith("Transfers are disabled until")) {
      message.hidden = true;
      message.textContent = "";
    }
  }

  async function checkHealth() {
    try {
      const health = await api("/api/health");
      const connected = Boolean(health.ok && health.database === "connected");
      updateTransferAvailability(connected && health.transfersEnabled === true);
      setDbStatus(connected, connected ? "MySQL connected" : "Database offline", health.databaseName);
      if (!connected) notice(health.message || "Database connection is unavailable. Set the MYSQL_* environment variables and confirm that the schema has been created.");
      else notice("");
      return health;
    } catch (error) {
      setDbStatus(false, "Database offline");
      updateTransferAvailability(false);
      notice(error.message + " Check the server configuration.");
      return { ok: false };
    }
  }

  function signAmount(type, amount) {
    const n = Number(amount || 0);
    return ["CREDIT"].includes(String(type).toUpperCase()) ? "+" + currency(n) : (["DEBIT", "ATM", "FEE"].includes(String(type).toUpperCase()) ? "−" : "") + currency(n);
  }

  function renderRecent(rows) {
    const body = $("#recent-rows");
    if (!rows.length) return setTableMessage("recent-rows", 5, "No transactions found in this database yet.");
    body.innerHTML = rows.map((t) => `<tr>
      <td><div class="table-main">${safe(t.reference_code)}</div><div class="table-sub">${safe(t.transaction_type)} · ${safe(t.channel)}</div></td>
      <td><div class="table-main">${safe(t.account_number)}</div><div class="table-sub">${safe(t.customer_name)}</div></td>
      <td>${dateTime(t.transaction_time)}</td>
      <td class="${String(t.transaction_type).toUpperCase() === "CREDIT" ? "amount-positive" : "amount-negative"}">${signAmount(t.transaction_type, t.amount)}</td>
      <td>${badge(t.status)}</td>
    </tr>`).join("");
  }

  async function loadOverview() {
    try {
      const data = await api("/api/overview");
      const m = data.metrics;
      $("#metric-balance").textContent = currency(m.totalBalance);
      $("#metric-customers").textContent = number(m.customers);
      $("#metric-transactions").textContent = number(m.transactions);
      $("#metric-success").textContent = number(m.successfulTransactions) + " successful";
      $("#metric-active-accounts").textContent = number(m.activeAccounts);
      $("#metric-loans").textContent = number(m.activeLoans) + " active loans";
      renderRecent(data.recentTransactions || []);
      renderBreakdown($("#overview-channels"), (await api("/api/analytics")).channels || [], "channel");
    } catch (error) {
      notice(error.message, "warning");
      ["recent-rows"].forEach((id) => setTableMessage(id, 5, "Unable to load transactions. " + error.message, true));
      ["metric-balance", "metric-customers", "metric-transactions", "metric-success", "metric-active-accounts", "metric-loans"].forEach((id) => { $("#" + id).textContent = "—"; });
      $("#overview-channels").innerHTML = '<p class="empty-state">Connect the MySQL database to load channel data.</p>';
    }
  }

  async function loadAccounts() {
    try {
      const q = $("#accounts-search")?.value.trim() || "";
      const result = await api("/api/accounts?q=" + encodeURIComponent(q));
      cache.accounts = result.data || [];
      $("#accounts-count").textContent = number(cache.accounts.length) + " accounts";
      const body = $("#accounts-rows");
      body.innerHTML = cache.accounts.length ? cache.accounts.map((a) => `<tr>
        <td><div class="table-main">${safe(a.account_number)}</div><div class="table-sub">ID #${safe(a.account_id)}</div></td>
        <td><div class="table-main">${safe(a.customer_name)}</div><div class="table-sub">${safe(a.customer_number)}</div></td>
        <td>${safe(a.account_type)}</td><td>${safe(a.branch_name || "—")}<div class="table-sub">${safe(a.branch_city || "")}</div></td>
        <td class="amount-positive">${currency(a.current_balance)}</td><td>${badge(a.status)}</td><td>${dateOnly(a.opened_at)}</td>
      </tr>`).join("") : '<tr><td colspan="7" class="table-loading">No accounts match this search.</td></tr>';
      updateTransferAccounts(cache.accounts);
    } catch (error) {
      $("#accounts-count").textContent = "Unavailable";
      setTableMessage("accounts-rows", 7, error.message, true);
      throw error;
    }
  }

  async function loadCustomers() {
    try {
      const q = $("#customers-search")?.value.trim() || "";
      const result = await api("/api/customers?q=" + encodeURIComponent(q));
      cache.customers = result.data || [];
      $("#customers-count").textContent = number(cache.customers.length) + " customers";
      const body = $("#customers-rows");
      body.innerHTML = cache.customers.length ? cache.customers.map((c) => `<tr>
        <td><div class="table-main">${safe(c.customer_name)}</div><div class="table-sub">${safe(c.phone || "No phone on file")}</div></td>
        <td>${safe(c.customer_number)}</td><td>${safe(c.email)}</td>
        <td>${number(c.account_count)}</td><td>${number(c.loan_count)}</td><td>${badge(c.risk_level)}</td><td>${dateOnly(c.customer_since)}</td>
      </tr>`).join("") : '<tr><td colspan="7" class="table-loading">No customers match this search.</td></tr>';
    } catch (error) {
      $("#customers-count").textContent = "Unavailable";
      setTableMessage("customers-rows", 7, error.message, true);
      throw error;
    }
  }

  async function loadTransactions() {
    try {
      const q = $("#transactions-search")?.value.trim() || "";
      const status = $("#transactions-status")?.value || "";
      const query = new URLSearchParams({ q, status });
      const result = await api("/api/transactions?" + query.toString());
      cache.transactions = result.data || [];
      $("#transactions-count").textContent = number(cache.transactions.length) + " transactions";
      const body = $("#transactions-rows");
      body.innerHTML = cache.transactions.length ? cache.transactions.map((t) => `<tr>
        <td><div class="table-main">${safe(t.reference_code)}</div><div class="table-sub">#${safe(t.transaction_id)}</div></td>
        <td><div class="table-main">${safe(t.customer_name)}</div><div class="table-sub">${safe(t.account_number)}</div></td>
        <td>${safe(t.transaction_type)}</td><td>${safe(t.channel)}</td><td>${dateTime(t.transaction_time)}</td>
        <td class="${String(t.transaction_type).toUpperCase() === "CREDIT" ? "amount-positive" : "amount-negative"}">${signAmount(t.transaction_type, t.amount)}</td><td>${badge(t.status)}</td>
      </tr>`).join("") : '<tr><td colspan="7" class="table-loading">No transactions match these filters.</td></tr>';
    } catch (error) {
      $("#transactions-count").textContent = "Unavailable";
      setTableMessage("transactions-rows", 7, error.message, true);
      throw error;
    }
  }

  function renderBreakdown(el, rows, labelKey) {
    if (!rows || !rows.length) {
      el.innerHTML = '<p class="empty-state">No records to display yet.</p>';
      return;
    }
    const max = Math.max(1, ...rows.map((r) => Number(r.count || 0)));
    el.innerHTML = rows.map((r) => `<div class="channel-row">
      <div class="channel-top"><span>${safe(r[labelKey] || "Other")}</span><strong>${number(r.count)} <span style="font-weight:400;color:#9ca69f">· ${currency(r.value || 0)}</span></strong></div>
      <div class="progress-track"><div class="progress-fill" style="width:${Math.max(2, Number(r.count || 0) / max * 100)}%"></div></div>
    </div>`).join("");
  }

  function renderDaily(rows) {
    const el = $("#daily-chart");
    if (!rows || !rows.length) {
      el.innerHTML = '<p class="empty-state">No transaction activity in the selected date range.</p>';
      return;
    }
    const max = Math.max(1, ...rows.map((r) => Number(r.value || 0)));
    el.innerHTML = rows.map((r) => {
      const d = new Date(String(r.day).slice(0, 10) + "T00:00:00");
      const label = Number.isNaN(d.getTime()) ? "" : d.toLocaleDateString("en-IN", { day: "2-digit", month: "short" });
      const height = Math.max(2, Number(r.value || 0) / max * 100);
      return `<div class="bar-item" title="${safe(label)}: ${safe(currency(r.value))}">
        <span class="bar-value">${number(r.count)}</span><div class="bar" style="height:${height}%"></div><span class="bar-label">${safe(label)}</span>
      </div>`;
    }).join("");
  }

  async function loadAnalytics() {
    try {
      const data = await api("/api/analytics");
      cache.analytics = data;
      renderDaily(data.daily || []);
      renderBreakdown($("#analytics-channels"), data.channels || [], "channel");
      renderBreakdown($("#analytics-types"), data.types || [], "transaction_type");
      const rows = data.topCustomers || [];
      $("#top-customers").innerHTML = rows.length ? rows.map((r, i) => `<tr><td>${i + 1}</td><td>${safe(r.customer_name)}</td><td>${number(r.transaction_count)}</td><td class="amount-positive">${currency(r.gross_value)}</td></tr>`).join("") : '<tr><td colspan="4" class="table-loading">No customer activity available.</td></tr>';
    } catch (error) {
      ["daily-chart", "analytics-channels", "analytics-types"].forEach((id) => { $("#" + id).innerHTML = '<p class="empty-state">' + safe(error.message) + "</p>"; });
      setTableMessage("top-customers", 4, error.message, true);
      throw error;
    }
  }

  async function loadLoans() {
    try {
      const result = await api("/api/loans");
      cache.loans = result.data || [];
      $("#loans-rows").innerHTML = cache.loans.length ? cache.loans.map((l) => `<tr>
        <td><div class="table-main">LN-${safe(l.loan_id)}</div><div class="table-sub">${safe(l.account_number)}</div></td>
        <td>${safe(l.customer_name)}</td><td>${safe(l.loan_type)}</td><td>${currency(l.principal)}</td>
        <td>${safe(l.interest_rate)}%</td><td><div class="table-main">${currency(l.total_paid)}</div><div class="table-sub">of ${currency(l.total_due)} recorded due</div></td><td>${badge(l.status)}</td>
      </tr>`).join("") : '<tr><td colspan="7" class="table-loading">No loan records found. Add sample loan data to explore this module.</td></tr>';
    } catch (error) {
      setTableMessage("loans-rows", 7, error.message, true);
      throw error;
    }
  }


  async function loadBranches() {
    try {
      const result = await api("/api/branches");
      const rows = result.data || [];
      $("#branches-rows").innerHTML = rows.length ? rows.map((b) => `<tr>
        <td><div class="table-main">${safe(b.branch_name)}</div><div class="table-sub">ID #${safe(b.branch_id)}</div></td>
        <td>${safe(b.branch_code)}</td><td>${safe(b.city)}, ${safe(b.state)}</td>
        <td>${number(b.customer_count)}</td><td>${number(b.account_count)}</td><td class="amount-positive">${currency(b.total_balance)}</td>
      </tr>`).join("") : '<tr><td colspan="6" class="table-loading">No branches found.</td></tr>';
    } catch (error) { setTableMessage("branches-rows", 6, error.message, true); throw error; }
  }

  async function loadCards() {
    try {
      const result = await api("/api/cards");
      cache.cards = result.data || [];
      $("#cards-rows").innerHTML = cache.cards.length ? cache.cards.map((cd) => `<tr>
        <td><div class="table-main">•••• ${safe(String(cd.card_number || "").slice(-4))}</div><div class="table-sub">Card #${safe(cd.card_id)}</div></td>
        <td><div class="table-main">${safe(cd.customer_name)}</div><div class="table-sub">${safe(cd.customer_number)}</div></td>
        <td>${safe(cd.account_number)}</td><td>${safe(cd.card_type)}</td><td>${currency(cd.credit_limit)}</td>
        <td>${dateOnly(cd.issued_at)}</td><td>${badge(cd.status)}</td>
      </tr>`).join("") : '<tr><td colspan="7" class="table-loading">No card records found. Run 29_demo_operations_data.sql for sample cards.</td></tr>';
    } catch (error) { setTableMessage("cards-rows", 7, error.message, true); throw error; }
  }

  async function loadRepayments() {
    try {
      const result = await api("/api/repayments");
      cache.repayments = result.data || [];
      $("#repayments-rows").innerHTML = cache.repayments.length ? cache.repayments.map((p) => `<tr>
        <td><div class="table-main">PMT-${safe(p.payment_id)}</div><div class="table-sub">Loan #${safe(p.loan_id)}</div></td>
        <td><div class="table-main">${safe(p.customer_name)}</div><div class="table-sub">${safe(p.loan_type)}</div></td>
        <td>${dateOnly(p.due_date)}</td><td>${dateOnly(p.paid_date)}</td><td>${currency(p.amount_due)}</td>
        <td class="amount-positive">${currency(p.amount_paid)}</td><td>${badge(p.status)}</td>
      </tr>`).join("") : '<tr><td colspan="7" class="table-loading">No repayments found. Run 29_demo_operations_data.sql for sample payments.</td></tr>';
    } catch (error) { setTableMessage("repayments-rows", 7, error.message, true); throw error; }
  }

  async function loadSettlements() {
    try {
      const result = await api("/api/settlements");
      cache.settlements = result.data || [];
      $("#settlements-rows").innerHTML = cache.settlements.length ? cache.settlements.map((item) => `<tr>
        <td><div class="table-main">STL-${safe(item.settlement_id)}</div></td><td>${safe(item.reference_code)}</td>
        <td><div class="table-main">${safe(item.customer_name)}</div><div class="table-sub">${safe(item.account_number)}</div></td>
        <td>${dateTime(item.transaction_time)}</td><td>${dateTime(item.settled_at)}</td><td>${currency(item.settlement_amount)}</td><td>${badge(item.status)}</td>
      </tr>`).join("") : '<tr><td colspan="7" class="table-loading">No settlement records found. Run 29_demo_operations_data.sql for samples.</td></tr>';
    } catch (error) { setTableMessage("settlements-rows", 7, error.message, true); throw error; }
  }

  async function loadDisputes() {
    try {
      const result = await api("/api/disputes");
      cache.disputes = result.data || [];
      $("#disputes-rows").innerHTML = cache.disputes.length ? cache.disputes.map((item) => `<tr>
        <td>${dateTime(item.opened_at)}</td><td><div class="table-main">${safe(item.reference_code)}</div></td>
        <td><div class="table-main">${safe(item.customer_name)}</div><div class="table-sub">${safe(item.account_number)}</div></td>
        <td>${safe(item.reason)}</td><td>${currency(item.disputed_amount)}</td><td>${badge(item.status)}</td>
      </tr>`).join("") : '<tr><td colspan="6" class="table-loading">No dispute records found. Run 29_demo_operations_data.sql for samples.</td></tr>';
    } catch (error) { setTableMessage("disputes-rows", 6, error.message, true); throw error; }
  }

  async function loadFraud() {
    try {
      const result = await api("/api/fraud-events");
      cache.fraud = result.data || [];
      $("#fraud-rows").innerHTML = cache.fraud.length ? cache.fraud.map((f) => `<tr>
        <td>${dateTime(f.detected_at)}</td><td><div class="table-main">${safe(f.reference_code)}</div></td><td>${safe(f.customer_name)}<div class="table-sub">${safe(f.account_number)}</div></td>
        <td>${safe(f.fraud_type)}</td><td>${currency(f.amount)}</td><td>${safe(f.risk_score)} / 100</td><td>${badge(f.action_taken)}</td>
      </tr>`).join("") : '<tr><td colspan="7" class="table-loading">No fraud events are recorded in the current database.</td></tr>';
    } catch (error) {
      setTableMessage("fraud-rows", 7, error.message, true);
      throw error;
    }
  }

  function updateTransferAccounts(accounts) {
    const from = $("#transfer-from");
    const to = $("#transfer-to");
    if (!from || !to) return;
    const active = (accounts || []).filter((a) => a.status === "ACTIVE");
    const selectedFrom = from.value;
    const selectedTo = to.value;
    from.innerHTML = '<option value="">Select source account</option>' + active.map((a) => `<option value="${safe(a.account_id)}">${safe(a.account_number)} · ${safe(a.customer_name)} · ${safe(currency(a.current_balance))}</option>`).join("");
    to.innerHTML = '<option value="">Select destination account</option>' + active.map((a) => `<option value="${safe(a.account_id)}">${safe(a.account_number)} · ${safe(a.customer_name)}</option>`).join("");
    if (active.some((a) => String(a.account_id) === selectedFrom)) from.value = selectedFrom;
    if (active.some((a) => String(a.account_id) === selectedTo)) to.value = selectedTo;
    excludeSameAccount();
  }

  function excludeSameAccount() {
    const from = $("#transfer-from");
    const to = $("#transfer-to");
    if (!from || !to) return;
    const previous = to.value;
    [...to.options].forEach((option) => {
      option.disabled = Boolean(option.value && option.value === from.value);
    });
    if (to.value === from.value) to.value = "";
    if (previous && previous !== from.value) to.value = previous;
  }

  async function loadTransferAccounts() {
    try {
      const result = await api("/api/accounts");
      cache.accounts = result.data || [];
      updateTransferAccounts(cache.accounts);
    } catch (error) {
      $("#transfer-from").innerHTML = '<option value="">Database unavailable</option>';
      $("#transfer-to").innerHTML = '<option value="">Database unavailable</option>';
      const msg = $("#transfer-message");
      msg.hidden = false;
      msg.className = "form-message error";
      msg.textContent = error.message;
    }
  }

  async function loadPage(page) {
    try {
      if (page === "overview") await loadOverview();
      if (page === "accounts") await loadAccounts();
      if (page === "customers") await loadCustomers();
      if (page === "transactions") await loadTransactions();
      if (page === "analytics") await loadAnalytics();
      if (page === "branches") await loadBranches();
      if (page === "cards") await loadCards();
      if (page === "loans") await loadLoans();
      if (page === "repayments") await loadRepayments();
      if (page === "settlements") await loadSettlements();
      if (page === "disputes") await loadDisputes();
      if (page === "fraud") await loadFraud();
      if (page === "transfer") await loadTransferAccounts();
    } catch (error) {
      notice(error.message);
    }
  }

  function navigate(page) {
    const target = document.getElementById("page-" + page);
    if (!target) return;
    activePage = page;
    document.querySelectorAll(".page").forEach((el) => el.classList.toggle("active", el === target));
    document.querySelectorAll(".nav-item").forEach((el) => {
      const current = el.dataset.page === page;
      el.classList.toggle("active", current);
      if (current) el.setAttribute("aria-current", "page");
      else el.removeAttribute("aria-current");
    });
    const title = target.querySelector("h1")?.textContent.trim() || "Overview";
    $("#breadcrumb-current").textContent = title.replace(" ✳", "");
    $("#sidebar").classList.remove("open");
    $("#mobile-menu").setAttribute("aria-expanded", "false");
    loadPage(page);
  }

  function exportRows(filename, headers, rows) {
    if (!rows || !rows.length) {
      notice("There are no rows to export yet.", "info");
      return;
    }
    const csvCell = (v) => { const raw = String(v ?? ""); const guarded = /^[\t\r\n ]*[=+\-@]/.test(raw) ? "'" + raw : raw; return '"' + guarded.replace(/"/g, '""') + '"'; };
    const content = [headers, ...rows].map((row) => row.map(csvCell).join(",")).join("\r\n");
    const blob = new Blob(["\ufeff" + content], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
  }

  function bindExport(id, filename, headers, mapper) {
    const el = $("#" + id);
    if (el) el.addEventListener("click", () => exportRows(filename, headers, (cache[mapper] || []).map((item) => mapper === "accounts" ? [
      item.account_number, item.customer_name, item.customer_number, item.account_type, item.branch_name, item.current_balance, item.status, item.opened_at
    ] : mapper === "customers" ? [
      item.customer_number, item.customer_name, item.email, item.phone, item.account_count, item.loan_count, item.risk_level, item.customer_since
    ] : [
      item.reference_code, item.customer_name, item.account_number, item.transaction_type, item.channel, item.transaction_time, item.amount, item.status
    ])));
  }

  async function submitTransfer(event) {
    event.preventDefault();
    const button = $("#transfer-submit");
    const message = $("#transfer-message");
    const fromAccountId = Number($("#transfer-from").value);
    const toAccountId = Number($("#transfer-to").value);
    const amount = Number($("#transfer-amount").value);
    message.hidden = true;
    message.textContent = "";
    if (!fromAccountId || !toAccountId || !amount || amount <= 0) {
      message.hidden = false;
      message.className = "form-message error";
      message.textContent = "Select both accounts and enter a valid amount.";
      return;
    }
    if (fromAccountId === toAccountId) {
      message.hidden = false;
      message.className = "form-message error";
      message.textContent = "Source and destination accounts must be different.";
      return;
    }
    button.disabled = true;
    button.textContent = "Processing transfer…";
    try {
      const result = await api("/api/transfers", {
        method: "POST",
        body: JSON.stringify({ fromAccountId, toAccountId, amount: Number(amount.toFixed(2)) })
      });
      message.hidden = false;
      message.className = "form-message success";
      message.textContent = result.message + " Reference: " + result.reference + " · Amount: " + currency(result.amount);
      $("#transfer-amount").value = "";
      await checkHealth();
      await loadTransferAccounts();
      await loadOverview();
    } catch (error) {
      if (error.status === 403 || error.status === 503) updateTransferAvailability(false);
      message.hidden = false;
      message.className = "form-message error";
      message.textContent = error.message;
    } finally {
      button.disabled = !transfersAvailable;
      button.innerHTML = 'Review & transfer <span>→</span>';
    }
  }

  document.addEventListener("click", (event) => {
    const button = event.target.closest("[data-page]");
    if (button) navigate(button.dataset.page);
    const link = event.target.closest("[data-page-link]");
    if (link) {
      event.preventDefault();
      navigate(link.dataset.pageLink);
    }
  });
  $("#mobile-menu").addEventListener("click", () => {
    const sidebar = $("#sidebar");
    const expanded = !sidebar.classList.contains("open");
    sidebar.classList.toggle("open", expanded);
    $("#mobile-menu").setAttribute("aria-expanded", String(expanded));
  });
  $("#refresh-button").addEventListener("click", async () => {
    await checkHealth();
    await loadPage(activePage);
  });
  $("#transfer-form").addEventListener("submit", submitTransfer);
  $("#transfer-from").addEventListener("change", excludeSameAccount);

  [["accounts-search", loadAccounts], ["customers-search", loadCustomers], ["transactions-search", loadTransactions]].forEach(([id, handler]) => {
    const input = $("#" + id);
    input.addEventListener("input", () => {
      clearTimeout(searchTimer);
      searchTimer = setTimeout(() => handler().catch((error) => notice(error.message)), 220);
    });
  });
  $("#transactions-status").addEventListener("change", () => loadTransactions().catch((error) => notice(error.message)));
  bindExport("accounts-export", "banking-accounts.csv", ["Account number", "Customer", "Customer number", "Type", "Branch", "Balance", "Status", "Opened"], "accounts");
  bindExport("customers-export", "banking-customers.csv", ["Customer number", "Name", "Email", "Phone", "Accounts", "Loans", "Risk level", "Joined"], "customers");
  bindExport("transactions-export", "banking-transactions.csv", ["Reference", "Customer", "Account", "Type", "Channel", "Date/time", "Amount", "Status"], "transactions");

  (async function init() {
    await checkHealth();
    await loadOverview();
  })();
})();
