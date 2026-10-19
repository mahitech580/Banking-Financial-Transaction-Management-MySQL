-- Business question: How many transaction channels and successful channel-days does each customer use?
WITH customer_channels AS (
  SELECT a.customer_id,COUNT(DISTINCT t.channel) distinct_channels,
         COUNT(*) transaction_attempts,SUM(t.status='SUCCESS') successful_attempts,
         COUNT(DISTINCT CASE WHEN t.status='SUCCESS' THEN CONCAT(t.channel,':',DATE(t.transaction_time)) END) successful_channel_days
  FROM accounts a JOIN transactions t ON t.account_id=a.account_id
  GROUP BY a.customer_id
)
SELECT c.customer_id,c.customer_number,c.risk_level,cc.distinct_channels,
       cc.transaction_attempts,cc.successful_attempts,cc.successful_channel_days,
       ROUND(100*cc.successful_attempts/NULLIF(cc.transaction_attempts,0),2) overall_success_rate_pct
FROM customer_channels cc JOIN customers c ON c.customer_id=cc.customer_id
ORDER BY distinct_channels DESC,successful_channel_days DESC,c.customer_id;