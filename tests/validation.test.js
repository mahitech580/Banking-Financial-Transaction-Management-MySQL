"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  MAX_PAGE_SIZE,
  MAX_TRANSFER_AMOUNT,
  normalizeSearchTerm,
  parsePagination,
  parseTransactionStatus,
  validateTransferPayload
} = require("../lib/validation");

test("search term normalization trims whitespace and enforces the requested cap", () => {
  assert.equal(normalizeSearchTerm("  account  "), "account");
  assert.equal(normalizeSearchTerm("abcdefgh", 5), "abcde");
  assert.equal(normalizeSearchTerm(null), "");
  assert.throws(() => normalizeSearchTerm("a", 0), RangeError);
});

test("transaction status accepts supported values case-insensitively", () => {
  assert.deepEqual(parseTransactionStatus(undefined), { ok: true, value: "" });
  assert.deepEqual(parseTransactionStatus(" success "), { ok: true, value: "SUCCESS" });
  assert.deepEqual(parseTransactionStatus("REVERSED"), { ok: true, value: "REVERSED" });
});

test("transaction status rejects unsupported filters instead of broadening the query", () => {
  for (const status of ["DONE", "SUCCESS,FAILED", "SUCCESS' OR 1=1 --", "UNKNOWN"]) {
    assert.equal(parseTransactionStatus(status).ok, false, status);
  }
});

test("pagination applies defaults and caps excessively large limits", () => {
  assert.deepEqual(parsePagination({}), { ok: true, limit: 100, offset: 0 });
  assert.deepEqual(parsePagination({ limit: "999999", offset: "25" }), {
    ok: true, limit: MAX_PAGE_SIZE, offset: 25
  });
  assert.deepEqual(parsePagination({ limit: "1", offset: "0" }), {
    ok: true, limit: 1, offset: 0
  });
});

test("pagination rejects fractional, non-finite and out-of-range values", () => {
  for (const limit of ["0", "-1", "1.5", "Infinity", "NaN"]) {
    assert.equal(parsePagination({ limit }).ok, false, "limit=" + limit);
  }
  for (const offset of ["-1", "1.5", "Infinity", "100001"]) {
    assert.equal(parsePagination({ offset }).ok, false, "offset=" + offset);
  }
});

test("transfer validation returns normalized identifiers and fixed-precision amounts", () => {
  const result = validateTransferPayload({ fromAccountId: "3", toAccountId: 4, amount: "125.50" });
  assert.equal(result.ok, true);
  assert.deepEqual(result.value, {
    fromAccountId: 3,
    toAccountId: 4,
    amount: 125.5,
    amountSql: "125.50"
  });
});

test("transfer validation rejects invalid identifiers, self-transfer and invalid money values", () => {
  const invalid = [
    { fromAccountId: 0, toAccountId: 2, amount: 1 },
    { fromAccountId: 1.2, toAccountId: 2, amount: 1 },
    { fromAccountId: 1, toAccountId: 1, amount: 1 },
    { fromAccountId: 1, toAccountId: 2, amount: 0 },
    { fromAccountId: 1, toAccountId: 2, amount: -1 },
    { fromAccountId: 1, toAccountId: 2, amount: 1.234 },
    { fromAccountId: 1, toAccountId: 2, amount: MAX_TRANSFER_AMOUNT + 0.01 },
    { fromAccountId: 1, toAccountId: 2, amount: "not-money" }
  ];
  for (const payload of invalid) {
    assert.equal(validateTransferPayload(payload).ok, false, JSON.stringify(payload));
  }
});
