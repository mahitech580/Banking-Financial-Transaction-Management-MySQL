-- loan collection efficiency grouped by borrower risk; read-only analysis over the banking demo schema.
SELECT c.risk_level AS grouping_value,
  COUNT(DISTINCT l.loan_id) AS loan_count,
  COUNT(*) AS installment_count,
  ROUND(SUM(p.amount_due),2) AS scheduled_amount,
  ROUND(SUM(p.amount_paid),2) AS collected_amount,
  ROUND(100*SUM(p.amount_paid)/NULLIF(SUM(p.amount_due),0),2) AS collection_rate_pct,
  ROUND(SUM(CASE WHEN p.due_date<CURDATE() AND p.amount_paid<p.amount_due THEN p.amount_due-p.amount_paid ELSE 0 END),2) AS overdue_amount,
  ROUND(AVG(CASE WHEN p.paid_date IS NOT NULL THEN DATEDIFF(p.paid_date,p.due_date) END),2) AS average_days_vs_due_date
FROM loans l JOIN loan_payments p ON p.loan_id=l.loan_id JOIN customers c ON c.customer_id=l.customer_id JOIN accounts a ON a.account_id=l.account_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
