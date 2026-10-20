-- Business question: Compare account performance bands based on successful transaction value.
WITH account_value AS (
  SELECT a.account_id, a.account_number, a.account_type, a.status,
         COALESCE(SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END), 0) AS successful_value,
         COUNT(CASE WHEN t.status = 'SUCCESS' THEN 1 END) AS successful_count
  FROM accounts AS a
  LEFT JOIN transactions AS t ON t.account_id = a.account_id
  GROUP BY a.account_id, a.account_number, a.account_type, a.status
), ranked AS (
  SELECT account_value.*,
         NTILE(4) OVER (ORDER BY successful_value DESC, account_id) AS value_quartile
  FROM account_value
)
SELECT value_quartile, account_type,
       COUNT(*) AS account_count,
       SUM(successful_value) AS successful_value,
       SUM(successful_count) AS successful_transaction_count,
       ROUND(AVG(successful_value), 2) AS average_account_value
FROM ranked
GROUP BY value_quartile, account_type
ORDER BY value_quartile, account_type;
