-- Business question: Compare outcome mix near calendar month boundaries with the rest of the month.
SELECT DATE_FORMAT(transaction_time, '%Y-%m') AS activity_month,
       CASE WHEN DAY(transaction_time) <= 3 THEN 'FIRST_3_DAYS'
            WHEN DATE(transaction_time) >= LAST_DAY(transaction_time) - INTERVAL 2 DAY THEN 'LAST_3_DAYS'
            ELSE 'MIDDLE_OF_MONTH' END AS month_segment,
       channel, status,
       COUNT(*) AS attempts,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(100.0 * SUM(status = 'SUCCESS') / COUNT(*), 2) AS success_rate_pct
FROM transactions
GROUP BY DATE_FORMAT(transaction_time, '%Y-%m'), month_segment, channel, status
ORDER BY activity_month DESC, month_segment, channel;
