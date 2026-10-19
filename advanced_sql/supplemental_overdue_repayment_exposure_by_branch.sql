-- Business question: How much scheduled repayment remains overdue at each servicing branch?
SELECT b.branch_id,b.branch_code,b.branch_name,
       COUNT(lp.payment_id) overdue_installments,
       COUNT(DISTINCT l.loan_id) affected_loans,
       ROUND(SUM(lp.amount_due-l.amount_paid),2) outstanding_overdue_amount,
       MIN(lp.due_date) oldest_due_date,
       MAX(DATEDIFF(CURRENT_DATE,lp.due_date)) maximum_days_overdue
FROM loan_payments lp
JOIN loans l ON l.loan_id=lp.loan_id
JOIN accounts a ON a.account_id=l.account_id
JOIN branches b ON b.branch_id=a.branch_id
WHERE lp.due_date<CURRENT_DATE AND lp.amount_paid<lp.amount_due
GROUP BY b.branch_id,b.branch_code,b.branch_name
ORDER BY outstanding_overdue_amount DESC;