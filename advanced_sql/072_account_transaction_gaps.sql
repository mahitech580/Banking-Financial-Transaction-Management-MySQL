-- Business question: What is the elapsed time between consecutive ledger rows for each account?
WITH ordered AS (
  SELECT account_id, transaction_id, reference_code, transaction_time,
         LAG(transaction_time) OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS previous_time
  FROM transactions
)
SELECT account_id, transaction_id, reference_code, previous_time, transaction_time,
       TIMESTAMPDIFF(SECOND, previous_time, transaction_time) AS gap_seconds
FROM ordered
WHERE previous_time IS NOT NULL
ORDER BY gap_seconds, account_id;
