-- customer cohort transaction activity grouped by customer signup cohort; read-only analysis over the banking demo schema.
SELECT DATE_FORMAT(c.customer_since,'%Y-%m') AS grouping_value,
  COUNT(DISTINCT c.customer_id) AS active_customers,
  COUNT(DISTINCT CASE WHEN t.status='SUCCESS' THEN c.customer_id END) AS successful_customers,
  COUNT(*) AS transaction_attempts,
  ROUND(SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END),2) AS successful_value,
  COUNT(DISTINCT DATE(t.transaction_time)) AS active_calendar_days,
  COUNT(DISTINCT CASE WHEN DATE(t.transaction_time)>c.customer_since THEN c.customer_id END) AS customers_active_after_signup_day,
  ROUND(AVG(t.amount),2) AS average_ticket
FROM transactions t JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id LEFT JOIN branches b ON b.branch_id=a.branch_id
GROUP BY 1
ORDER BY 2 DESC;
