-- Business question: Which unpaid instalments are past due?
SELECT lp.payment_id, lp.loan_id, lp.due_date, lp.amount_due, lp.amount_paid,
       lp.amount_due - lp.amount_paid AS amount_remaining,
       lp.status
FROM loan_payments lp
WHERE lp.due_date < CURRENT_DATE
  AND lp.amount_paid < lp.amount_due
  AND lp.status IN ('DUE', 'LATE', 'MISSED')
ORDER BY lp.due_date, amount_remaining DESC;