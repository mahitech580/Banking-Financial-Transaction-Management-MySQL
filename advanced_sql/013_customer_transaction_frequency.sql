-- Business question: Which customers transact most frequently, and what is their average amount?
SELECT c.customer_id, c.customer_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(t.transaction_id) AS transaction_count,
       ROUND(AVG(t.amount), 2) AS average_amount,
       SUM(t.amount) AS gross_amount
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN transactions t ON t.account_id = a.account_id
WHERE t.status = 'SUCCESS'
GROUP BY c.customer_id, c.customer_number, c.first_name, c.last_name
ORDER BY transaction_count DESC, gross_amount DESC;