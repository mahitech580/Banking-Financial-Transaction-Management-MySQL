-- ledger transaction reliability grouped by calendar month; read-only analysis over the banking demo schema.
SELECT DATE_FORMAT(t.transaction_time,'%Y-%m') AS grouping_value,
  COUNT(*) AS attempt_count,
  ROUND(100*SUM(t.status='SUCCESS')/NULLIF(COUNT(*),0),2) AS success_rate_pct,
  SUM(t.status='FAILED') AS failed_count,
  ROUND(SUM(CASE WHEN t.status='FAILED' THEN t.amount ELSE 0 END),2) AS failed_value,
  SUM(t.status='REVERSED') AS reversed_count,
  SUM(t.status='PENDING') AS pending_count,
  COUNT(DISTINCT t.reference_code) AS unique_references
FROM transactions t JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id LEFT JOIN branches b ON b.branch_id=a.branch_id LEFT JOIN merchants m ON m.merchant_id=t.merchant_id
GROUP BY 1
ORDER BY 2 DESC;
