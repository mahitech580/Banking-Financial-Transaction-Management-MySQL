-- Business question: How did successful transaction value change from month to month?
WITH monthly AS (
  SELECT DATE_FORMAT(transaction_time, '%Y-%m') AS month,
         SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS value
  FROM transactions
  GROUP BY DATE_FORMAT(transaction_time, '%Y-%m')
), compared AS (
  SELECT month, value, LAG(value) OVER (ORDER BY month) AS previous_value
  FROM monthly
)
SELECT month, value, previous_value,
       value - previous_value AS absolute_change,
       ROUND(100 * (value - previous_value) / NULLIF(previous_value, 0), 2) AS pct_change
FROM compared
ORDER BY month;