-- account balance profile grouped by customer age band; read-only analysis over the banking demo schema.
SELECT CASE WHEN TIMESTAMPDIFF(YEAR,c.date_of_birth,CURDATE())<25 THEN 'Under 25' WHEN TIMESTAMPDIFF(YEAR,c.date_of_birth,CURDATE())<35 THEN '25-34' WHEN TIMESTAMPDIFF(YEAR,c.date_of_birth,CURDATE())<50 THEN '35-49' ELSE '50+' END AS grouping_value,
  COUNT(*) AS account_count,
  COUNT(DISTINCT a.customer_id) AS account_holders,
  ROUND(SUM(a.current_balance),2) AS total_book_balance,
  ROUND(AVG(a.current_balance),2) AS average_balance,
  ROUND(MAX(a.current_balance),2) AS largest_account_balance,
  SUM(a.status='ACTIVE') AS active_accounts,
  SUM(a.current_balance=0) AS zero_balance_accounts
FROM accounts a JOIN customers c ON c.customer_id=a.customer_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
