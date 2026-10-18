-- Business question: Who has the largest explicit successful debit outflow?
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(t.transaction_id) AS debit_count,
       SUM(t.amount) AS total_debit_amount,
       AVG(t.amount) AS average_debit_amount
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN transactions t ON t.account_id = a.account_id
WHERE t.status = 'SUCCESS' AND t.transaction_type = 'DEBIT'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_debit_amount DESC;