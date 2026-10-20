-- Business question: Within each calendar month, how much of a customer's successful gross value came from their largest transaction?
-- Grain: one customer-month. This concentration metric is descriptive and does not indicate whether the amount was appropriate.
WITH monthly_success AS (
  SELECT a.customer_id, DATE_FORMAT(t.transaction_time, '%Y-%m-01') AS transaction_month,
    COUNT(*) AS successful_count, SUM(t.amount) AS successful_gross_value,
    MAX(t.amount) AS largest_successful_transaction
  FROM accounts a JOIN transactions t ON t.account_id = a.account_id
  WHERE t.status = 'SUCCESS'
  GROUP BY a.customer_id, DATE_FORMAT(t.transaction_time, '%Y-%m-01')
)
SELECT customer_id, transaction_month, successful_count, successful_gross_value,
  largest_successful_transaction,
  ROUND(100.0 * largest_successful_transaction / NULLIF(successful_gross_value, 0), 2)
    AS largest_transaction_share_pct,
  CASE WHEN successful_count = 1 THEN 'SINGLE_SUCCESSFUL_TRANSACTION'
    WHEN largest_successful_transaction / NULLIF(successful_gross_value, 0) >= 0.80 THEN 'HIGH_CONCENTRATION'
    WHEN largest_successful_transaction / NULLIF(successful_gross_value, 0) >= 0.50 THEN 'MODERATE_CONCENTRATION'
    ELSE 'DISTRIBUTED_VALUE' END AS value_concentration_band
FROM monthly_success
ORDER BY transaction_month DESC, largest_transaction_share_pct DESC, customer_id;
