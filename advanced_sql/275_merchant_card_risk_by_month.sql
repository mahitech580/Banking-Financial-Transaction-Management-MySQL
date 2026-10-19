-- merchant card activity and risk grouped by card transaction month; read-only analysis over the banking demo schema.
SELECT DATE_FORMAT(ct.transaction_time,'%Y-%m') AS grouping_value,
  COUNT(*) AS card_transaction_count,
  COUNT(DISTINCT ca.card_id) AS cards_used,
  COUNT(DISTINCT c.customer_id) AS distinct_cardholders,
  SUM(ct.status='FAILED') AS failed_attempts,
  ROUND(SUM(CASE WHEN ct.status='FAILED' THEN ct.amount ELSE 0 END),2) AS failed_attempt_value,
  ROUND(SUM(CASE WHEN ct.status='SUCCESS' THEN ct.amount ELSE 0 END),2) AS successful_spend,
  SUM(m.risk_level='HIGH') AS high_risk_merchant_events
FROM card_transactions ct JOIN cards ca ON ca.card_id=ct.card_id JOIN customers c ON c.customer_id=ca.customer_id JOIN merchants m ON m.merchant_id=ct.merchant_id JOIN accounts a ON a.account_id=ca.account_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
