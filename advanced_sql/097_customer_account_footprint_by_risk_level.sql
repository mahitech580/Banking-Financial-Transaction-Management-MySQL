-- customer account footprint grouped by customer risk level; read-only analysis over the banking demo schema.
SELECT c.risk_level AS grouping_value,
  COUNT(DISTINCT c.customer_id) AS customer_count,
  COUNT(a.account_id) AS account_count,
  SUM(CASE WHEN a.status='ACTIVE' THEN 1 ELSE 0 END) AS active_account_count,
  ROUND(SUM(CASE WHEN a.status='ACTIVE' THEN a.current_balance ELSE 0 END),2) AS active_balance
FROM customers c LEFT JOIN accounts a ON a.customer_id=c.customer_id LEFT JOIN branches b ON b.branch_id=c.branch_id
GROUP BY 1
ORDER BY 2 DESC;
