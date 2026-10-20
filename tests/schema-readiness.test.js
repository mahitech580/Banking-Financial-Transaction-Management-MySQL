"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const { REQUIRED_CORE_TABLES, findMissingCoreTables } = require("../lib/schema-readiness");

test("the complete core banking schema is ready", () => {
  assert.deepEqual(findMissingCoreTables(REQUIRED_CORE_TABLES), []);
});

test("missing core tables are returned in stable, actionable order", () => {
  assert.deepEqual(findMissingCoreTables(["customers", "transactions"]), ["branches", "accounts"]);
});

test("optional operations tables do not block core schema readiness", () => {
  assert.deepEqual(findMissingCoreTables([...REQUIRED_CORE_TABLES, "cards", "loans"]), []);
});

test("schema readiness rejects a non-array table list", () => {
  assert.throws(() => findMissingCoreTables(null), TypeError);
});
