-- Business question: Find candidate same-customer events across card and account activity for manual reconciliation.
-- Matching amount and approximate time do not prove the records represent the same payment.
SELECT c.customer_number, m.merchant_name,
       t.reference_code AS ledger_reference, ct.reference_code AS card_reference,
       t.amount AS ledger_amount, ct.amount AS card_amount,
       t.transaction_time AS ledger_time, ct.transaction_time AS card_time,
       TIMESTAMPDIFF(SECOND, t.transaction_time, ct.transaction_time) AS time_difference_seconds,
       t.status AS ledger_status, ct.status AS card_status
FROM transactions AS t
JOIN accounts AS a ON a.account_id = t.account_id
JOIN customers AS c ON c.customer_id = a.customer_id
JOIN card_transactions AS ct ON ct.merchant_id = t.merchant_id AND ct.amount = t.amount
JOIN cards AS cd ON cd.card_id = ct.card_id AND cd.customer_id = c.customer_id
JOIN merchants AS m ON m.merchant_id = t.merchant_id
WHERE t.merchant_id IS NOT NULL
  AND ABS(TIMESTAMPDIFF(SECOND, t.transaction_time, ct.transaction_time)) <= 300
ORDER BY ABS(TIMESTAMPDIFF(SECOND, t.transaction_time, ct.transaction_time)), c.customer_number;
