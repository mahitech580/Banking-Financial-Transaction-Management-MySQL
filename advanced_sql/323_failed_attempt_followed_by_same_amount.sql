-- Business question: What happens after a failed attempt when the next same-account attempt has the same amount?
-- A subsequent retry pattern is not proof of duplicate posting or fraud.
WITH sequence_rows AS (
  SELECT account_id,transaction_id,transaction_time,amount,status,channel,
         LEAD(transaction_id) OVER(PARTITION BY account_id ORDER BY transaction_time,transaction_id) next_transaction_id,
         LEAD(transaction_time) OVER(PARTITION BY account_id ORDER BY transaction_time,transaction_id) next_transaction_time,
         LEAD(amount) OVER(PARTITION BY account_id ORDER BY transaction_time,transaction_id) next_amount,
         LEAD(status) OVER(PARTITION BY account_id ORDER BY transaction_time,transaction_id) next_status
  FROM transactions
)
SELECT account_id,transaction_id failed_attempt_id,next_transaction_id,
       transaction_time failed_at,next_transaction_time next_attempt_at,amount,
       status failed_status,next_status,channel,
       TIMESTAMPDIFF(MINUTE,transaction_time,next_transaction_time) minutes_until_next_attempt
FROM sequence_rows
WHERE status='FAILED' AND next_transaction_id IS NOT NULL
  AND next_transaction_time<=transaction_time+INTERVAL 24 HOUR
  AND next_amount=amount
ORDER BY minutes_until_next_attempt,account_id;