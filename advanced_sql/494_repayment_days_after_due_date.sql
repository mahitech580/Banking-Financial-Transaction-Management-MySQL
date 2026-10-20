-- Business question: Quantify recorded repayment delay for installments with a payment date.
SELECT l.loan_type, lp.status,
       COUNT(*) AS paid_date_rows,
       ROUND(AVG(DATEDIFF(lp.paid_date, lp.due_date)), 2) AS average_days_from_due,
       MIN(DATEDIFF(lp.paid_date, lp.due_date)) AS earliest_days_from_due,
       MAX(DATEDIFF(lp.paid_date, lp.due_date)) AS latest_days_from_due,
       SUM(lp.amount_paid) AS amount_paid
FROM loan_payments AS lp
JOIN loans AS l ON l.loan_id = lp.loan_id
WHERE lp.paid_date IS NOT NULL
GROUP BY l.loan_type, lp.status
ORDER BY average_days_from_due DESC;
