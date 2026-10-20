-- Business question: View daily transaction outcomes and cumulative successful value.
WITH daily AS (
  SELECT DATE(transaction_time) AS activity_day,
         COUNT(*) AS attempts,
         SUM(status = 'SUCCESS') AS successes,
         SUM(status = 'FAILED') AS failures,
         SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
  FROM transactions
  GROUP BY DATE(transaction_time)
)
SELECT activity_day, attempts, successes, failures, successful_value,
       SUM(successful_value) OVER (ORDER BY activity_day ROWS UNBOUNDED PRECEDING) AS cumulative_successful_value,
       ROUND(100.0 * successes / NULLIF(attempts, 0), 2) AS success_rate_pct
FROM daily
ORDER BY activity_day;
