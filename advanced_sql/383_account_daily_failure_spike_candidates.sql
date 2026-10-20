-- Business question: Which account-days have failure counts unusually high relative to the same account's observed daily history?
-- Grain: one account-day candidate. The two-standard-deviation flag is a screening heuristic and depends on sample size.
WITH daily_attempts AS (
  SELECT account_id, DATE(transaction_time) AS activity_date, COUNT(*) AS attempt_count,
    SUM(status = 'FAILED') AS failed_attempts
  FROM transactions
  GROUP BY account_id, DATE(transaction_time)
),
baseline AS (
  SELECT da.*,
    AVG(failed_attempts) OVER (PARTITION BY account_id) AS average_daily_failures,
    STDDEV_POP(failed_attempts) OVER (PARTITION BY account_id) AS daily_failure_stddev,
    COUNT(*) OVER (PARTITION BY account_id) AS observed_days
  FROM daily_attempts da
)
SELECT account_id, activity_date, attempt_count, failed_attempts, observed_days,
  ROUND(average_daily_failures, 2) AS average_daily_failures,
  ROUND(daily_failure_stddev, 2) AS daily_failure_stddev,
  ROUND(average_daily_failures + 2 * daily_failure_stddev, 2) AS review_threshold
FROM baseline
WHERE observed_days >= 3 AND failed_attempts >= 2
  AND failed_attempts > average_daily_failures + 2 * daily_failure_stddev
ORDER BY failed_attempts DESC, account_id, activity_date DESC;
