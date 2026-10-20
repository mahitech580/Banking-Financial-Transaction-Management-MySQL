-- Business question: Compare transaction-type outcomes across channels.
SELECT transaction_type, channel, status,
       COUNT(*) AS attempt_count,
       SUM(amount) AS attempted_value,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(AVG(amount), 2) AS average_amount,
       COUNT(DISTINCT account_id) AS accounts_involved
FROM transactions
GROUP BY transaction_type, channel, status
ORDER BY transaction_type, channel, status;
