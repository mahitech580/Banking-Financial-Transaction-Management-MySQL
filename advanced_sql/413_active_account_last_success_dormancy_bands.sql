-- Business question: Which active positive-balance accounts have gone longest without a successful transaction?
WITH activity AS (
  SELECT account_id, MAX(transaction_time) AS last_success_at
  FROM transactions WHERE status = 'SUCCESS'
  GROUP BY account_id
)
SELECT a.account_number, a.account_type, a.current_balance, x.last_success_at,
       DATEDIFF(CURRENT_DATE, DATE(x.last_success_at)) AS days_since_success,
       CASE WHEN x.last_success_at IS NULL THEN 'NEVER_SUCCESSFUL'
            WHEN x.last_success_at < CURRENT_DATE - INTERVAL 180 DAY THEN 'OVER_180_DAYS'
            WHEN x.last_success_at < CURRENT_DATE - INTERVAL 90 DAY THEN '91_TO_180_DAYS'
            WHEN x.last_success_at < CURRENT_DATE - INTERVAL 30 DAY THEN '31_TO_90_DAYS'
            ELSE 'LAST_30_DAYS' END AS dormancy_band
FROM accounts AS a
LEFT JOIN activity AS x ON x.account_id = a.account_id
WHERE a.status = 'ACTIVE' AND a.current_balance > 0
ORDER BY days_since_success DESC, a.current_balance DESC;
