-- Business question: Which customers have the largest active loan principal exposure?
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(l.loan_id) AS active_loan_count,
       SUM(l.principal) AS active_principal_exposure
FROM customers c
JOIN loans l ON l.customer_id = c.customer_id
WHERE l.status = 'ACTIVE'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY active_principal_exposure DESC;