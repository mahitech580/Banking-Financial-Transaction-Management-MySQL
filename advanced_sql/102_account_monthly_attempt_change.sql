-- Business question: How does account transaction-attempt volume change between observed months?
WITH monthly AS (
  SELECT account_id,DATE_FORMAT(transaction_time,'%Y-%m-01') month_start,COUNT(*) attempts,
         SUM(status='SUCCESS') successes,SUM(status='FAILED') failures
  FROM transactions GROUP BY account_id,DATE_FORMAT(transaction_time,'%Y-%m-01')
)
SELECT account_id,month_start,attempts,successes,failures,
       LAG(attempts) OVER(PARTITION BY account_id ORDER BY month_start) prior_month_attempts,
       attempts-LAG(attempts) OVER(PARTITION BY account_id ORDER BY month_start) attempt_change
FROM monthly ORDER BY account_id,month_start;