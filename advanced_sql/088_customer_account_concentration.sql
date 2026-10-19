-- Measure the largest account's share of each multi-account customer's stored balance.
WITH b AS (SELECT c.customer_id,c.customer_number,a.account_id,a.current_balance,
SUM(a.current_balance) OVER(PARTITION BY c.customer_id) customer_balance,
MAX(a.current_balance) OVER(PARTITION BY c.customer_id) largest_balance
FROM customers c JOIN accounts a ON a.customer_id=c.customer_id)
SELECT customer_id,customer_number,COUNT(*) account_count,ROUND(MAX(customer_balance),2) customer_balance,ROUND(MAX(largest_balance),2) largest_account_balance,
ROUND(100*MAX(largest_balance)/NULLIF(MAX(customer_balance),0),2) largest_account_share_pct
FROM b GROUP BY customer_id,customer_number HAVING COUNT(*)>1 ORDER BY largest_account_share_pct DESC;