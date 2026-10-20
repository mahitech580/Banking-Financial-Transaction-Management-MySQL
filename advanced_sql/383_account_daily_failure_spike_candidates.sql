-- Business question: Which account-days have failure counts unusually high relative to the account's prior observed daily history?
-- Grain: one account-day candidate. The threshold uses up to 30 prior observed account-days and excludes the candidate day itself.
-- The two-standard-deviation rule is a screening heuristic; it can be unstable when only a few baseline days exist.
WITH daily_attempts AS (
  SELECT account_id, DATE(transaction_time) AS activity_date, COUNT(*) AS attempt_count,
    SUM(status = 'FAILED') AS failed_attempts
  FROM transactions
  GROUP BY account_id, DATE(transaction_time)
),
baseline AS (
  SELECT da.*,
    AVG(failed_attempts) OVER (
      PARTITION BY account_id ORDER BY activity_date
      ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
    ) AS prior_average_daily_failures,
    STDDEV_POP(failed_attempts) OVER (
      PARTITION BY account_id ORDER BY activity_date
      ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
    ) AS prior_daily_failure_stddev,
    COUNT(*) OVER (
      PARTITION BY account_id ORDER BY activity_date
      ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
    ) AS prior_observed_days
  FROM daily_attempts da
)
SELECT account_id, activity_date, attempt_count, failed_attempts, prior_observed_days,
  ROUND(prior_average_daily_failures, 2) AS prior_average_daily_failures,
  ROUND(prior_daily_failure_stddev, 2) AS prior_daily_failure_stddev,
  ROUND(prior_average_daily_failures + 2 * prior_daily_failure_stddev, 2) AS review_threshold
FROM baseline
WHERE prior_observed_days >= 3
  AND failed_attempts >= 2
  AND failed_attempts > prior_average_daily_failures + 2 * prior_daily_failure_stddev
ORDER BY failed_attempts DESC, account_id, activity_date DESC;
