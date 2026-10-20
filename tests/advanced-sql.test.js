const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const directory = path.join(__dirname, "..", "advanced_sql");
const sqlFiles = fs.readdirSync(directory).filter((name) => name.endsWith(".sql")).sort();
const numberedFiles = sqlFiles.filter((name) => /^\d{3}_.+\.sql$/.test(name));
const supplementalFiles = sqlFiles.filter((name) => name.startsWith("supplemental_"));

test("numbered advanced SQL case studies have a unique, gap-free sequence", () => {
  assert.ok(numberedFiles.length >= 342, "expected the numbered case-study library");
  assert.equal(new Set(numberedFiles).size, numberedFiles.length, "numbered filenames must be unique");
  for (const [index, name] of numberedFiles.entries()) {
    assert.equal(Number(name.slice(0, 3)), index + 1, `unexpected sequence at ${name}`);
  }
});

test("all numbered and supplemental SQL files have distinct contents", () => {
  assert.equal(new Set(sqlFiles).size, sqlFiles.length, "SQL filenames must be unique");
  const sources = sqlFiles.map((name) => fs.readFileSync(path.join(directory, name), "utf8").trim());
  assert.equal(new Set(sources).size, sources.length, "SQL files must not duplicate one another");
});

test("every SQL example is a read-only SELECT or CTE with an introductory comment", () => {
  for (const name of sqlFiles) {
    const source = fs.readFileSync(path.join(directory, name), "utf8");
    assert.match(source.trimStart(), /^--\s+\S/m, `${name} needs an introductory comment`);
    assert.ok(source.trim().length > 80, `${name} looks incomplete`);
    const executable = source.replace(/^--.*$/gm, "").trimStart();
    assert.match(executable, /^(WITH\b|SELECT\b)/i, `${name} must begin with SELECT or CTE`);
    assert.doesNotMatch(source, /^\s*(DROP|TRUNCATE|DELETE|INSERT|UPDATE|REPLACE|ALTER)\b/im,
      `${name} must remain read-only`);
  }
});

test("branch balance report pre-aggregates accounts to avoid join fan-out", () => {
  const source = fs.readFileSync(path.join(directory, "027_branch_customer_account_summary.sql"), "utf8");
  assert.doesNotMatch(source, /SUM\s*\(\s*DISTINCT\s+a\.current_balance\s*\)/i);
  assert.ok(source.includes("SELECT branch_id, COUNT(*) AS customer_count"));
  assert.ok(source.includes("FROM customers"));
  assert.ok(source.includes("GROUP BY branch_id"));
  assert.ok(source.includes("COUNT(*) AS account_count"));
  assert.ok(source.includes("SUM(current_balance) AS total_balance"));
  assert.ok(source.includes("FROM accounts"));
});

test("supplemental reports are explicitly prefixed and do not occupy numbered slots", () => {
  assert.ok(supplementalFiles.length >= 24, "expected the retained overlapping reports");
  assert.equal(numberedFiles.length + supplementalFiles.length, sqlFiles.length,
    "every SQL file must be numbered or explicitly supplemental");
  for (const name of supplementalFiles) {
    assert.match(name, /^supplemental_[a-z0-9_]+\.sql$/);
  }
});
