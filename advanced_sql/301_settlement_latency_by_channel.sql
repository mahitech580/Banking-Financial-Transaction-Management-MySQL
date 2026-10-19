-- Business question: What are median and approximate 90th-percentile settlement delays by channel?
WITH latency AS (
  SELECT t.channel,s.settlement_id,TIMESTAMPDIFF(MINUTE,t.transaction_time,s.settled_at) delay_minutes
  FROM settlements s JOIN transactions t ON t.transaction_id=s.transaction_id
  WHERE s.status='SETTLED' AND s.settled_at IS NOT NULL
),
ranked AS (
  SELECT channel,delay_minutes,
         ROW_NUMBER() OVER(PARTITION BY channel ORDER BY delay_minutes,settlement_id) row_num,
         COUNT(*) OVER(PARTITION BY channel) sample_size
  FROM latency
)
SELECT channel,COUNT(*) settled_records,
       ROUND(AVG(delay_minutes),2) average_delay_minutes,
       ROUND(AVG(CASE WHEN row_num IN (FLOOR((sample_size+1)/2),CEIL((sample_size+1)/2)) THEN delay_minutes END),2) median_delay_minutes,
       MIN(CASE WHEN row_num>=CEIL(sample_size*0.9) THEN delay_minutes END) approximate_p90_delay_minutes,
       MAX(delay_minutes) maximum_delay_minutes
FROM ranked GROUP BY channel ORDER BY approximate_p90_delay_minutes DESC;