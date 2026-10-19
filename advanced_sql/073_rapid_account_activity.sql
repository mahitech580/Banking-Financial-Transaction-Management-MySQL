-- Business question: Which account ledger rows occurred within five minutes of the preceding row?
-- These are review candidates only; closely spaced activity can be legitimate.
WITH ordered AS (
  SELECT account_id, transaction_id, reference_code, transaction_time,
         LAG(transaction_time) OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS previous_time
  FROM transactions
)
SELECT account_id, transaction_id, reference_code, previous_time, transaction_time,
       TIMESTAMPDIFF(SECOND, previous_time, transaction_time) AS gap_seconds
FROM ordered
WHERE previous_time IS NOT NULL
  AND transaction_time <= DATE_ADD(previous_time, INTERVAL 5 MINUTE)
ORDER BY transaction_time DESC, account_id;
