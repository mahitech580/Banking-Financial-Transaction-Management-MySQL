-- Business question: Which customers change their most-used successful transaction channel between consecutive active months?
-- Grain: one customer-month with a dominant channel and prior active-month dominant channel; ties are resolved alphabetically.
WITH monthly_channel_counts AS (
  SELECT a.customer_id, DATE_FORMAT(t.transaction_time, '%Y-%m-01') AS activity_month,
    t.channel, COUNT(*) AS successful_count
  FROM accounts a JOIN transactions t ON t.account_id = a.account_id
  WHERE t.status = 'SUCCESS'
  GROUP BY a.customer_id, DATE_FORMAT(t.transaction_time, '%Y-%m-01'), t.channel
),
ranked_channels AS (
  SELECT mcc.*,
    ROW_NUMBER() OVER (PARTITION BY customer_id, activity_month
      ORDER BY successful_count DESC, channel) AS channel_rank
  FROM monthly_channel_counts mcc
),
dominant_channel AS (
  SELECT customer_id, activity_month, channel AS dominant_channel, successful_count
  FROM ranked_channels WHERE channel_rank = 1
),
channel_changes AS (
  SELECT dc.*,
    LAG(dominant_channel) OVER (PARTITION BY customer_id ORDER BY activity_month) AS previous_active_month_channel
  FROM dominant_channel dc
)
SELECT customer_id, activity_month, previous_active_month_channel, dominant_channel,
  successful_count AS successful_transactions_in_dominant_channel,
  CASE WHEN previous_active_month_channel IS NULL THEN 'FIRST_ACTIVE_MONTH'
    WHEN previous_active_month_channel = dominant_channel THEN 'SAME_DOMINANT_CHANNEL'
    ELSE 'DOMINANT_CHANNEL_CHANGED' END AS channel_shift
FROM channel_changes
ORDER BY activity_month DESC, customer_id;
