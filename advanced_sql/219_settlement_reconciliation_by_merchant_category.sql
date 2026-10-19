-- payment settlement reconciliation grouped by merchant category; read-only analysis over the banking demo schema.
SELECT COALESCE(m.merchant_category,'No merchant') AS grouping_value,
  COUNT(*) AS settlement_record_count,
  COUNT(DISTINCT s.transaction_id) AS distinct_transactions,
  ROUND(SUM(s.settlement_amount),2) AS settlement_value,
  SUM(s.status='SETTLED') AS settled_count,
  SUM(s.status='PENDING') AS pending_count,
  SUM(s.status='FAILED') AS failed_count,
  ROUND(AVG(CASE WHEN s.settled_at IS NOT NULL THEN TIMESTAMPDIFF(HOUR,t.transaction_time,s.settled_at) END),2) AS average_settlement_lag_hours,
  ROUND(SUM(ABS(s.settlement_amount-t.amount)),2) AS aggregate_record_value_difference
FROM settlements s JOIN transactions t ON t.transaction_id=s.transaction_id JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id LEFT JOIN merchants m ON m.merchant_id=t.merchant_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
