-- Business question: Compare overdue repayment exposure using each borrower's registered home branch.
SELECT b.branch_name, l.loan_type,
       COUNT(lp.payment_id) AS overdue_installments,
       COUNT(DISTINCT l.loan_id) AS affected_loans,
       SUM(lp.amount_due) AS due_amount,
       SUM(lp.amount_paid) AS paid_amount,
       SUM(lp.amount_due - lp.amount_paid) AS unpaid_amount
FROM loan_payments AS lp
JOIN loans AS l ON l.loan_id = lp.loan_id
JOIN customers AS c ON c.customer_id = l.customer_id
LEFT JOIN branches AS b ON b.branch_id = c.branch_id
WHERE lp.due_date < CURRENT_DATE AND lp.amount_paid < lp.amount_due
GROUP BY b.branch_id, b.branch_name, l.loan_type
ORDER BY unpaid_amount DESC;
