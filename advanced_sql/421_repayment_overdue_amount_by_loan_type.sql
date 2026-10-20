-- Business question: How much unpaid scheduled repayment value is past due by loan type?
SELECT l.loan_type, lp.status,
       COUNT(*) AS installment_count,
       SUM(lp.amount_due) AS scheduled_value,
       SUM(lp.amount_due - lp.amount_paid) AS unpaid_value,
       MIN(lp.due_date) AS oldest_due_date
FROM loan_payments AS lp
JOIN loans AS l ON l.loan_id = lp.loan_id
WHERE lp.due_date < CURRENT_DATE AND lp.amount_paid < lp.amount_due
GROUP BY l.loan_type, lp.status
ORDER BY unpaid_value DESC;
