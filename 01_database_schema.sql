-- Banking Financial Management schema bootstrap
-- Safe by default: creates the schema if needed and does not delete existing data.
-- For a clean demo reset, manually run:
-- DROP DATABASE IF EXISTS banking_financial_management;

CREATE DATABASE IF NOT EXISTS banking_financial_management
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE banking_financial_management;


-- Bootstrap verification
-- Verify that the expected schema is active before running dependent scripts.
SELECT DATABASE() AS active_schema, VERSION() AS mysql_version;
