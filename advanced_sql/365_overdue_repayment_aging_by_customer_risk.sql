-- Business question: How is unpaid overdue repayment exposure distributed by customer risk and loan product?
-- Grain: one risk/loan-type/aging bucket. Partial payments are represented by remaining amounts due, not full installment face value.
SELECT c.risk_level AS customer_risk_level, l.loan_type,
  CASE WHEN DATEDIFF(CURRENT_DATE, lp.due_date) BETWEEN 1 AND 7 THEN '1_TO_7_DAYS'
    WHEN DATEDIFF(CURRENT_DATE, lp.due_date) BETWEEN 8 AND 30 THEN '8_TO_30_DAYS'
    WHEN DATEDIFF(CURRENT_DATE, lp.due_date) BETWEEN 31 AND 90 THEN '31_TO_90_DAYS'
    ELSE 'OVER_90_DAYS' END AS overdue_age_band,
  COUNT(*) AS overdue_installments,
  COUNT(DISTINCT l.loan_id) AS affected_loans,
  COUNT(DISTINCT c.customer_id) AS affected_customers,
  SUM(lp.amount_due - lp.amount_paid) AS overdue_unpaid_amount
FROM loan_payments lp
JOIN loans l ON l.loan_id = lp.loan_id
JOIN customers c ON c.customer_id = l.customer_id
WHERE lp.due_date < CURRENT_DATE AND lp.amount_paid < lp.amount_due
GROUP BY c.risk_level, l.loan_type, overdue_age_band
ORDER BY c.risk_level, l.loan_type,
  FIELD(overdue_age_band, '1_TO_7_DAYS', '8_TO_30_DAYS', '31_TO_90_DAYS', 'OVER_90_DAYS');
