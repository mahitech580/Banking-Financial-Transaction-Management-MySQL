-- loan portfolio composition grouped by servicing branch; read-only analysis over the banking demo schema.
SELECT b.branch_name AS grouping_value,
  COUNT(*) AS loan_count,
  COUNT(DISTINCT l.customer_id) AS borrowers,
  ROUND(SUM(l.principal),2) AS originated_principal,
  ROUND(AVG(l.interest_rate),3) AS average_annual_rate_pct,
  ROUND(SUM(l.principal*l.interest_rate)/NULLIF(SUM(l.principal),0),3) AS principal_weighted_rate_pct,
  ROUND(AVG(l.tenure_months),1) AS average_tenure_months,
  ROUND(SUM(CASE WHEN l.status='DEFAULTED' THEN l.principal ELSE 0 END),2) AS defaulted_principal
FROM loans l JOIN customers c ON c.customer_id=l.customer_id JOIN accounts a ON a.account_id=l.account_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
