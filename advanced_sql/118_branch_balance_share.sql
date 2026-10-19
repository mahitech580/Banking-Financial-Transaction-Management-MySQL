-- Business question: What share of stored account balance belongs to each branch?
WITH branch_balances AS (
  SELECT b.branch_id,b.branch_code,b.branch_name,
         COUNT(a.account_id) account_count,
         SUM(a.current_balance) branch_balance
  FROM branches b LEFT JOIN accounts a ON a.branch_id=b.branch_id
  GROUP BY b.branch_id,b.branch_code,b.branch_name
)
SELECT branch_id,branch_code,branch_name,account_count,ROUND(branch_balance,2) branch_balance,
       ROUND(100*branch_balance/NULLIF(SUM(branch_balance) OVER(),0),2) portfolio_balance_share_pct
FROM branch_balances ORDER BY branch_balance DESC,branch_id;