-- Business question: How do scheduled, paid, and outstanding repayment amounts trend by due month?
SELECT DATE_FORMAT(p.due_date,'%Y-%m') due_month,l.loan_type,p.status,
       COUNT(*) installment_count,COUNT(DISTINCT p.loan_id) affected_loans,
       ROUND(SUM(p.amount_due),2) scheduled_amount,
       ROUND(SUM(p.amount_paid),2) recorded_paid_amount,
       ROUND(SUM(p.amount_due-p.amount_paid),2) remaining_scheduled_amount,
       ROUND(100*SUM(p.amount_paid)/NULLIF(SUM(p.amount_due),0),2) amount_collection_rate_pct
FROM loan_payments p JOIN loans l ON l.loan_id=p.loan_id
GROUP BY DATE_FORMAT(p.due_date,'%Y-%m'),l.loan_type,p.status
ORDER BY due_month,l.loan_type,p.status;