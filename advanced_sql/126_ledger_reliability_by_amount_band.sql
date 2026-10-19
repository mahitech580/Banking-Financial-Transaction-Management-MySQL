-- ledger transaction reliability grouped by amount band; read-only analysis over the banking demo schema.
SELECT CASE WHEN t.amount<500 THEN 'Below 500' WHEN t.amount<5000 THEN '500-4999' WHEN t.amount<50000 THEN '5000-49999' ELSE '50000+' END AS grouping_value,
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
