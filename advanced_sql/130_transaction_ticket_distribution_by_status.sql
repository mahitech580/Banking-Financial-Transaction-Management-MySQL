-- transaction ticket distribution grouped by transaction status; read-only analysis over the banking demo schema.
SELECT t.status AS grouping_value,
  COUNT(*) AS transaction_count,
  ROUND(MIN(t.amount),2) AS minimum_ticket,
  ROUND(AVG(t.amount),2) AS average_ticket,
  ROUND(MAX(t.amount),2) AS maximum_ticket,
  ROUND(STDDEV_POP(t.amount),2) AS ticket_stddev,
  ROUND(SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END),2) AS successful_value,
  SUM(t.amount>=10000) AS tickets_at_least_10000
FROM transactions t JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id LEFT JOIN branches b ON b.branch_id=a.branch_id LEFT JOIN merchants m ON m.merchant_id=t.merchant_id
GROUP BY 1
ORDER BY 2 DESC;
