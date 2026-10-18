-- Business question: What is the median successful transaction amount?
WITH ranked AS (
  SELECT amount,
         ROW_NUMBER() OVER (ORDER BY amount) AS rn,
         COUNT(*) OVER () AS n
  FROM transactions
  WHERE status = 'SUCCESS'
)
SELECT AVG(amount) AS median_successful_amount
FROM ranked
WHERE rn IN (FLOOR((n + 1) / 2), FLOOR((n + 2) / 2));