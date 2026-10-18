-- Business question: What are the daily transaction counts, successes, and successful values?
SELECT DATE(transaction_time) AS activity_date,
       COUNT(*) AS attempts,
       SUM(status = 'SUCCESS') AS successful_transactions,
       SUM(status = 'FAILED') AS failed_transactions,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
FROM transactions
GROUP BY DATE(transaction_time)
ORDER BY activity_date DESC;