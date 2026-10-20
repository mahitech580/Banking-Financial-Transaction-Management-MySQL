-- Business question: Quantify upcoming unpaid installments by loan type and customer risk label.
SELECT l.loan_type, c.risk_level,
       COUNT(lp.payment_id) AS upcoming_installments,
       SUM(lp.amount_due) AS scheduled_due_amount,
       SUM(lp.amount_due - lp.amount_paid) AS remaining_due_amount,
       MIN(lp.due_date) AS next_due_date,
       MAX(lp.due_date) AS last_due_date
FROM loan_payments AS lp
JOIN loans AS l ON l.loan_id = lp.loan_id
JOIN customers AS c ON c.customer_id = l.customer_id
WHERE lp.due_date >= CURRENT_DATE
  AND lp.due_date < CURRENT_DATE + INTERVAL 30 DAY
  AND lp.amount_paid < lp.amount_due
GROUP BY l.loan_type, c.risk_level
ORDER BY remaining_due_amount DESC;
