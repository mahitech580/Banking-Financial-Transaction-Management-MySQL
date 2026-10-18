-- Business question: Which registered customers currently have no account?
SELECT c.customer_id, c.customer_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.customer_since, c.risk_level
FROM customers c
LEFT JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_id IS NULL
ORDER BY c.customer_since;