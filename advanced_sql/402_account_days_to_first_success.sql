-- Business question: How long after opening does each account record its first successful transaction?
WITH first_success AS (
  SELECT account_id, MIN(transaction_time) AS first_success_at
  FROM transactions
  WHERE status = 'SUCCESS'
  GROUP BY account_id
)
SELECT a.account_id, a.account_number, a.account_type, a.opened_at,
       DATE(fs.first_success_at) AS first_success_date,
       DATEDIFF(DATE(fs.first_success_at), a.opened_at) AS days_to_first_success,
       CASE WHEN fs.first_success_at IS NULL THEN 'NO_SUCCESS_RECORDED'
            WHEN DATE(fs.first_success_at) < a.opened_at THEN 'CHECK_DATE_ORDER'
            ELSE 'SUCCESS_RECORDED' END AS activity_state
FROM accounts AS a
LEFT JOIN first_success AS fs ON fs.account_id = a.account_id
ORDER BY days_to_first_success DESC, a.account_id;
