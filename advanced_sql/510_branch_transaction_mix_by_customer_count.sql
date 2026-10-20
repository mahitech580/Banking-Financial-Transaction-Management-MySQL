-- Business question: Normalize branch transaction attempt and successful value measures by customers represented.
WITH customer_counts AS (
  SELECT branch_id, COUNT(DISTINCT customer_id) AS customers
  FROM accounts
  GROUP BY branch_id
), branch_activity AS (
  SELECT a.branch_id, COUNT(*) AS attempts,
         SUM(t.status = 'SUCCESS') AS successes,
         SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value
  FROM accounts AS a
  JOIN transactions AS t ON t.account_id = a.account_id
  GROUP BY a.branch_id
)
SELECT b.branch_name, COALESCE(cc.customers, 0) AS customers,
       COALESCE(ba.attempts, 0) AS attempts,
       COALESCE(ba.successes, 0) AS successes,
       COALESCE(ba.successful_value, 0) AS successful_value,
       ROUND(ba.attempts / NULLIF(cc.customers, 0), 2) AS attempts_per_customer,
       ROUND(ba.successful_value / NULLIF(cc.customers, 0), 2) AS successful_value_per_customer
FROM branches AS b
LEFT JOIN customer_counts AS cc ON cc.branch_id = b.branch_id
LEFT JOIN branch_activity AS ba ON ba.branch_id = b.branch_id
ORDER BY successful_value_per_customer DESC;
