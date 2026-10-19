-- card inventory and exposure grouped by credit limit band; read-only analysis over the banking demo schema.
SELECT CASE WHEN ca.credit_limit=0 THEN 'Zero' WHEN ca.credit_limit<10000 THEN 'Under 10k' WHEN ca.credit_limit<100000 THEN '10k-99999' ELSE '100k+' END AS grouping_value,
  COUNT(*) AS card_count,
  COUNT(DISTINCT ca.customer_id) AS cardholders,
  SUM(ca.status='ACTIVE') AS active_cards,
  SUM(ca.status='BLOCKED') AS blocked_cards,
  SUM(ca.status='EXPIRED') AS expired_cards,
  ROUND(SUM(ca.credit_limit),2) AS total_credit_limit,
  ROUND(AVG(ca.credit_limit),2) AS average_credit_limit
FROM cards ca JOIN customers c ON c.customer_id=ca.customer_id JOIN accounts a ON a.account_id=ca.account_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
