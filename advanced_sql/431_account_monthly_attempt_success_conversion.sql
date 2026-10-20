-- Business question: Track each account's attempted volume and conversion to successful activity by month.
SELECT a.account_id, a.account_number,
       DATE_FORMAT(t.transaction_time, '%Y-%m') AS transaction_month,
       COUNT(*) AS attempts,
       SUM(t.status = 'SUCCESS') AS successes,
       SUM(t.status = 'FAILED') AS failures,
       ROUND(100.0 * SUM(t.status = 'SUCCESS') / COUNT(*), 2) AS success_rate_pct,
       SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value
FROM accounts AS a
JOIN transactions AS t ON t.account_id = a.account_id
GROUP BY a.account_id, a.account_number, DATE_FORMAT(t.transaction_time, '%Y-%m')
ORDER BY transaction_month DESC, attempts DESC;
