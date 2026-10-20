-- Business question: Compare early transaction activity for accounts grouped by opening month.
WITH account_activity AS (
  SELECT a.account_id, a.opened_at,
         COUNT(t.transaction_id) AS attempts,
         SUM(t.status = 'SUCCESS') AS successes,
         SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value
  FROM accounts AS a
  LEFT JOIN transactions AS t
    ON t.account_id = a.account_id
   AND t.transaction_time >= a.opened_at
   AND t.transaction_time < DATE_ADD(a.opened_at, INTERVAL 1 YEAR)
  GROUP BY a.account_id, a.opened_at
)
SELECT DATE_FORMAT(opened_at, '%Y-%m') AS opening_cohort,
       COUNT(*) AS account_count,
       SUM(attempts) AS first_year_attempts,
       SUM(successes) AS first_year_successes,
       SUM(successful_value) AS first_year_successful_value,
       ROUND(100.0 * SUM(successes) / NULLIF(SUM(attempts), 0), 2) AS first_year_success_rate_pct
FROM account_activity
GROUP BY DATE_FORMAT(opened_at, '%Y-%m')
ORDER BY opening_cohort DESC;
