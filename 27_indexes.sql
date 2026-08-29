USE banking_financial_management;
CREATE INDEX idx_transactions_account_time ON transactions(account_id,transaction_time);
CREATE INDEX idx_transactions_status_time ON transactions(status,transaction_time);
CREATE INDEX idx_customers_risk ON customers(risk_level);
CREATE INDEX idx_loans_customer_status ON loans(customer_id,status);
