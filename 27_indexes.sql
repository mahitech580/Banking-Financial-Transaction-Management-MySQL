-- Supporting indexes for common filters, joins, date ranges and investigation queues.
-- Execute this file once after schema/data setup. Inspect existing indexes before rerunning.
USE banking_financial_management;

CREATE INDEX idx_accounts_customer_status
  ON accounts (customer_id, status);

CREATE INDEX idx_transactions_account_time
  ON transactions (account_id, transaction_time DESC);

CREATE INDEX idx_transactions_status_time
  ON transactions (status, transaction_time DESC);

CREATE INDEX idx_transactions_type_status_time
  ON transactions (transaction_type, status, transaction_time);

CREATE INDEX idx_card_transactions_card_time
  ON card_transactions (card_id, transaction_time DESC);

CREATE INDEX idx_card_transactions_merchant_time
  ON card_transactions (merchant_id, transaction_time DESC);

CREATE INDEX idx_loans_customer_status
  ON loans (customer_id, status);

CREATE INDEX idx_loan_payments_due_status
  ON loan_payments (due_date, status);

CREATE INDEX idx_fraud_events_action_score
  ON fraud_events (action_taken, risk_score DESC);

CREATE INDEX idx_settlements_status_time
  ON settlements (status, settled_at);

CREATE INDEX idx_audit_log_entity_time
  ON audit_log (entity_name, entity_id, action_at DESC);


-- Review created indexes and uniqueness flags after installation.
SHOW INDEX FROM transactions;


-- Check whether the account/time index supports an account history lookup.
EXPLAIN SELECT transaction_id,reference_code,amount,transaction_time FROM transactions WHERE account_id=1 ORDER BY transaction_time DESC LIMIT 20;
