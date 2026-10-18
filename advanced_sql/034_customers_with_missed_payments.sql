-- Business question: Which customers have missed or overdue instalments?
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(lp.payment_id) AS missed_or_overdue_instalments,
       SUM(lp.amount_due - lp.amount_paid) AS remaining_amount
FROM customers c
JOIN loans l ON l.customer_id = c.customer_id
JOIN loan_payments lp ON lp.loan_id = l.loan_id
WHERE lp.status = 'MISSED'
   OR (lp.status IN ('DUE', 'LATE') AND lp.due_date < CURRENT_DATE AND lp.amount_paid < lp.amount_due)
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY remaining_amount DESC;