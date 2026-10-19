-- fraud investigation workload grouped by risk score band; read-only analysis over the banking demo schema.
SELECT CASE WHEN f.risk_score<25 THEN '0-24.99' WHEN f.risk_score<50 THEN '25-49.99' WHEN f.risk_score<75 THEN '50-74.99' ELSE '75-100' END AS grouping_value,
  COUNT(*) AS fraud_event_count,
  COUNT(DISTINCT f.transaction_id) AS distinct_flagged_transactions,
  ROUND(AVG(f.risk_score),2) AS average_risk_score,
  ROUND(MAX(f.risk_score),2) AS maximum_risk_score,
  SUM(f.action_taken='BLOCK') AS block_action_count,
  SUM(f.action_taken='REVIEW') AS review_action_count,
  SUM(f.action_taken='ALLOW') AS allow_action_count
FROM fraud_events f JOIN transactions t ON t.transaction_id=f.transaction_id JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id LEFT JOIN merchants m ON m.merchant_id=t.merchant_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
