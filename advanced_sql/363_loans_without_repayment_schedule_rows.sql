-- Business question: Which recorded loans currently have no linked repayment-schedule rows?
-- Grain: one loan without schedule rows. The schema permits empty schedules, so confirm product and onboarding rules before interpreting this as an exception.
SELECT l.loan_id, l.customer_id, l.account_id, l.loan_type, l.status AS loan_status,
  l.principal, l.interest_rate, l.tenure_months, l.start_date,
  DATEDIFF(CURRENT_DATE, l.start_date) AS days_since_loan_start
FROM loans l
LEFT JOIN loan_payments lp ON lp.loan_id = l.loan_id
WHERE lp.payment_id IS NULL
ORDER BY l.start_date, l.loan_id;
