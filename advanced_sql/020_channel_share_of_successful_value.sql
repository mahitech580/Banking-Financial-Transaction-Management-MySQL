-- Business question: What percentage of successful transaction value belongs to each channel?
WITH channel_totals AS (
  SELECT channel, SUM(amount) AS value
  FROM transactions
  WHERE status = 'SUCCESS'
  GROUP BY channel
)
SELECT channel, value,
       ROUND(100 * value / NULLIF(SUM(value) OVER (), 0), 2) AS pct_of_successful_value
FROM channel_totals
ORDER BY value DESC;