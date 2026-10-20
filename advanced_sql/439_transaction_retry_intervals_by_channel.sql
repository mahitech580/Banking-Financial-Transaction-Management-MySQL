-- Business question: Estimate time between a failed transaction attempt and the next attempt on the same account.
WITH ordered_attempts AS (
  SELECT account_id, transaction_id, channel, status, transaction_time,
         LEAD(transaction_time) OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS next_attempt_at,
         LEAD(status) OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS next_status
  FROM transactions
)
SELECT channel, status AS prior_status, next_status,
       COUNT(*) AS attempt_pairs,
       ROUND(AVG(TIMESTAMPDIFF(SECOND, transaction_time, next_attempt_at)), 1) AS average_gap_seconds,
       MIN(TIMESTAMPDIFF(SECOND, transaction_time, next_attempt_at)) AS minimum_gap_seconds,
       MAX(TIMESTAMPDIFF(SECOND, transaction_time, next_attempt_at)) AS maximum_gap_seconds
FROM ordered_attempts
WHERE next_attempt_at IS NOT NULL
GROUP BY channel, status, next_status
ORDER BY attempt_pairs DESC;
