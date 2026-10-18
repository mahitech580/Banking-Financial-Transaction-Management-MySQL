-- Business question: How does transaction frequency vary by weekday?
SELECT DAYOFWEEK(transaction_time) AS weekday_number,
       DAYNAME(transaction_time) AS weekday_name,
       COUNT(*) AS transaction_count,
       SUM(status = 'SUCCESS') AS successful_count,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
FROM transactions
GROUP BY DAYOFWEEK(transaction_time), DAYNAME(transaction_time)
ORDER BY weekday_number;