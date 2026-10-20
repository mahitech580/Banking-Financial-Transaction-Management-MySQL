-- Business question: Check whether transaction reference prefixes are distributed consistently by channel.
SELECT channel, LEFT(reference_code, 3) AS reference_prefix,
       status, COUNT(*) AS transaction_count,
       MIN(transaction_time) AS first_seen_at,
       MAX(transaction_time) AS last_seen_at,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
FROM transactions
GROUP BY channel, LEFT(reference_code, 3), status
ORDER BY channel, transaction_count DESC;
