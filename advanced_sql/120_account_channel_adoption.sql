-- Business question: How many distinct channels does each account use, and which is its most frequent channel?
WITH channel_counts AS (
  SELECT account_id,channel,COUNT(*) attempts,SUM(status='SUCCESS') successes
  FROM transactions GROUP BY account_id,channel
),
ranked AS (
  SELECT account_id,channel,attempts,successes,
         DENSE_RANK() OVER(PARTITION BY account_id ORDER BY attempts DESC,channel) channel_rank
  FROM channel_counts
),
adoption AS (
  SELECT account_id,COUNT(DISTINCT channel) channel_count FROM transactions GROUP BY account_id
)
SELECT a.account_id,a.account_number,COALESCE(ad.channel_count,0) distinct_channels,
       r.channel most_used_channel,r.attempts attempts_on_most_used_channel,r.successes successes_on_most_used_channel
FROM accounts a LEFT JOIN adoption ad ON ad.account_id=a.account_id
LEFT JOIN ranked r ON r.account_id=a.account_id AND r.channel_rank=1
ORDER BY distinct_channels DESC,a.account_id;