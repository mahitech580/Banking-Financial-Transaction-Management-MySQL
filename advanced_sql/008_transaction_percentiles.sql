-- Business question: How do successful transaction amounts compare by percentile?
WITH distribution AS (
  SELECT amount,
         CUME_DIST() OVER (ORDER BY amount) AS cumulative_distribution
  FROM transactions
  WHERE status = 'SUCCESS'
)
SELECT MIN(CASE WHEN cumulative_distribution >= 0.50 THEN amount END) AS p50_amount,
       MIN(CASE WHEN cumulative_distribution >= 0.90 THEN amount END) AS p90_amount,
       MIN(CASE WHEN cumulative_distribution >= 0.95 THEN amount END) AS p95_amount,
       MAX(amount) AS maximum_amount
FROM distribution;