-- Business question: How much successful transaction value is associated with each customer risk level?
SELECT c.risk_level, COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(t.transaction_id) AS successful_transactions,
       SUM(t.amount) AS successful_value,
       AVG(t.amount) AS average_transaction_amount
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN transactions t ON t.account_id = a.account_id
WHERE t.status = 'SUCCESS'
GROUP BY c.risk_level
ORDER BY FIELD(c.risk_level, 'HIGH', 'MEDIUM', 'LOW');