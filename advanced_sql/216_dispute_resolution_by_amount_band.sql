-- transaction dispute resolution grouped by disputed amount band; read-only analysis over the banking demo schema.
SELECT CASE WHEN d.disputed_amount<500 THEN 'Under 500' WHEN d.disputed_amount<5000 THEN '500-4999' WHEN d.disputed_amount<50000 THEN '5000-49999' ELSE '50000+' END AS grouping_value,
  COUNT(*) AS dispute_count,
  COUNT(DISTINCT d.transaction_id) AS disputed_transaction_count,
  ROUND(SUM(d.disputed_amount),2) AS disputed_value,
  SUM(d.status='OPEN') AS open_disputes,
  SUM(d.status='WON') AS won_disputes,
  SUM(d.status='LOST') AS lost_disputes,
  SUM(d.status='REFUNDED') AS refunded_disputes,
  ROUND(AVG(DATEDIFF(CURDATE(),DATE(d.opened_at))),1) AS average_days_since_opened
FROM disputes d JOIN transactions t ON t.transaction_id=d.transaction_id JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id LEFT JOIN merchants m ON m.merchant_id=t.merchant_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
