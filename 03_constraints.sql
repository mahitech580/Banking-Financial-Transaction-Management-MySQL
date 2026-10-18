-- Additional named constraints. Core keys and most value checks are declared in 02_tables.sql.
USE banking_financial_management;

-- MySQL 8.0.16+ enforces CHECK constraints.
ALTER TABLE accounts
  ADD CONSTRAINT chk_accounts_nonnegative_balance CHECK (current_balance >= 0);

-- Loan, installment, transaction and fraud score checks are defined alongside their tables.
-- Cross-row rules such as sufficient funds must be enforced transactionally, not with CHECK.
