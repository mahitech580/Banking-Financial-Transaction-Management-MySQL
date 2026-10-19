-- Business question: Which branch/channel combinations show changing transaction failure rates over time?
WITH monthly AS (
  SELECT a.branch_id,b.branch_name,t.channel,
         DATE_FORMAT(t.transaction_time,'%Y-%m-01') month_start,
         COUNT(*) attempts,SUM(t.status='FAILED') failures,SUM(t.status='SUCCESS') successes
  FROM transactions t JOIN accounts a ON a.account_id=t.account_id
  JOIN branches b ON b.branch_id=a.branch_id
  GROUP BY a.branch_id,b.branch_name,t.channel,DATE_FORMAT(t.transaction_time,'%Y-%m-01')
)
SELECT branch_id,branch_name,channel,month_start,attempts,failures,successes,
       ROUND(100*failures/NULLIF(attempts,0),2) failure_rate_pct,
       ROUND(100*successes/NULLIF(attempts,0),2) success_rate_pct,
       failures-LAG(failures) OVER(PARTITION BY branch_id,channel ORDER BY month_start) failure_count_change
FROM monthly ORDER BY branch_name,channel,month_start;