-- Business question: How many distinct customers transact each day?
SELECT DATE(t.transaction_time) AS activity_day, COUNT(DISTINCT a.customer_id) AS distinct_customers, COUNT(*) AS transaction_rows, SUM(t.status = 'SUCCESS') AS successful_rows
FROM transactions t JOIN accounts a ON a.account_id = t.account_id
GROUP BY DATE(t.transaction_time)
ORDER BY activity_day;
