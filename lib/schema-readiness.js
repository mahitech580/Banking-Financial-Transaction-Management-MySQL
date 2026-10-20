"use strict";

const REQUIRED_API_TABLES = Object.freeze([
  "branches", "customers", "accounts", "transactions", "transfers", "merchants",
  "cards", "loans", "loan_payments", "fraud_events", "disputes", "settlements"
]);

function findMissingApiTables(tableNames) {
  if (!Array.isArray(tableNames)) throw new TypeError("tableNames must be an array");
  const present = new Set(tableNames.filter((name) => typeof name === "string").map((name) => name.toLowerCase()));
  return REQUIRED_API_TABLES.filter((name) => !present.has(name));
}

module.exports = { REQUIRED_API_TABLES, findMissingApiTables };
