-- Business question: What share of each channel's successful financial flow comes from its largest transaction?
WITH totals AS (
  SELECT channel,COUNT(*) successful_transactions,SUM(amount) channel_successful_value,
         MAX(amount) largest_successful_transaction
  FROM transactions WHERE status='SUCCESS' GROUP BY channel
)
SELECT channel,successful_transactions,ROUND(channel_successful_value,2) channel_successful_value,
       ROUND(largest_successful_transaction,2) largest_transaction,
       ROUND(100*largest_successful_transaction/NULLIF(channel_successful_value,0),2) largest_transaction_share_pct,
       ROUND(channel_successful_value/NULLIF(successful_transactions,0),2) average_successful_amount
FROM totals ORDER BY largest_transaction_share_pct DESC;