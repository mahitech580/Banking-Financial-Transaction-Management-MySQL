-- Business question: At which hours do transaction outcomes and attempted values vary?
SELECT HOUR(transaction_time) AS transaction_hour, channel, status,
       COUNT(*) AS attempts,
       SUM(amount) AS attempted_value,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(100.0 * SUM(status = 'SUCCESS') / COUNT(*), 2) AS success_rate_pct
FROM transactions
GROUP BY HOUR(transaction_time), channel, status
ORDER BY transaction_hour, channel, status;
