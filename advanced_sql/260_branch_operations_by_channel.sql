-- branch transaction operations grouped by transaction channel; read-only analysis over the banking demo schema.
SELECT t.channel AS grouping_value,
  COUNT(*) AS transaction_count,
  COUNT(DISTINCT a.account_id) AS accounts_with_activity,
  COUNT(DISTINCT c.customer_id) AS active_customers,
  SUM(t.status='SUCCESS') AS successful_transactions,
  SUM(t.status='FAILED') AS failed_transactions,
  ROUND(SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END),2) AS successful_value,
  ROUND(100*SUM(t.status='SUCCESS')/NULLIF(COUNT(*),0),2) AS success_rate_pct
FROM transactions t JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id JOIN branches b ON b.branch_id=a.branch_id LEFT JOIN merchants m ON m.merchant_id=t.merchant_id
GROUP BY 1
ORDER BY 2 DESC;
