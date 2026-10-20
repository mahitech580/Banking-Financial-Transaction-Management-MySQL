-- Business question: What repayment amounts fall due in the next 30 days, and how much remains unpaid on each installment?
-- Grain: one installment. This reads the stored schedule; it does not create or modify collections.
SELECT lp.payment_id, lp.loan_id, l.customer_id, c.risk_level AS customer_risk_level,
  l.loan_type, l.status AS loan_status, lp.due_date, lp.paid_date,
  lp.status AS payment_status, lp.amount_due, lp.amount_paid,
  lp.amount_due - lp.amount_paid AS unpaid_amount,
  DATEDIFF(lp.due_date, CURRENT_DATE) AS days_until_due,
  CASE WHEN lp.amount_paid >= lp.amount_due THEN 'FULLY_PAID'
    WHEN lp.due_date < CURRENT_DATE THEN 'OVERDUE'
    WHEN lp.due_date <= CURRENT_DATE + INTERVAL 7 DAY THEN 'DUE_WITHIN_7_DAYS'
    ELSE 'DUE_WITHIN_8_TO_30_DAYS' END AS collection_window
FROM loan_payments lp
JOIN loans l ON l.loan_id = lp.loan_id
JOIN customers c ON c.customer_id = l.customer_id
WHERE lp.due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL 30 DAY
   OR (lp.due_date < CURRENT_DATE AND lp.amount_paid < lp.amount_due)
ORDER BY lp.due_date, c.risk_level DESC, lp.loan_id, lp.payment_id;
