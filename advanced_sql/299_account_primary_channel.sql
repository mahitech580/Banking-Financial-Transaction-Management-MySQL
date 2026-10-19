-- Business question: What is each account's most-used channel and how concentrated is its attempt volume?
WITH channel_counts AS (
  SELECT account_id,channel,COUNT(*) attempts,SUM(status='SUCCESS') successes,
         SUM(status='FAILED') failures
  FROM transactions GROUP BY account_id,channel
),
ranked AS (
  SELECT account_id,channel,attempts,successes,failures,
         ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY attempts DESC,channel) channel_rank,
         SUM(attempts) OVER(PARTITION BY account_id) total_attempts
  FROM channel_counts
)
SELECT account_id,channel primary_channel,attempts primary_channel_attempts,total_attempts,
       ROUND(100*attempts/NULLIF(total_attempts,0),2) primary_channel_share_pct,
       successes,failures,ROUND(100*successes/NULLIF(attempts,0),2) channel_success_rate_pct
FROM ranked WHERE channel_rank=1
ORDER BY primary_channel_share_pct DESC,account_id;