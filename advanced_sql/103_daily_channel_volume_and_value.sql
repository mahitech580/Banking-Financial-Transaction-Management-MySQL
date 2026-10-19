-- Business question: What is the daily attempt, success, failure, and successful-value trend by channel?
SELECT DATE(transaction_time) activity_date,channel,COUNT(*) attempts,
       SUM(status='SUCCESS') successes,SUM(status='FAILED') failures,
       ROUND(SUM(CASE WHEN status='SUCCESS' THEN amount ELSE 0 END),2) successful_value
FROM transactions
GROUP BY DATE(transaction_time),channel
ORDER BY activity_date,channel;