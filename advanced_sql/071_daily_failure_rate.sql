-- Business question: How does the failed transaction rate change each day?
SELECT DATE(transaction_time) AS activity_day, COUNT(*) AS attempts, SUM(status='FAILED') AS failed_count, ROUND(100*SUM(status='FAILED')/NULLIF(COUNT(*),0),2) AS failed_rate_pct, SUM(CASE WHEN status='FAILED' THEN amount ELSE 0 END) AS failed_attempt_value
FROM transactions
GROUP BY DATE(transaction_time)
ORDER BY activity_day;
