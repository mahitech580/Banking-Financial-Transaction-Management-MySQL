-- Business question: Do transaction attempt outcomes vary between weekdays and weekends?
-- Grain: one row per weekday/weekend segment and channel; this is a descriptive comparison, not a causal explanation.
SELECT
  CASE WHEN DAYOFWEEK(transaction_time) IN (1, 7) THEN 'WEEKEND' ELSE 'WEEKDAY' END AS day_segment,
  channel,
  COUNT(*) AS attempt_count,
  SUM(status = 'SUCCESS') AS successful_count,
  SUM(status = 'FAILED') AS failed_count,
  SUM(status = 'PENDING') AS pending_count,
  SUM(status = 'REVERSED') AS reversed_count,
  ROUND(100.0 * SUM(status = 'SUCCESS') / NULLIF(COUNT(*), 0), 2) AS success_rate_pct,
  COALESCE(SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END), 0.00)
    AS successful_gross_value
FROM transactions
GROUP BY day_segment, channel
ORDER BY day_segment, channel;
