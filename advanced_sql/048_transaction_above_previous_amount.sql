-- Business question: Which successful transactions are larger than the previous successful transaction on the same account?
WITH sequence AS (
  SELECT account_id, transaction_id, reference_code, transaction_time, amount,
         LAG(amount) OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS previous_amount
  FROM transactions
  WHERE status = 'SUCCESS'
)
SELECT account_id, reference_code, transaction_time, amount, previous_amount,
       amount - previous_amount AS amount_increase
FROM sequence
WHERE previous_amount IS NOT NULL AND amount > previous_amount
ORDER BY amount_increase DESC;