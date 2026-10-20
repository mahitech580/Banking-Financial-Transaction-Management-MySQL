-- Business question: How does currently overdue unpaid repayment exposure vary across loan rate bands and customer risk?
-- Grain: one customer-risk/loan-type/rate-band group. The association is descriptive, not evidence that interest rate caused delinquency.
SELECT c.risk_level AS customer_risk_level, l.loan_type,
  CASE WHEN l.interest_rate = 0 THEN 'ZERO_RATE'
    WHEN l.interest_rate <= 5 THEN 'ABOVE_ZERO_TO_5'
    WHEN l.interest_rate <= 10 THEN 'ABOVE_5_TO_10'
    ELSE 'ABOVE_10' END AS annual_rate_band,
  COUNT(DISTINCT l.loan_id) AS loans_with_overdue_installments,
  COUNT(lp.payment_id) AS overdue_installments,
  SUM(lp.amount_due - lp.amount_paid) AS overdue_unpaid_amount,
  ROUND(AVG(l.interest_rate), 3) AS average_annual_interest_rate
FROM loan_payments lp
JOIN loans l ON l.loan_id = lp.loan_id
JOIN customers c ON c.customer_id = l.customer_id
WHERE lp.due_date < CURRENT_DATE AND lp.amount_paid < lp.amount_due
GROUP BY c.risk_level, l.loan_type, annual_rate_band
ORDER BY overdue_unpaid_amount DESC, c.risk_level, l.loan_type;
