-- Business question: Which customers have multiple independent review signals across activity, disputes, fraud events, and lending?
-- Grain: one row per customer. These synthetic-data indicators are for human review, not a customer risk decision.
WITH transaction_summary AS (
  SELECT a.customer_id, COUNT(t.transaction_id) AS attempt_count,
    SUM(t.status = 'SUCCESS') AS success_count,
    COALESCE(SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END), 0.00) AS successful_value
  FROM accounts a
  LEFT JOIN transactions t ON t.account_id = a.account_id
  GROUP BY a.customer_id
),
fraud_summary AS (
  SELECT a.customer_id, COUNT(DISTINCT f.fraud_event_id) AS fraud_event_count,
    SUM(f.action_taken = 'BLOCK') AS block_count,
    SUM(f.action_taken = 'REVIEW') AS review_count
  FROM accounts a
  JOIN transactions t ON t.account_id = a.account_id
  JOIN fraud_events f ON f.transaction_id = t.transaction_id
  GROUP BY a.customer_id
),
dispute_summary AS (
  SELECT a.customer_id, COUNT(DISTINCT d.dispute_id) AS dispute_count,
    COALESCE(SUM(CASE WHEN d.status = 'OPEN' THEN d.disputed_amount ELSE 0 END), 0.00) AS open_dispute_amount
  FROM accounts a
  JOIN transactions t ON t.account_id = a.account_id
  JOIN disputes d ON d.transaction_id = t.transaction_id
  GROUP BY a.customer_id
),
loan_summary AS (
  SELECT customer_id, COUNT(*) AS loan_count,
    COALESCE(SUM(CASE WHEN status = 'ACTIVE' THEN principal ELSE 0 END), 0.00) AS active_loan_principal
  FROM loans
  GROUP BY customer_id
)
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.risk_level, COALESCE(ts.attempt_count, 0) AS attempt_count,
  COALESCE(ts.success_count, 0) AS success_count, COALESCE(fs.fraud_event_count, 0) AS fraud_event_count,
  COALESCE(fs.block_count, 0) AS block_count, COALESCE(fs.review_count, 0) AS review_count,
  COALESCE(ds.dispute_count, 0) AS dispute_count, COALESCE(ds.open_dispute_amount, 0.00) AS open_dispute_amount,
  COALESCE(ls.loan_count, 0) AS loan_count, COALESCE(ls.active_loan_principal, 0.00) AS active_loan_principal,
  (COALESCE(fs.fraud_event_count, 0) > 0) + (COALESCE(ds.dispute_count, 0) > 0)
    + (COALESCE(ls.loan_count, 0) > 0) AS distinct_signal_families
FROM customers c
LEFT JOIN transaction_summary ts ON ts.customer_id = c.customer_id
LEFT JOIN fraud_summary fs ON fs.customer_id = c.customer_id
LEFT JOIN dispute_summary ds ON ds.customer_id = c.customer_id
LEFT JOIN loan_summary ls ON ls.customer_id = c.customer_id
WHERE COALESCE(fs.fraud_event_count, 0) > 0
   OR COALESCE(ds.dispute_count, 0) > 0
   OR COALESCE(c.risk_level, 'LOW') = 'HIGH'
ORDER BY distinct_signal_families DESC, fraud_event_count DESC, dispute_count DESC, c.customer_id;
