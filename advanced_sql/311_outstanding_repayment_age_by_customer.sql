-- Business question: Which customers have the largest scheduled repayment amounts past due?
SELECT c.customer_id,c.customer_number,l.loan_id,l.loan_type,l.status loan_status,
       COUNT(p.payment_id) overdue_installments,
       ROUND(SUM(p.amount_due-p.amount_paid),2) outstanding_past_due_amount,
       MIN(p.due_date) oldest_due_date,
       MAX(DATEDIFF(CURRENT_DATE,p.due_date)) maximum_days_past_due
FROM customers c JOIN loans l ON l.customer_id=c.customer_id
JOIN loan_payments p ON p.loan_id=l.loan_id
WHERE p.due_date<CURRENT_DATE AND p.amount_paid<p.amount_due
GROUP BY c.customer_id,c.customer_number,l.loan_id,l.loan_type,l.status
ORDER BY outstanding_past_due_amount DESC,maximum_days_past_due DESC;