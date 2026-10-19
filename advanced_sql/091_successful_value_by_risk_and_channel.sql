-- Cross-tab successful value by customer risk label and transaction channel.
SELECT c.risk_level,t.channel,COUNT(*) successful_transactions,ROUND(SUM(t.amount),2) successful_value,ROUND(AVG(t.amount),2) average_amount
FROM customers c JOIN accounts a ON a.customer_id=c.customer_id JOIN transactions t ON t.account_id=a.account_id
WHERE t.status='SUCCESS' GROUP BY c.risk_level,t.channel ORDER BY FIELD(c.risk_level,'LOW','MEDIUM','HIGH'),successful_value DESC;