"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const { REQUIRED_API_TABLES, findMissingApiTables } = require("../lib/schema-readiness");

test("a complete set of API tables is ready", () => {
  assert.deepEqual(findMissingApiTables(REQUIRED_API_TABLES), []);
});

test("each missing required table is reported", () => {
  for (const missing of REQUIRED_API_TABLES) {
    const present = REQUIRED_API_TABLES.filter((name) => name !== missing);
    assert.deepEqual(findMissingApiTables(present), [missing], missing);
  }
});

test("partial schemas return all missing API tables in stable order", () => {
  const present = ["customers", "transactions"];
  assert.deepEqual(
    findMissingApiTables(present),
    REQUIRED_API_TABLES.filter((name) => !present.includes(name))
  );
});

test("table names compare case-insensitively and unrelated tables do not block readiness", () => {
  assert.deepEqual(
    findMissingApiTables([...REQUIRED_API_TABLES.map((name) => name.toUpperCase()), "audit_log", null, 12]),
    []
  );
});

test("schema readiness rejects non-array input", () => {
  assert.throws(() => findMissingApiTables(null), TypeError);
});
