-- Business question: How concentrated are each customer's positive account balances in their largest account?
-- Only positive balances are used to make the concentration calculation interpretable.
WITH balances AS (
  SELECT customer_id,account_id,GREATEST(current_balance,0) positive_balance
  FROM accounts
),
shares AS (
  SELECT customer_id,account_id,positive_balance,
         SUM(positive_balance) OVER(PARTITION BY customer_id) customer_positive_balance,
         MAX(positive_balance) OVER(PARTITION BY customer_id) largest_positive_balance
  FROM balances
)
SELECT c.customer_id,c.customer_number,COUNT(s.account_id) account_count,
       ROUND(MAX(s.customer_positive_balance),2) total_positive_balance,
       ROUND(MAX(s.largest_positive_balance),2) largest_positive_account_balance,
       ROUND(100*MAX(s.largest_positive_balance)/NULLIF(MAX(s.customer_positive_balance),0),2) largest_account_share_pct,
       ROUND(SUM(POW(s.positive_balance/NULLIF(s.customer_positive_balance,0),2)),4) positive_balance_hhi
FROM customers c JOIN shares s ON s.customer_id=c.customer_id
GROUP BY c.customer_id,c.customer_number
ORDER BY positive_balance_hhi DESC,c.customer_id;