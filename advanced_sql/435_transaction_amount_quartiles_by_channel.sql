-- Business question: Compare transaction amount distributions across channels without mixing channel populations.
WITH amounts AS (
  SELECT channel, status, transaction_id, amount,
         NTILE(4) OVER (PARTITION BY channel ORDER BY amount, transaction_id) AS amount_quartile
  FROM transactions
)
SELECT channel, amount_quartile, status,
       COUNT(*) AS transaction_count,
       MIN(amount) AS minimum_amount,
       ROUND(AVG(amount), 2) AS average_amount,
       MAX(amount) AS maximum_amount,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
FROM amounts
GROUP BY channel, amount_quartile, status
ORDER BY channel, amount_quartile, status;
