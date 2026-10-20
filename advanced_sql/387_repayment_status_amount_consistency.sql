-- Business question: Which repayment rows have amount/status combinations worth checking against the operational status rules?
-- Grain: one flagged installment. Partial payments and status-update timing may explain an exception; no row is modified.
SELECT lp.payment_id, lp.loan_id, l.customer_id, lp.due_date, lp.paid_date,
  lp.status AS payment_status, lp.amount_due, lp.amount_paid,
  lp.amount_due - lp.amount_paid AS remaining_due,
  CASE WHEN lp.status = 'PAID' AND lp.amount_paid < lp.amount_due THEN 'PAID_BELOW_FULL_AMOUNT'
    WHEN lp.status <> 'PAID' AND lp.amount_paid >= lp.amount_due THEN 'FULL_AMOUNT_BUT_NOT_PAID_STATUS'
    WHEN lp.status = 'MISSED' AND lp.paid_date IS NOT NULL THEN 'MISSED_WITH_PAID_DATE'
    WHEN lp.status = 'DUE' AND lp.paid_date IS NOT NULL THEN 'DUE_WITH_PAID_DATE'
    ELSE 'OTHER_REVIEW' END AS consistency_reason
FROM loan_payments lp JOIN loans l ON l.loan_id = lp.loan_id
WHERE (lp.status = 'PAID' AND lp.amount_paid < lp.amount_due)
   OR (lp.status <> 'PAID' AND lp.amount_paid >= lp.amount_due)
   OR (lp.status = 'MISSED' AND lp.paid_date IS NOT NULL)
   OR (lp.status = 'DUE' AND lp.paid_date IS NOT NULL)
ORDER BY lp.due_date, lp.loan_id, lp.payment_id;
