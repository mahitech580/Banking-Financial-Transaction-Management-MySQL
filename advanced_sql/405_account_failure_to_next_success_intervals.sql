-- Business question: Which accounts repeatedly encounter failures before later success?
WITH ordered_events AS (
  SELECT account_id, transaction_id, transaction_time, status, amount,
         LEAD(transaction_time) OVER (
           PARTITION BY account_id ORDER BY transaction_time, transaction_id
         ) AS next_time,
         LEAD(status) OVER (
           PARTITION BY account_id ORDER BY transaction_time, transaction_id
         ) AS next_status
  FROM transactions
)
SELECT a.account_number, COUNT(*) AS failed_then_success_pairs,
       ROUND(AVG(TIMESTAMPDIFF(SECOND, oe.transaction_time, oe.next_time)), 1) AS average_recovery_seconds,
       MAX(TIMESTAMPDIFF(SECOND, oe.transaction_time, oe.next_time)) AS longest_recovery_seconds
FROM ordered_events AS oe
JOIN accounts AS a ON a.account_id = oe.account_id
WHERE oe.status = 'FAILED' AND oe.next_status = 'SUCCESS' AND oe.next_time IS NOT NULL
GROUP BY a.account_id, a.account_number
ORDER BY failed_then_success_pairs DESC, average_recovery_seconds DESC;
