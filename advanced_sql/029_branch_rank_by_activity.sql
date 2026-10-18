-- Business question: How do branches rank by successful transaction value?
WITH branch_values AS (
  SELECT b.branch_id, b.branch_name,
         COALESCE(SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END), 0) AS value
  FROM branches b
  LEFT JOIN accounts a ON a.branch_id = b.branch_id
  LEFT JOIN transactions t ON t.account_id = a.account_id
  GROUP BY b.branch_id, b.branch_name
)
SELECT branch_id, branch_name, value,
       DENSE_RANK() OVER (ORDER BY value DESC) AS activity_rank
FROM branch_values
ORDER BY activity_rank, branch_name;