"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const { decimalToMinorUnits, hasSufficientFunds } = require("../lib/money");

test("converts decimal strings into integer minor units", () => {
  assert.equal(decimalToMinorUnits("125.50"), 12550n);
  assert.equal(decimalToMinorUnits("8"), 800n);
  assert.equal(decimalToMinorUnits("0.09"), 9n);
  assert.equal(decimalToMinorUnits("-2.34"), -234n);
});

test("rejects malformed money values rather than coercing them", () => {
  for (const value of ["", "1.234", "1e3", "0x10", "NaN", "Infinity", "1.", ".5", null, true, []]) {
    assert.equal(decimalToMinorUnits(value), null, String(value));
  }
});

test("checks available funds at cent precision", () => {
  assert.equal(hasSufficientFunds("100.00", "99.99"), true);
  assert.equal(hasSufficientFunds("100.00", "100.00"), true);
  assert.equal(hasSufficientFunds("100.00", "100.01"), false);
  assert.equal(hasSufficientFunds("0.10", "0.11"), false);
});

test("preserves cent differences above JavaScript's safe integer precision", () => {
  assert.equal(hasSufficientFunds("90071992547409.91", "90071992547409.92"), false);
  assert.equal(hasSufficientFunds("90071992547409.92", "90071992547409.92"), true);
});

test("malformed or negative values fail the funds check closed", () => {
  assert.equal(hasSufficientFunds("unknown", "10.00"), false);
  assert.equal(hasSufficientFunds("-1.00", "0.01"), false);
  assert.equal(hasSufficientFunds("10.00", "invalid"), false);
});
