-- loan repayment collection grouped by scheduled due month; read-only analysis over the banking demo schema.
SELECT DATE_FORMAT(p.due_date,'%Y-%m') AS grouping_value,
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
