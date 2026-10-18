-- Business question: Which accounts do not have a linked card?
SELECT a.account_id, a.account_number, a.account_type, a.status,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM accounts a
JOIN customers c ON c.customer_id = a.customer_id
WHERE NOT EXISTS (SELECT 1 FROM cards cd WHERE cd.account_id = a.account_id)
ORDER BY c.last_name, c.first_name, a.account_number;