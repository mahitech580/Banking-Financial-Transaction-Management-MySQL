-- Business question: Which active accounts have had no successful transaction in the last 90 calendar days?
-- Grain: one row per active account. This is an operational follow-up list, not evidence of account misuse.
WITH last_success AS (
  SELECT account_id, MAX(transaction_time) AS last_success_at,
    COUNT(*) AS lifetime_success_count
  FROM transactions
  WHERE status = 'SUCCESS'
  GROUP BY account_id
)
SELECT a.account_id, a.account_number, a.account_type, a.current_balance, a.opened_at,
  ls.last_success_at, COALESCE(ls.lifetime_success_count, 0) AS lifetime_success_count,
  CASE WHEN ls.last_success_at IS NULL THEN 'NO_SUCCESSFUL_ACTIVITY_RECORDED'
    WHEN ls.last_success_at < CURRENT_DATE - INTERVAL 90 DAY THEN 'NO_SUCCESS_IN_90_DAYS'
    ELSE 'RECENT_SUCCESS' END AS activity_band,
  CASE WHEN ls.last_success_at IS NULL THEN NULL
    ELSE DATEDIFF(CURRENT_DATE, DATE(ls.last_success_at)) END AS days_since_last_success
FROM accounts a
LEFT JOIN last_success ls ON ls.account_id = a.account_id
WHERE a.status = 'ACTIVE'
  AND (ls.last_success_at IS NULL OR ls.last_success_at < CURRENT_DATE - INTERVAL 90 DAY)
ORDER BY a.current_balance DESC, ls.last_success_at, a.account_id;
