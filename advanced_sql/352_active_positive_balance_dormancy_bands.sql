-- Business question: How are positive-balance active accounts distributed by time since last successful transaction?
-- Grain: one row per account; dormancy is date-based, and a missing success timestamp is shown separately.
WITH last_success AS (
  SELECT account_id, MAX(transaction_time) AS last_success_at
  FROM transactions WHERE status = 'SUCCESS'
  GROUP BY account_id
),
classified AS (
  SELECT a.account_id, a.account_type, a.branch_id, a.current_balance, ls.last_success_at,
    CASE WHEN ls.last_success_at IS NULL THEN 'NEVER_SUCCESSFUL'
      WHEN ls.last_success_at >= CURRENT_DATE - INTERVAL 30 DAY THEN '0_TO_30_DAYS'
      WHEN ls.last_success_at >= CURRENT_DATE - INTERVAL 90 DAY THEN '31_TO_90_DAYS'
      WHEN ls.last_success_at >= CURRENT_DATE - INTERVAL 180 DAY THEN '91_TO_180_DAYS'
      ELSE 'OVER_180_DAYS' END AS dormancy_band
  FROM accounts a LEFT JOIN last_success ls ON ls.account_id = a.account_id
  WHERE a.status = 'ACTIVE' AND a.current_balance > 0
)
SELECT dormancy_band, account_type, COUNT(*) AS account_count,
  SUM(current_balance) AS positive_balance_total,
  ROUND(AVG(current_balance), 2) AS average_balance,
  MIN(current_balance) AS minimum_balance, MAX(current_balance) AS maximum_balance
FROM classified
GROUP BY dormancy_band, account_type
ORDER BY FIELD(dormancy_band, 'NEVER_SUCCESSFUL', 'OVER_180_DAYS', '91_TO_180_DAYS', '31_TO_90_DAYS', '0_TO_30_DAYS'),
  account_type;
