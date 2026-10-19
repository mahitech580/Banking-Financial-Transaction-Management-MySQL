-- Business question: How large is each loan's scheduled repayment total relative to recorded principal?
-- Scheduled totals can include interest and fees; this is descriptive, not an exact interest calculation.
WITH schedule AS (
  SELECT loan_id,COUNT(*) installment_count,SUM(amount_due) total_scheduled_amount,
         SUM(amount_paid) total_recorded_paid_amount
  FROM loan_payments GROUP BY loan_id
)
SELECT l.loan_id,l.customer_id,l.loan_type,l.principal,l.interest_rate,l.tenure_months,l.status,
       COALESCE(s.installment_count,0) installment_count,
       ROUND(COALESCE(s.total_scheduled_amount,0),2) total_scheduled_amount,
       ROUND(COALESCE(s.total_recorded_paid_amount,0),2) total_recorded_paid_amount,
       ROUND(COALESCE(s.total_scheduled_amount,0)/NULLIF(l.principal,0),4) scheduled_to_principal_ratio,
       ROUND(COALESCE(s.total_recorded_paid_amount,0)/NULLIF(l.principal,0),4) paid_to_principal_ratio
FROM loans l LEFT JOIN schedule s ON s.loan_id=l.loan_id
ORDER BY scheduled_to_principal_ratio DESC,l.loan_id;