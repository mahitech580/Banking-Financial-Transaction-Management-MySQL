-- loan repayment collection grouped by overdue age band; read-only analysis over the banking demo schema.
SELECT CASE WHEN p.paid_date IS NOT NULL THEN 'Paid' WHEN p.due_date>=CURDATE() THEN 'Not yet overdue' WHEN DATEDIFF(CURDATE(),p.due_date)<=30 THEN '1-30 days overdue' WHEN DATEDIFF(CURDATE(),p.due_date)<=90 THEN '31-90 days overdue' ELSE 'Over 90 days overdue' END AS grouping_value,
  COUNT(*) AS installment_count,
  ROUND(SUM(p.amount_due),2) AS amount_due,
  ROUND(SUM(p.amount_paid),2) AS amount_collected,
  ROUND(SUM(p.amount_due-p.amount_paid),2) AS outstanding_installment_amount,
  SUM(p.status IN ('LATE','MISSED')) AS late_or_missed_count,
  SUM(p.status='PAID' AND p.paid_date<=p.due_date) AS paid_on_time_count,
  ROUND(100*SUM(p.amount_paid)/NULLIF(SUM(p.amount_due),0),2) AS collection_rate_pct
FROM loan_payments p JOIN loans l ON l.loan_id=p.loan_id JOIN customers c ON c.customer_id=l.customer_id JOIN accounts a ON a.account_id=l.account_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
