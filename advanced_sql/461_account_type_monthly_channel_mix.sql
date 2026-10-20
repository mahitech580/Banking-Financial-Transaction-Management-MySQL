-- Business question: Compare channel distribution across account types month by month.
SELECT a.account_type, t.channel,
       DATE_FORMAT(t.transaction_time, '%Y-%m') AS activity_month,
       COUNT(*) AS attempts,
       SUM(t.status = 'SUCCESS') AS successful_attempts,
       SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value,
       ROUND(100.0 * SUM(t.status = 'SUCCESS') / COUNT(*), 2) AS success_rate_pct
FROM accounts AS a
JOIN transactions AS t ON t.account_id = a.account_id
GROUP BY a.account_type, t.channel, DATE_FORMAT(t.transaction_time, '%Y-%m')
ORDER BY activity_month DESC, a.account_type, attempts DESC;
