"use strict";

const REQUIRED_CORE_TABLES = Object.freeze(["branches", "customers", "accounts", "transactions"]);

function findMissingCoreTables(tableNames) {
  if (!Array.isArray(tableNames)) throw new TypeError("tableNames must be an array");
  const present = new Set(tableNames.map((name) => String(name ?? "").toLowerCase()));
  return REQUIRED_CORE_TABLES.filter((name) => !present.has(name));
}

module.exports = { REQUIRED_CORE_TABLES, findMissingCoreTables };
