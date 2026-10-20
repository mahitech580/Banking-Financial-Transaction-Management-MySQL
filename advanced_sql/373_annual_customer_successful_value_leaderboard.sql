-- Business question: Which customers account for the largest share of successful gross transaction value each year?
-- Grain: one customer/year. This measures transaction amount, not profit, net cash flow, or customer value after costs.
WITH annual_customer_value AS (
  SELECT a.customer_id, YEAR(t.transaction_time) AS transaction_year,
    COUNT(*) AS successful_transactions, SUM(t.amount) AS successful_gross_value
  FROM accounts a JOIN transactions t ON t.account_id = a.account_id
  WHERE t.status = 'SUCCESS'
  GROUP BY a.customer_id, YEAR(t.transaction_time)
),
ranked AS (
  SELECT acv.*,
    DENSE_RANK() OVER (PARTITION BY transaction_year ORDER BY successful_gross_value DESC) AS value_rank,
    SUM(successful_gross_value) OVER (PARTITION BY transaction_year) AS annual_total_value
  FROM annual_customer_value acv
)
SELECT transaction_year, value_rank, customer_id, successful_transactions, successful_gross_value,
  ROUND(100.0 * successful_gross_value / NULLIF(annual_total_value, 0), 2) AS annual_value_share_pct,
  annual_total_value
FROM ranked
WHERE value_rank <= 20
ORDER BY transaction_year DESC, value_rank, customer_id;
