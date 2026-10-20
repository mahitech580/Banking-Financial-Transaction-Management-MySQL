-- Business question: Which customers have two successful same-amount transactions across their own distinct accounts within ten minutes?
-- Grain: one transaction pair. These are investigation candidates; legitimate transfers and routine purchases can produce similar patterns.
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  first_t.transaction_id AS first_transaction_id, first_t.reference_code AS first_reference,
  first_a.account_id AS first_account_id, first_t.transaction_time AS first_time,
  second_t.transaction_id AS second_transaction_id, second_t.reference_code AS second_reference,
  second_a.account_id AS second_account_id, second_t.transaction_time AS second_time,
  first_t.amount, first_t.channel AS first_channel, second_t.channel AS second_channel,
  ABS(TIMESTAMPDIFF(SECOND, first_t.transaction_time, second_t.transaction_time)) AS seconds_apart
FROM transactions first_t
JOIN accounts first_a ON first_a.account_id = first_t.account_id
JOIN transactions second_t
  ON second_t.transaction_id > first_t.transaction_id
  AND second_t.amount = first_t.amount AND second_t.status = 'SUCCESS'
  AND ABS(TIMESTAMPDIFF(SECOND, first_t.transaction_time, second_t.transaction_time)) <= 600
JOIN accounts second_a ON second_a.account_id = second_t.account_id
  AND second_a.customer_id = first_a.customer_id AND second_a.account_id <> first_a.account_id
JOIN customers c ON c.customer_id = first_a.customer_id
WHERE first_t.status = 'SUCCESS'
ORDER BY seconds_apart, c.customer_id, first_t.transaction_time;
