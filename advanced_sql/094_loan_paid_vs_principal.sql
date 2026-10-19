-- Compare original principal with recorded paid repayment amounts; this excludes interest and fees by design.
SELECT l.loan_id,l.customer_id,l.loan_type,l.principal,l.status,
COALESCE(SUM(CASE WHEN r.status='PAID' THEN r.amount ELSE 0 END),0) recorded_paid_amount,
ROUND(l.principal-COALESCE(SUM(CASE WHEN r.status='PAID' THEN r.amount ELSE 0 END),0),2) principal_less_paid_amount
FROM loans l LEFT JOIN loan_repayments r ON r.loan_id=l.loan_id
GROUP BY l.loan_id,l.customer_id,l.loan_type,l.principal,l.status ORDER BY l.loan_id;