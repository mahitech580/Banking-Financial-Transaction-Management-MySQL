-- Business question: Are there successful same-card purchases to the same merchant for the same amount within five minutes?
-- Grain: one candidate pair. Repeat purchases can be legitimate; timestamps and references should be checked before any disposition.
SELECT first_tx.card_id, c.customer_id, first_tx.merchant_id, m.merchant_name,
  first_tx.amount AS purchase_amount, first_tx.card_transaction_id AS first_transaction_id,
  first_tx.reference_code AS first_reference, first_tx.transaction_time AS first_time,
  second_tx.card_transaction_id AS second_transaction_id,
  second_tx.reference_code AS second_reference, second_tx.transaction_time AS second_time,
  ABS(TIMESTAMPDIFF(SECOND, first_tx.transaction_time, second_tx.transaction_time)) AS seconds_apart
FROM card_transactions first_tx
JOIN card_transactions second_tx
  ON second_tx.card_transaction_id > first_tx.card_transaction_id
  AND second_tx.card_id = first_tx.card_id
  AND second_tx.merchant_id = first_tx.merchant_id
  AND second_tx.amount = first_tx.amount
  AND second_tx.status = 'SUCCESS'
  AND ABS(TIMESTAMPDIFF(SECOND, first_tx.transaction_time, second_tx.transaction_time)) <= 300
JOIN cards c ON c.card_id = first_tx.card_id
JOIN merchants m ON m.merchant_id = first_tx.merchant_id
WHERE first_tx.status = 'SUCCESS'
ORDER BY seconds_apart, first_tx.card_id, first_tx.transaction_time;
