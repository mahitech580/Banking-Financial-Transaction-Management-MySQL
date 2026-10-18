-- Business question: Which active loans have no recorded repayment rows?
SELECT l.loan_id, l.loan_type, l.principal, l.start_date, l.status,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM loans l
JOIN customers c ON c.customer_id = l.customer_id
WHERE l.status = 'ACTIVE'
  AND NOT EXISTS (SELECT 1 FROM loan_payments lp WHERE lp.loan_id = l.loan_id)
ORDER BY l.start_date;