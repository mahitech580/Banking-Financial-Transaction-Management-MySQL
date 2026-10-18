-- Business question: When did each account first and most recently transact?
WITH ordered AS (
  SELECT account_id, transaction_id, reference_code, transaction_time,
         ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS first_rank,
         ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY transaction_time DESC, transaction_id DESC) AS last_rank
  FROM transactions
)
SELECT a.account_number,
       MAX(CASE WHEN o.first_rank = 1 THEN o.reference_code END) AS first_reference,
       MAX(CASE WHEN o.first_rank = 1 THEN o.transaction_time END) AS first_transaction_at,
       MAX(CASE WHEN o.last_rank = 1 THEN o.reference_code END) AS latest_reference,
       MAX(CASE WHEN o.last_rank = 1 THEN o.transaction_time END) AS latest_transaction_at
FROM accounts a LEFT JOIN ordered o ON o.account_id = a.account_id
GROUP BY a.account_id, a.account_number
ORDER BY a.account_number;