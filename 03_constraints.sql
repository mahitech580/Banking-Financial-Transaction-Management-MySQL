-- Additional named constraints. Core keys and most value checks are declared in 02_tables.sql.
USE banking_financial_management;

-- MySQL 8.0.16+ enforces CHECK constraints.
ALTER TABLE accounts
  ADD CONSTRAINT chk_accounts_nonnegative_balance CHECK (current_balance >= 0);

-- Loan, installment, transaction and fraud score checks are defined alongside their tables.
-- Cross-row rules such as sufficient funds must be enforced transactionally, not with CHECK.


-- Balance integrity audit
-- Any returned row violates the non-negative balance rule.
SELECT account_id, account_number, current_balance
FROM accounts
WHERE current_balance < 0;


-- Repayment consistency audit
-- A clean dataset should return zero inconsistent repayment records.
SELECT payment_id, loan_id, amount_due, amount_paid, status
FROM loan_payments
WHERE amount_due <= 0 OR amount_paid < 0 OR amount_paid > amount_due;
