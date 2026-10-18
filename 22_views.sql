-- Reusable read models for reporting. CREATE OR REPLACE makes view definitions repeatable.
USE banking_financial_management;

CREATE OR REPLACE VIEW v_customer_account_summary AS
SELECT c.customer_id, c.customer_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.risk_level, COUNT(a.account_id) AS account_count,
       COALESCE(SUM(a.current_balance), 0) AS total_balance
FROM customers AS c
LEFT JOIN accounts AS a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_number, c.first_name, c.last_name, c.risk_level;

CREATE OR REPLACE VIEW v_transaction_daily_summary AS
SELECT DATE(transaction_time) AS transaction_date,
       COUNT(*) AS total_attempts,
       SUM(status = 'SUCCESS') AS successful_count,
       SUM(status = 'FAILED') AS failed_count,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
FROM transactions
GROUP BY DATE(transaction_time);

CREATE OR REPLACE VIEW v_loan_repayment_summary AS
SELECT l.loan_id, l.customer_id, l.loan_type, l.principal, l.status AS loan_status,
       COUNT(lp.payment_id) AS installment_count,
       COALESCE(SUM(lp.amount_due), 0) AS scheduled_amount,
       COALESCE(SUM(lp.amount_paid), 0) AS collected_amount,
       COALESCE(SUM(lp.amount_due - lp.amount_paid), 0) AS outstanding_scheduled_amount,
       COALESCE(SUM(lp.status IN ('LATE','MISSED')), 0) AS late_or_missed_count
FROM loans AS l
LEFT JOIN loan_payments AS lp ON lp.loan_id = l.loan_id
GROUP BY l.loan_id, l.customer_id, l.loan_type, l.principal, l.status;

CREATE OR REPLACE VIEW v_fraud_review_queue AS
SELECT f.fraud_event_id, f.detected_at, f.fraud_type, f.risk_score, f.action_taken,
       t.reference_code, t.amount, t.channel, t.status AS transaction_status,
       a.account_number, c.customer_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM fraud_events AS f
JOIN transactions AS t ON t.transaction_id = f.transaction_id
JOIN accounts AS a ON a.account_id = t.account_id
JOIN customers AS c ON c.customer_id = a.customer_id
WHERE f.action_taken IN ('REVIEW','BLOCK');

CREATE OR REPLACE VIEW v_pending_settlement_queue AS
SELECT s.settlement_id, s.transaction_id, t.reference_code, t.transaction_time,
       s.settlement_amount, s.status
FROM settlements AS s
JOIN transactions AS t ON t.transaction_id = s.transaction_id
WHERE s.status = 'PENDING';


-- Review customers with the largest combined account balance
SELECT customer_number,customer_name,account_count,total_balance,risk_level FROM v_customer_account_summary ORDER BY total_balance DESC LIMIT 20;


-- Inspect daily ledger volume and successful value from the reusable view
SELECT transaction_date,total_attempts,successful_count,failed_count,successful_value FROM v_transaction_daily_summary ORDER BY transaction_date DESC LIMIT 30;


-- Reuse views to review unresolved work without duplicating joins
SELECT * FROM v_fraud_review_queue ORDER BY risk_score DESC,detected_at DESC;
SELECT * FROM v_pending_settlement_queue ORDER BY transaction_time;
