-- Business question: Which accounts have an unusually high share of unsuccessful transaction attempts?
-- Grain: one row per account. Status mix is descriptive and is not proof of customer or system fault.
SELECT
  a.account_id,
  a.account_number,
  a.account_type,
  a.status AS account_status,
  COUNT(t.transaction_id) AS transaction_attempts,
  SUM(CASE WHEN t.status = 'SUCCESS' THEN 1 ELSE 0 END) AS successful_attempts,
  SUM(CASE WHEN t.status = 'FAILED' THEN 1 ELSE 0 END) AS failed_attempts,
  SUM(CASE WHEN t.status = 'PENDING' THEN 1 ELSE 0 END) AS pending_attempts,
  SUM(CASE WHEN t.status = 'REVERSED' THEN 1 ELSE 0 END) AS reversed_attempts,
  ROUND(100.0 * SUM(CASE WHEN t.status = 'SUCCESS' THEN 1 ELSE 0 END)
    / NULLIF(COUNT(t.transaction_id), 0), 2) AS success_rate_pct,
  COALESCE(SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END), 0.00)
    AS successful_gross_value
FROM accounts a
LEFT JOIN transactions t ON t.account_id = a.account_id
GROUP BY a.account_id, a.account_number, a.account_type, a.status
ORDER BY success_rate_pct ASC, transaction_attempts DESC, a.account_id;
