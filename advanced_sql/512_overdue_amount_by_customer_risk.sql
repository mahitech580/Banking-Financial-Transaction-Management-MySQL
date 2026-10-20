-- Business question: Summarize unpaid overdue repayment value by customer risk classification.
SELECT c.risk_level, l.loan_type,
       COUNT(lp.payment_id) AS overdue_installments,
       COUNT(DISTINCT l.loan_id) AS affected_loans,
       SUM(lp.amount_due - lp.amount_paid) AS overdue_unpaid_amount,
       MAX(DATEDIFF(CURRENT_DATE, lp.due_date)) AS maximum_days_past_due
FROM loan_payments AS lp
JOIN loans AS l ON l.loan_id = lp.loan_id
JOIN customers AS c ON c.customer_id = l.customer_id
WHERE lp.due_date < CURRENT_DATE AND lp.amount_paid < lp.amount_due
GROUP BY c.risk_level, l.loan_type
ORDER BY overdue_unpaid_amount DESC;
