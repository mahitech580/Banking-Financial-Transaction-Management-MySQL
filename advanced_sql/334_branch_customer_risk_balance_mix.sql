-- Business question: How does account balance and customer risk mix differ by branch?
WITH customer_balances AS (
  SELECT a.customer_id,a.branch_id,SUM(a.current_balance) customer_balance,COUNT(*) customer_accounts
  FROM accounts a GROUP BY a.customer_id,a.branch_id
)
SELECT b.branch_id,b.branch_name,c.risk_level,COUNT(DISTINCT c.customer_id) customers,
       SUM(cb.customer_accounts) accounts,ROUND(SUM(cb.customer_balance),2) stored_balance,
       ROUND(AVG(cb.customer_balance),2) average_balance_per_customer,
       SUM(cb.customer_balance<0) customers_with_negative_aggregate_balance
FROM branches b JOIN customer_balances cb ON cb.branch_id=b.branch_id
JOIN customers c ON c.customer_id=cb.customer_id
GROUP BY b.branch_id,b.branch_name,c.risk_level
ORDER BY b.branch_name,stored_balance DESC;