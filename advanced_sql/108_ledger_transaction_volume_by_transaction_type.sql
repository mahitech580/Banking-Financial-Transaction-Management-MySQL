-- ledger transaction volume grouped by transaction type; read-only analysis over the banking demo schema.
SELECT t.transaction_type AS grouping_value,
  COUNT(*) AS attempt_count,
  SUM(t.status='SUCCESS') AS success_count,
  SUM(t.status='FAILED') AS failed_count,
  ROUND(SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END),2) AS successful_value,
  COUNT(DISTINCT c.customer_id) AS distinct_customers,
  ROUND(AVG(t.amount),2) AS average_ticket
FROM transactions t JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id LEFT JOIN branches b ON b.branch_id=a.branch_id LEFT JOIN merchants m ON m.merchant_id=t.merchant_id
GROUP BY 1
ORDER BY 2 DESC;
