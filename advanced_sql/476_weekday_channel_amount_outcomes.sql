-- Business question: Compare channel success and value patterns by weekday.
SELECT DAYNAME(transaction_time) AS weekday_name,
       DAYOFWEEK(transaction_time) AS weekday_number,
       channel, status, COUNT(*) AS attempts,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(AVG(amount), 2) AS average_attempt_amount
FROM transactions
GROUP BY DAYNAME(transaction_time), DAYOFWEEK(transaction_time), channel, status
ORDER BY weekday_number, channel, status;
