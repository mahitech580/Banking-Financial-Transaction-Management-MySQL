-- Business question: Which accounts have a negative stored balance, alongside their last successful ledger event?
-- Grain: one account. The core schema does not prohibit negative balances; compare with overdraft/product policy before escalation.
WITH last_success AS (
  SELECT account_id, MAX(transaction_time) AS last_success_at,
    SUM(status = 'SUCCESS') AS successful_count
  FROM transactions
  GROUP BY account_id
)
SELECT a.account_id, a.account_number, a.account_type, a.status AS account_status,
  a.current_balance, a.opened_at, ls.last_success_at,
  COALESCE(ls.successful_count, 0) AS successful_count,
  CASE WHEN ls.last_success_at IS NULL THEN 'NO_SUCCESSFUL_TRANSACTION'
    WHEN ls.last_success_at < CURRENT_DATE - INTERVAL 90 DAY THEN 'STALE_SUCCESS_ACTIVITY'
    ELSE 'RECENT_SUCCESS_ACTIVITY' END AS activity_review
FROM accounts a
LEFT JOIN last_success ls ON ls.account_id = a.account_id
WHERE a.current_balance < 0
ORDER BY a.current_balance ASC, ls.last_success_at, a.account_id;
