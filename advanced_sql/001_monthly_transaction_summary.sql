-- Business question: How many transactions and what successful value did each month generate?
SELECT DATE_FORMAT(transaction_time, '%Y-%m') AS month,
       COUNT(*) AS transaction_count,
       SUM(status = 'SUCCESS') AS successful_count,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
FROM transactions
GROUP BY DATE_FORMAT(transaction_time, '%Y-%m')
ORDER BY month;