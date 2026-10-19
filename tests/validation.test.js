const test = require("node:test");
const assert = require("node:assert/strict");
const {
  MAX_PAGE_SIZE,
  normalizeSearchTerm,
  parsePagination,
  parseTransactionStatus,
  validateTransferPayload
} = require("../lib/validation");

test("search terms trim and respect the configured maximum length", () => {
  assert.equal(normalizeSearchTerm("  Mahi  "), "Mahi");
  assert.equal(normalizeSearchTerm("abcdefgh", 4), "abcd");
  assert.equal(normalizeSearchTerm(null), "");
});

test("transaction status parsing distinguishes empty, allowed, and invalid values", () => {
  assert.deepEqual(parseTransactionStatus(""), { ok: true, value: "" });
  assert.deepEqual(parseTransactionStatus(" success "), { ok: true, value: "SUCCESS" });
  assert.equal(parseTransactionStatus("SUCCESS; DROP TABLE accounts").ok, false);
  assert.equal(parseTransactionStatus("unknown").ok, false);
});

test("pagination provides defaults and parameter-safe bounded values", () => {
  assert.deepEqual(parsePagination({}), { ok: true, limit: 100, offset: 0 });
  assert.deepEqual(parsePagination({ limit: "25", offset: "50" }), { ok: true, limit: 25, offset: 50 });
  assert.deepEqual(parsePagination({ limit: "900", offset: "0" }), { ok: true, limit: MAX_PAGE_SIZE, offset: 0 });
  assert.equal(parsePagination({ limit: "0" }).ok, false);
  assert.equal(parsePagination({ limit: "1.5" }).ok, false);
  assert.equal(parsePagination({ offset: "-1" }).ok, false);
  assert.equal(parsePagination({ offset: "100001" }).ok, false);
});

test("transfer validation accepts valid two-decimal amounts and serializes money safely", () => {
  assert.deepEqual(validateTransferPayload({ fromAccountId: 1, toAccountId: 2, amount: 25.5 }), {
    ok: true,
    value: { fromAccountId: 1, toAccountId: 2, amount: 25.5, amountSql: "25.50" }
  });
});

test("transfer validation rejects missing, unsafe, repeated, and fractional account IDs", () => {
  for (const payload of [
    {},
    { fromAccountId: 0, toAccountId: 2, amount: 1 },
    { fromAccountId: Number.MAX_SAFE_INTEGER + 1, toAccountId: 2, amount: 1 },
    { fromAccountId: 1.5, toAccountId: 2, amount: 1 },
    { fromAccountId: 3, toAccountId: 3, amount: 1 }
  ]) {
    assert.equal(validateTransferPayload(payload).ok, false, JSON.stringify(payload));
  }
});

test("transfer validation rejects invalid money precision, sign, and maximum", () => {
  for (const amount of [0, -1, 1.001, 1.234, Infinity, NaN, 1_000_000_000_001]) {
    assert.equal(validateTransferPayload({ fromAccountId: 1, toAccountId: 2, amount }).ok, false, String(amount));
  }
});
