-- Business question: What are paid amounts and payment delays by loan type and scheduled due quarter?
SELECT l.loan_type,YEAR(p.due_date) due_year,QUARTER(p.due_date) due_quarter,
       COUNT(*) scheduled_installments,
       SUM(p.paid_date IS NOT NULL) installments_with_paid_date,
       SUM(p.paid_date IS NOT NULL AND p.paid_date<p.due_date) paid_early,
       SUM(p.paid_date IS NOT NULL AND p.paid_date=p.due_date) paid_on_due_date,
       SUM(p.paid_date IS NOT NULL AND p.paid_date>p.due_date) paid_late,
       ROUND(AVG(CASE WHEN p.paid_date IS NOT NULL THEN DATEDIFF(p.paid_date,p.due_date) END),2) average_days_from_due,
       ROUND(SUM(p.amount_due),2) scheduled_amount,ROUND(SUM(p.amount_paid),2) paid_amount
FROM loan_payments p JOIN loans l ON l.loan_id=p.loan_id
GROUP BY l.loan_type,YEAR(p.due_date),QUARTER(p.due_date)
ORDER BY due_year,due_quarter,l.loan_type;