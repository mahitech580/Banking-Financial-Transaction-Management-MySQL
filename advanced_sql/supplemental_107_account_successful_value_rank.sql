-- Business question: Rank accounts by successful transaction value and quantify relative concentration.
WITH totals AS (
  SELECT a.account_id,a.account_number,a.customer_id,
         SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END) successful_value,
         SUM(t.status='SUCCESS') successful_count
  FROM accounts a LEFT JOIN transactions t ON t.account_id=a.account_id
  GROUP BY a.account_id,a.account_number,a.customer_id
)
SELECT account_id,account_number,customer_id,successful_count,ROUND(successful_value,2) successful_value,
       DENSE_RANK() OVER(ORDER BY successful_value DESC) value_rank,
       ROUND(100*CUME_DIST() OVER(ORDER BY successful_value DESC),2) cumulative_distribution_pct
FROM totals ORDER BY successful_value DESC,account_id;