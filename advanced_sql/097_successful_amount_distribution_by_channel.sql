-- Business question: How are successful transaction amounts distributed across channel-specific deciles?
WITH ranked AS (
  SELECT transaction_id,channel,amount,
         NTILE(10) OVER(PARTITION BY channel ORDER BY amount,transaction_id) amount_decile
  FROM transactions WHERE status='SUCCESS'
)
SELECT channel,amount_decile,COUNT(*) transaction_count,MIN(amount) minimum_amount,
       MAX(amount) maximum_amount,ROUND(AVG(amount),2) average_amount
FROM ranked GROUP BY channel,amount_decile ORDER BY channel,amount_decile;