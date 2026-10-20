-- Business question: Which customers have disputes relative to their recorded transaction-attempt volume?
-- Grain: one row per customer with at least one dispute; a high ratio is a triage signal and not proof of abuse.
WITH attempts AS (
  SELECT a.customer_id, COUNT(t.transaction_id) AS attempt_count,
    SUM(t.status = 'SUCCESS') AS success_count
  FROM accounts a
  LEFT JOIN transactions t ON t.account_id = a.account_id
  GROUP BY a.customer_id
),
customer_disputes AS (
  SELECT a.customer_id, COUNT(DISTINCT d.dispute_id) AS dispute_count,
    SUM(d.status = 'OPEN') AS open_dispute_count,
    COALESCE(SUM(CASE WHEN d.status = 'OPEN' THEN d.disputed_amount ELSE 0 END), 0.00) AS open_dispute_amount
  FROM accounts a
  JOIN transactions t ON t.account_id = a.account_id
  JOIN disputes d ON d.transaction_id = t.transaction_id
  GROUP BY a.customer_id
)
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.risk_level, COALESCE(a.attempt_count, 0) AS attempt_count,
  COALESCE(a.success_count, 0) AS successful_count, d.dispute_count,
  d.open_dispute_count, d.open_dispute_amount,
  ROUND(100.0 * d.dispute_count / NULLIF(a.attempt_count, 0), 2) AS disputes_per_100_attempts,
  CASE WHEN d.dispute_count >= 3 AND d.dispute_count / NULLIF(a.attempt_count, 0) >= 0.10
    THEN 'HIGHER_REVIEW_PRIORITY'
    WHEN d.dispute_count >= 2 THEN 'REVIEW_PATTERN'
    ELSE 'LOWER_VOLUME' END AS triage_band
FROM customers c
JOIN customer_disputes d ON d.customer_id = c.customer_id
LEFT JOIN attempts a ON a.customer_id = c.customer_id
ORDER BY disputes_per_100_attempts DESC, d.dispute_count DESC, c.customer_id;
