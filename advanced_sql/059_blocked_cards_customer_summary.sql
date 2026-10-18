-- Business question: Which blocked or expired cards belong to which customers?
SELECT cd.card_id, cd.card_type, cd.status, cd.issued_at,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.customer_number, a.account_number
FROM cards cd
JOIN customers c ON c.customer_id = cd.customer_id
JOIN accounts a ON a.account_id = cd.account_id
WHERE cd.status IN ('BLOCKED', 'EXPIRED')
ORDER BY cd.issued_at DESC;