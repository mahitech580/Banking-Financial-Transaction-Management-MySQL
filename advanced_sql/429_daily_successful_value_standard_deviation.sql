-- Business question: Compare daily successful transaction value with the average day for each channel.
WITH daily_channel AS (
  SELECT channel, DATE(transaction_time) AS activity_day,
         COUNT(*) AS successful_count, SUM(amount) AS successful_value
  FROM transactions
  WHERE status = 'SUCCESS'
  GROUP BY channel, DATE(transaction_time)
)
SELECT channel, activity_day, successful_count, successful_value,
       ROUND(AVG(successful_value) OVER (PARTITION BY channel), 2) AS channel_daily_average,
       ROUND(successful_value - AVG(successful_value) OVER (PARTITION BY channel), 2) AS difference_from_average,
       RANK() OVER (PARTITION BY channel ORDER BY successful_value DESC) AS value_rank
FROM daily_channel
ORDER BY activity_day DESC, channel;
