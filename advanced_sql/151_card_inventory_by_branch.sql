-- card inventory and exposure grouped by account branch; read-only analysis over the banking demo schema.
SELECT b.branch_name AS grouping_value,
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
