-- Business question: Compare activity patterns on calendar days across channels.
SELECT DAY(transaction_time) AS calendar_day_of_month, channel, status,
       COUNT(*) AS attempts,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(AVG(amount), 2) AS average_attempt_amount
FROM transactions
GROUP BY DAY(transaction_time), channel, status
ORDER BY calendar_day_of_month, channel, status;
