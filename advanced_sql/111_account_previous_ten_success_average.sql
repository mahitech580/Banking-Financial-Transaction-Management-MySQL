-- Business question: Compare each successful transaction with the mean of up to ten prior successful transactions on that account.
WITH sequenced AS (
  SELECT account_id,transaction_id,transaction_time,amount,
         AVG(amount) OVER(PARTITION BY account_id ORDER BY transaction_time,transaction_id
           ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) previous_ten_mean,
         COUNT(*) OVER(PARTITION BY account_id ORDER BY transaction_time,transaction_id
           ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) prior_count
  FROM transactions WHERE status='SUCCESS'
)
SELECT account_id,transaction_id,transaction_time,amount,prior_count,
       ROUND(previous_ten_mean,2) previous_ten_mean,
       ROUND(amount-previous_ten_mean,2) difference_from_prior_mean,
       ROUND(100*(amount-previous_ten_mean)/NULLIF(previous_ten_mean,0),2) pct_difference
FROM sequenced WHERE prior_count>0
ORDER BY ABS(amount-previous_ten_mean) DESC LIMIT 200;