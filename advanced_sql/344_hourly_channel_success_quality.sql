-- Business question: At which hour/channel combinations do transaction outcomes differ?
-- Grain: one row per hour and channel. Small sample sizes should not be treated as stable service-level estimates.
SELECT
  HOUR(transaction_time) AS transaction_hour,
  channel,
  COUNT(*) AS attempt_count,
  SUM(status = 'SUCCESS') AS success_count,
  SUM(status = 'FAILED') AS failed_count,
  SUM(status = 'PENDING') AS pending_count,
  SUM(status = 'REVERSED') AS reversed_count,
  ROUND(100.0 * SUM(status = 'SUCCESS') / NULLIF(COUNT(*), 0), 2) AS success_rate_pct,
  ROUND(AVG(TIMESTAMPDIFF(SECOND, DATE(transaction_time), transaction_time)), 1)
    AS average_second_of_day
FROM transactions
GROUP BY HOUR(transaction_time), channel
ORDER BY transaction_hour, channel;
