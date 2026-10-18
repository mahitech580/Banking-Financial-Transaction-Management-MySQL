-- Business question: How many days late were repayments that have a paid date?
SELECT lp.payment_id, lp.loan_id, lp.due_date, lp.paid_date,
       GREATEST(DATEDIFF(lp.paid_date, lp.due_date), 0) AS days_late,
       lp.amount_due, lp.amount_paid, lp.status
FROM loan_payments lp
WHERE lp.paid_date IS NOT NULL
ORDER BY days_late DESC, lp.paid_date DESC;