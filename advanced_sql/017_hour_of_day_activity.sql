-- Business question: During which hours does transaction activity peak?
SELECT HOUR(transaction_time) AS hour_of_day,
       COUNT(*) AS transaction_count,
       SUM(status = 'SUCCESS') AS successful_count,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
FROM transactions
GROUP BY HOUR(transaction_time)
ORDER BY transaction_count DESC, successful_value DESC;