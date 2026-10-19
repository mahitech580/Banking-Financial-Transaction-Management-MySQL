-- transaction dispute resolution grouped by days since opened band; read-only analysis over the banking demo schema.
SELECT CASE WHEN DATEDIFF(CURDATE(),DATE(d.opened_at))<=7 THEN '0-7 days' WHEN DATEDIFF(CURDATE(),DATE(d.opened_at))<=30 THEN '8-30 days' WHEN DATEDIFF(CURDATE(),DATE(d.opened_at))<=90 THEN '31-90 days' ELSE 'Over 90 days' END AS grouping_value,
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
