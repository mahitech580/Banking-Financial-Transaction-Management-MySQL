"use strict";

const { URL } = require("node:url");

const DEFAULT_DATABASE_NAME = "banking_financial_management";

/**
 * Resolve the schema name used by the active connection configuration.
 * MYSQL_URL is authoritative when it contains a database path, matching makePool().
 */
function resolveDatabaseName(mysqlUrl, mysqlDatabase) {
  if (typeof mysqlUrl === "string" && mysqlUrl.trim()) {
    const parsed = new URL(mysqlUrl);
    const urlDatabase = decodeURIComponent(parsed.pathname.replace(/^\/+/, ""));
    if (urlDatabase) return urlDatabase;
  }

  const configuredDatabase = typeof mysqlDatabase === "string" ? mysqlDatabase.trim() : "";
  return configuredDatabase || DEFAULT_DATABASE_NAME;
}

module.exports = { DEFAULT_DATABASE_NAME, resolveDatabaseName };
