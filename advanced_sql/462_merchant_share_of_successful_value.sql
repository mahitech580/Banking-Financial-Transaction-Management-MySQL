-- Business question: Rank merchants by their share of successful ledger transaction value.
WITH merchant_values AS (
  SELECT m.merchant_id, m.merchant_name, m.merchant_category,
         SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value
  FROM merchants AS m
  LEFT JOIN transactions AS t ON t.merchant_id = m.merchant_id
  GROUP BY m.merchant_id, m.merchant_name, m.merchant_category
)
SELECT merchant_id, merchant_name, merchant_category, successful_value,
       SUM(successful_value) OVER () AS all_merchant_successful_value,
       ROUND(100.0 * successful_value / NULLIF(SUM(successful_value) OVER (), 0), 2) AS value_share_pct,
       RANK() OVER (ORDER BY successful_value DESC) AS value_rank
FROM merchant_values
ORDER BY value_rank, merchant_name;
