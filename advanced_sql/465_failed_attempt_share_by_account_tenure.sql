-- Business question: Compare failed-transaction share across account-age groups.
SELECT a.account_type,
       CASE WHEN DATEDIFF(CURRENT_DATE, a.opened_at) < 30 THEN 'UNDER_30_DAYS'
            WHEN DATEDIFF(CURRENT_DATE, a.opened_at) < 180 THEN '30_TO_179_DAYS'
            WHEN DATEDIFF(CURRENT_DATE, a.opened_at) < 365 THEN '180_TO_364_DAYS'
            ELSE '365_DAYS_PLUS' END AS account_age_band,
       COUNT(t.transaction_id) AS attempts,
       SUM(t.status = 'FAILED') AS failed_attempts,
       SUM(t.status = 'REVERSED') AS reversed_attempts,
       ROUND(100.0 * SUM(t.status = 'FAILED') / NULLIF(COUNT(t.transaction_id), 0), 2) AS failed_rate_pct
FROM accounts AS a
LEFT JOIN transactions AS t ON t.account_id = a.account_id
GROUP BY a.account_type, account_age_band
ORDER BY failed_rate_pct DESC;
