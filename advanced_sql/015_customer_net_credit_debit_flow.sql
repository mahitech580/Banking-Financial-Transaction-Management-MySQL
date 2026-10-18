-- Business question: What is each customer's net flow using only explicit credits and debits?
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       SUM(CASE WHEN t.transaction_type = 'CREDIT' THEN t.amount
                WHEN t.transaction_type = 'DEBIT' THEN -t.amount ELSE 0 END) AS net_credit_debit_flow
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN transactions t ON t.account_id = a.account_id
WHERE t.status = 'SUCCESS'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY net_credit_debit_flow DESC;