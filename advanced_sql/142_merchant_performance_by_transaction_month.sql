-- merchant ledger performance grouped by transaction month; read-only analysis over the banking demo schema.
SELECT DATE_FORMAT(t.transaction_time,'%Y-%m') AS grouping_value,
  COUNT(*) AS attempt_count,
  COUNT(DISTINCT c.customer_id) AS distinct_customers,
  SUM(t.status='SUCCESS') AS successful_attempts,
  ROUND(100*SUM(t.status='SUCCESS')/NULLIF(COUNT(*),0),2) AS success_rate_pct,
  ROUND(SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END),2) AS successful_value,
  ROUND(AVG(t.amount),2) AS average_ticket
FROM transactions t JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id JOIN merchants m ON m.merchant_id=t.merchant_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
