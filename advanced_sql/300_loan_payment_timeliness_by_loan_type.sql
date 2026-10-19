-- Business question: How early or late are recorded loan payments compared with their due dates?
SELECT l.loan_type,
       COUNT(p.payment_id) payment_records,
       SUM(p.status='PAID') paid_status_count,
       SUM(p.paid_date IS NOT NULL AND p.paid_date<=p.due_date) on_or_before_due_date,
       SUM(p.paid_date IS NOT NULL AND p.paid_date>p.due_date) paid_after_due_date,
       SUM(p.paid_date IS NULL AND p.due_date<CURRENT_DATE AND p.amount_paid<p.amount_due) currently_past_due,
       ROUND(AVG(CASE WHEN p.paid_date IS NOT NULL THEN DATEDIFF(p.paid_date,p.due_date) END),2) average_days_from_due,
       ROUND(SUM(p.amount_paid),2) recorded_paid_amount,
       ROUND(SUM(p.amount_due),2) scheduled_due_amount
FROM loans l JOIN loan_payments p ON p.loan_id=l.loan_id
GROUP BY l.loan_type ORDER BY payment_records DESC;