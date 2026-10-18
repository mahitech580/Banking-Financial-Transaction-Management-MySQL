-- Business question: How much is due and paid across each recorded repayment status?
SELECT status, COUNT(*) AS installment_count,
       SUM(amount_due) AS total_due,
       SUM(amount_paid) AS total_paid,
       SUM(amount_due - amount_paid) AS unpaid_difference
FROM loan_payments
GROUP BY status
ORDER BY installment_count DESC;