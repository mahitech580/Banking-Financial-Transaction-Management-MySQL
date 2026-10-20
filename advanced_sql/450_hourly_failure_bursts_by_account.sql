-- Business question: Identify account-hours with multiple failed attempts for operational review.
SELECT account_id, DATE(transaction_time) AS activity_day,
       HOUR(transaction_time) AS activity_hour,
       channel, COUNT(*) AS failed_attempts,
       MIN(transaction_time) AS first_failure_at,
       MAX(transaction_time) AS last_failure_at,
       TIMESTAMPDIFF(SECOND, MIN(transaction_time), MAX(transaction_time)) AS observed_burst_seconds
FROM transactions
WHERE status = 'FAILED'
GROUP BY account_id, DATE(transaction_time), HOUR(transaction_time), channel
HAVING COUNT(*) >= 2
ORDER BY failed_attempts DESC, activity_day DESC, activity_hour DESC;
