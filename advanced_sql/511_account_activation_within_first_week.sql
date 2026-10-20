-- Business question: Measure how soon newly opened accounts record their first successful transaction.
WITH first_success AS (
  SELECT account_id, MIN(transaction_time) AS first_success_at
  FROM transactions
  WHERE status = 'SUCCESS'
  GROUP BY account_id
)
SELECT a.account_type,
       CASE WHEN fs.first_success_at IS NULL THEN 'NO_SUCCESS_RECORDED'
            WHEN fs.first_success_at < a.opened_at THEN 'BEFORE_OPENING_REVIEW'
            WHEN fs.first_success_at < a.opened_at + INTERVAL 7 DAY THEN 'WITHIN_7_DAYS'
            WHEN fs.first_success_at < a.opened_at + INTERVAL 30 DAY THEN '8_TO_30_DAYS'
            ELSE 'OVER_30_DAYS' END AS activation_band,
       COUNT(*) AS account_count
FROM accounts AS a
LEFT JOIN first_success AS fs ON fs.account_id = a.account_id
GROUP BY a.account_type, activation_band
ORDER BY a.account_type, activation_band;
