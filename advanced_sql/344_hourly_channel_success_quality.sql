-- Business question: At which hour/channel combinations do transaction outcomes differ?
-- Grain: one row per hour and channel. Small sample sizes should not be treated as stable service-level estimates.
SELECT
  HOUR(transaction_time) AS transaction_hour,
  channel,
  COUNT(*) AS attempt_count,
  COUNT(DISTINCT DATE(transaction_time)) AS observed_calendar_days,
  SUM(status = 'SUCCESS') AS success_count,
  SUM(status = 'FAILED') AS failed_count,
  SUM(status = 'PENDING') AS pending_count,
  SUM(status = 'REVERSED') AS reversed_count,
  ROUND(100.0 * SUM(status = 'SUCCESS') / NULLIF(COUNT(*), 0), 2) AS success_rate_pct,
  ROUND(AVG(amount), 2) AS average_attempt_amount,
  ROUND(AVG(CASE WHEN status = 'SUCCESS' THEN amount END), 2) AS average_successful_amount,
  COALESCE(SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END), 0.00)
    AS successful_gross_value,
  MAX(transaction_time) AS latest_attempt_at
FROM transactions
GROUP BY HOUR(transaction_time), channel
ORDER BY transaction_hour, channel;
