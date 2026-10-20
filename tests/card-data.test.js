"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const { maskCardNumber } = require("../lib/card-data");

test("masks all but the final four digits of a card number", () => {
  assert.equal(maskCardNumber("4111 1111 1111 1234"), "•••• 1234");
  assert.equal(maskCardNumber("4111-1111-1111-9876"), "•••• 9876");
});

test("never returns the complete card number for short or unformatted values", () => {
  assert.equal(maskCardNumber("123"), "•••• 123");
  assert.equal(maskCardNumber("card-without-digits"), "••••");
});

test("handles missing and empty card values safely", () => {
  assert.equal(maskCardNumber(null), "");
  assert.equal(maskCardNumber(undefined), "");
  assert.equal(maskCardNumber("   "), "");
});

test("masking output does not contain the original card number", () => {
  const raw = "4111111111114321";
  const masked = maskCardNumber(raw);
  assert.equal(masked.includes(raw), false);
  assert.equal(masked.endsWith("4321"), true);
});
