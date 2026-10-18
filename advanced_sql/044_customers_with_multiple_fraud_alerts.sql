-- Business question: Which customers have multiple fraud events recorded?
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(f.fraud_event_id) AS fraud_event_count,
       MAX(f.risk_score) AS maximum_risk_score,
       SUM(f.action_taken = 'BLOCK') AS blocked_events
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN transactions t ON t.account_id = a.account_id
JOIN fraud_events f ON f.transaction_id = t.transaction_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(f.fraud_event_id) > 1
ORDER BY fraud_event_count DESC, maximum_risk_score DESC;