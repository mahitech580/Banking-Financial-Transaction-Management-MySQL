-- Business question: Which customer-days have unusually high transaction-attempt volume against that customer's observed baseline?
-- Statistical flags are review candidates; small sample sizes can make these thresholds unstable.
WITH daily AS (
  SELECT a.customer_id,DATE(t.transaction_time) activity_date,COUNT(*) daily_attempts
  FROM accounts a JOIN transactions t ON t.account_id=a.account_id
  GROUP BY a.customer_id,DATE(t.transaction_time)
),
stats AS (
  SELECT customer_id,AVG(daily_attempts) mean_daily_attempts,
         STDDEV_POP(daily_attempts) sd_daily_attempts,COUNT(*) observed_days
  FROM daily GROUP BY customer_id
)
SELECT c.customer_id,c.customer_number,d.activity_date,d.daily_attempts,
       ROUND(s.mean_daily_attempts,2) mean_daily_attempts,
       ROUND(s.sd_daily_attempts,2) daily_attempts_stddev,s.observed_days
FROM daily d JOIN stats s ON s.customer_id=d.customer_id
JOIN customers c ON c.customer_id=d.customer_id
WHERE s.observed_days>=5 AND s.sd_daily_attempts>0
  AND d.daily_attempts>s.mean_daily_attempts+3*s.sd_daily_attempts
ORDER BY d.daily_attempts DESC,c.customer_id;