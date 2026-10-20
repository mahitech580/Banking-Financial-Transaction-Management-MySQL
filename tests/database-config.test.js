"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const { DEFAULT_DATABASE_NAME, resolveDatabaseName } = require("../lib/database-config");

test("database name matches MYSQL_URL when URL and MYSQL_DATABASE disagree", () => {
  assert.equal(
    resolveDatabaseName("mysql://demo:secret@db.example.test:3306/url_database", "environment_database"),
    "url_database"
  );
});

test("database names in URL paths are decoded", () => {
  assert.equal(resolveDatabaseName("mysql://demo:secret@db.example.test:3306/banking%5Fdemo"), "banking_demo");
});

test("MYSQL_DATABASE is the fallback when MYSQL_URL has no database path", () => {
  assert.equal(resolveDatabaseName("mysql://demo:secret@db.example.test:3306/", "environment_database"), "environment_database");
});

test("the documented database name is used when neither source is configured", () => {
  assert.equal(resolveDatabaseName("", ""), DEFAULT_DATABASE_NAME);
});

test("malformed configured URLs fail explicitly instead of silently checking the wrong schema", () => {
  assert.throws(() => resolveDatabaseName("not a URL", "environment_database"), TypeError);
});
