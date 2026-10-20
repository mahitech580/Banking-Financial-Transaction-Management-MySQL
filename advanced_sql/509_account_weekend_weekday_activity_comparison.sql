-- Business question: Compare successful activity counts and values by account and day type.
SELECT a.account_number,
       CASE WHEN DAYOFWEEK(t.transaction_time) IN (1, 7) THEN 'WEEKEND' ELSE 'WEEKDAY' END AS day_type,
       COUNT(*) AS successful_transactions,
       COUNT(DISTINCT DATE(t.transaction_time)) AS active_days,
       SUM(t.amount) AS successful_value,
       ROUND(AVG(t.amount), 2) AS average_ticket
FROM accounts AS a
JOIN transactions AS t ON t.account_id = a.account_id
WHERE t.status = 'SUCCESS'
GROUP BY a.account_id, a.account_number, day_type
ORDER BY successful_value DESC, a.account_number;
