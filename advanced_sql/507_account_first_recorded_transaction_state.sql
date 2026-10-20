-- Business question: Identify each account's first recorded transaction and its status.
WITH ranked_transactions AS (
  SELECT t.account_id, t.transaction_id, t.reference_code, t.transaction_time, t.status, t.amount, t.channel,
         ROW_NUMBER() OVER (PARTITION BY t.account_id ORDER BY t.transaction_time, t.transaction_id) AS event_rank
  FROM transactions AS t
)
SELECT a.account_number, a.opened_at,
       rt.transaction_id AS first_transaction_id,
       rt.reference_code AS first_reference,
       rt.transaction_time AS first_transaction_at,
       rt.status AS first_transaction_status,
       rt.channel AS first_transaction_channel,
       rt.amount AS first_transaction_amount,
       DATEDIFF(DATE(rt.transaction_time), a.opened_at) AS days_from_opening
FROM accounts AS a
LEFT JOIN ranked_transactions AS rt ON rt.account_id = a.account_id AND rt.event_rank = 1
ORDER BY first_transaction_at, a.account_number;
