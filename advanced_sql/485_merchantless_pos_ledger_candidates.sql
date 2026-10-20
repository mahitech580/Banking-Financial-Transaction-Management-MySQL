-- Business question: Identify point-of-sale ledger attempts with no linked merchant.
SELECT t.transaction_id, t.reference_code, t.transaction_time, t.amount,
       t.status, t.channel, t.transaction_type, a.account_number, c.customer_number
FROM transactions AS t
JOIN accounts AS a ON a.account_id = t.account_id
JOIN customers AS c ON c.customer_id = a.customer_id
WHERE t.channel = 'POS' AND t.merchant_id IS NULL
ORDER BY t.transaction_time DESC, t.transaction_id DESC;
