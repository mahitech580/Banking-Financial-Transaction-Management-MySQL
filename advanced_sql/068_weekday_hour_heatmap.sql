-- Business question: Which weekday and hour combinations have the most ledger activity?
-- Read-only example; interpret amounts alongside transaction status and dataset coverage.
SELECT DAYOFWEEK(transaction_time) AS weekday_number, DAYNAME(transaction_time) AS weekday_name, HOUR(transaction_time) AS hour_of_day, COUNT(*) AS transaction_count, SUM(status='SUCCESS') AS successful_count FROM transactions GROUP BY DAYOFWEEK(transaction_time), DAYNAME(transaction_time), HOUR(transaction_time) ORDER BY transaction_count DESC, weekday_number, hour_of_day;
