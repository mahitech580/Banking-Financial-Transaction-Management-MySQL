-- Business question: Which weekday and hour combinations have the most ledger activity?
-- MySQL DAYOFWEEK uses 1=Sunday through 7=Saturday; this is descriptive, not a fraud rule.
SELECT DAYOFWEEK(transaction_time) AS weekday_number, DAYNAME(transaction_time) AS weekday_name, HOUR(transaction_time) AS hour_of_day, COUNT(*) AS transaction_count, SUM(status='SUCCESS') AS successful_count
FROM transactions
GROUP BY DAYOFWEEK(transaction_time), DAYNAME(transaction_time), HOUR(transaction_time)
ORDER BY transaction_count DESC, weekday_number, hour_of_day;
