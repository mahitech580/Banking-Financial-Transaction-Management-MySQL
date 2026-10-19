-- Business question: Flag successful transaction amounts more than three population standard deviations above channel mean.
-- This is a statistical review candidate; small or skewed samples can yield misleading signals.
WITH channel_stats AS (
  SELECT channel,COUNT(*) sample_size,AVG(amount) mean_amount,STDDEV_POP(amount) amount_sd
  FROM transactions WHERE status='SUCCESS' GROUP BY channel
)
SELECT t.transaction_id,t.reference_code,t.channel,t.amount,t.transaction_time,
       ROUND(s.mean_amount,2) channel_mean_amount,ROUND(s.amount_sd,2) channel_stddev_amount,
       s.sample_size,
       ROUND((t.amount-s.mean_amount)/NULLIF(s.amount_sd,0),2) standard_deviations_above_mean
FROM transactions t JOIN channel_stats s ON s.channel=t.channel
WHERE t.status='SUCCESS' AND s.sample_size>=5 AND s.amount_sd>0
  AND t.amount>s.mean_amount+3*s.amount_sd
ORDER BY standard_deviations_above_mean DESC;