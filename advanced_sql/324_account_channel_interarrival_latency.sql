-- Business question: How much time typically passes between attempts on the same account and channel?
WITH gaps AS (
  SELECT account_id,channel,transaction_id,transaction_time,
         LAG(transaction_time) OVER(PARTITION BY account_id,channel ORDER BY transaction_time,transaction_id) previous_time
  FROM transactions
)
SELECT channel,COUNT(*) observed_interarrival_gaps,
       ROUND(AVG(TIMESTAMPDIFF(SECOND,previous_time,transaction_time)),2) average_gap_seconds,
       MIN(TIMESTAMPDIFF(SECOND,previous_time,transaction_time)) minimum_gap_seconds,
       MAX(TIMESTAMPDIFF(SECOND,previous_time,transaction_time)) maximum_gap_seconds,
       SUM(TIMESTAMPDIFF(SECOND,previous_time,transaction_time)<=60) gaps_under_one_minute,
       SUM(TIMESTAMPDIFF(SECOND,previous_time,transaction_time)<=300) gaps_under_five_minutes
FROM gaps WHERE previous_time IS NOT NULL
GROUP BY channel ORDER BY average_gap_seconds;