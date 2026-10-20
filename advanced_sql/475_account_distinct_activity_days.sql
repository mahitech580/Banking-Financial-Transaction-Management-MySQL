-- Business question: Compare account activity frequency by the number of distinct days with transaction attempts.
SELECT a.account_type, a.status AS account_status,
       CASE WHEN x.active_days IS NULL THEN 'NO_ACTIVITY'
            WHEN x.active_days = 1 THEN 'ONE_DAY'
            WHEN x.active_days BETWEEN 2 AND 7 THEN '2_TO_7_DAYS'
            WHEN x.active_days BETWEEN 8 AND 30 THEN '8_TO_30_DAYS'
            ELSE 'OVER_30_DAYS' END AS activity_day_band,
       COUNT(*) AS account_count,
       SUM(a.current_balance) AS current_balance,
       SUM(COALESCE(x.attempts, 0)) AS transaction_attempts
FROM accounts AS a
LEFT JOIN (
  SELECT account_id, COUNT(DISTINCT DATE(transaction_time)) AS active_days,
         COUNT(*) AS attempts
  FROM transactions
  GROUP BY account_id
) AS x ON x.account_id = a.account_id
GROUP BY a.account_type, a.status, activity_day_band
ORDER BY a.account_type, activity_day_band;
