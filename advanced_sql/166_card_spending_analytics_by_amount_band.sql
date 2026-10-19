-- card spending analytics grouped by card amount band; read-only analysis over the banking demo schema.
SELECT CASE WHEN ct.amount<500 THEN 'Under 500' WHEN ct.amount<5000 THEN '500-4999' WHEN ct.amount<50000 THEN '5000-49999' ELSE '50000+' END AS grouping_value,
  COUNT(*) AS card_attempts,
  COUNT(DISTINCT ca.card_id) AS distinct_cards,
  SUM(ct.status='SUCCESS') AS successful_attempts,
  SUM(ct.status='FAILED') AS failed_attempts,
  ROUND(SUM(CASE WHEN ct.status='SUCCESS' THEN ct.amount ELSE 0 END),2) AS successful_spend,
  ROUND(100*SUM(ct.status='SUCCESS')/NULLIF(COUNT(*),0),2) AS success_rate_pct,
  ROUND(AVG(ct.amount),2) AS average_ticket
FROM card_transactions ct JOIN cards ca ON ca.card_id=ct.card_id JOIN customers c ON c.customer_id=ca.customer_id JOIN accounts a ON a.account_id=ca.account_id JOIN merchants m ON m.merchant_id=ct.merchant_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
