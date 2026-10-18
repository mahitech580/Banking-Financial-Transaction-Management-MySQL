-- Business question: How much did a transaction amount change from the previous one for the same account?
WITH sequence AS (
  SELECT account_id, transaction_id, transaction_time, amount,
         LAG(amount) OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS previous_amount
  FROM transactions
)
SELECT account_id, transaction_id, transaction_time, amount, previous_amount,
       ROUND(100 * (amount - previous_amount) / NULLIF(previous_amount, 0), 2) AS pct_change
FROM sequence
WHERE previous_amount IS NOT NULL
ORDER BY ABS((amount - previous_amount) / NULLIF(previous_amount, 0)) DESC;