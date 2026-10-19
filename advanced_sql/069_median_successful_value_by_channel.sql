-- Business question: What is the median successful transaction amount by channel?
-- The row-number method averages the two middle values for even-sized groups.
WITH ranked AS (
  SELECT channel, amount,
         ROW_NUMBER() OVER (PARTITION BY channel ORDER BY amount, transaction_id) AS rn,
         COUNT(*) OVER (PARTITION BY channel) AS n
  FROM transactions
  WHERE status = 'SUCCESS'
)
SELECT channel, MAX(n) AS successful_rows,
       AVG(CASE WHEN rn IN (FLOOR((n + 1) / 2), FLOOR((n + 2) / 2)) THEN amount END) AS median_successful_amount
FROM ranked
GROUP BY channel
ORDER BY median_successful_amount DESC;
