-- Business question: How long after account opening does the first successful ledger transaction appear?
-- Grain: one account. Negative intervals can reveal timestamps that precede the recorded opening date and should be verified.
WITH first_success AS (
  SELECT account_id, MIN(transaction_time) AS first_success_at,
    COUNT(*) AS success_count
  FROM transactions WHERE status = 'SUCCESS'
  GROUP BY account_id
)
SELECT a.account_id, a.account_number, a.account_type, a.status AS account_status,
  a.opened_at, fs.first_success_at, COALESCE(fs.success_count, 0) AS lifetime_success_count,
  CASE WHEN fs.first_success_at IS NULL THEN NULL
    ELSE DATEDIFF(DATE(fs.first_success_at), a.opened_at) END AS days_from_open_to_first_success,
  CASE WHEN fs.first_success_at IS NULL THEN 'NO_SUCCESSFUL_ACTIVITY'
    WHEN DATE(fs.first_success_at) < a.opened_at THEN 'SUCCESS_PRECEDES_OPEN_DATE'
    WHEN DATEDIFF(DATE(fs.first_success_at), a.opened_at) <= 7 THEN 'WITHIN_7_DAYS'
    WHEN DATEDIFF(DATE(fs.first_success_at), a.opened_at) <= 30 THEN 'WITHIN_30_DAYS'
    ELSE 'AFTER_30_DAYS' END AS activation_band
FROM accounts a LEFT JOIN first_success fs ON fs.account_id = a.account_id
ORDER BY days_from_open_to_first_success, a.opened_at, a.account_id;
