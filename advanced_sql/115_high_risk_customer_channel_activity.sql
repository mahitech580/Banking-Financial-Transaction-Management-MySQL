-- Business question: Describe successful transaction channel usage for customers labelled high risk.
-- The label is an existing dataset attribute and does not prove fraud or justify an automated decision.
SELECT c.customer_id,c.customer_number,t.channel,COUNT(*) successful_transactions,
       ROUND(SUM(t.amount),2) successful_value,ROUND(AVG(t.amount),2) average_amount,
       MIN(t.transaction_time) first_success_at,MAX(t.transaction_time) last_success_at
FROM customers c JOIN accounts a ON a.customer_id=c.customer_id
JOIN transactions t ON t.account_id=a.account_id
WHERE c.risk_level='HIGH' AND t.status='SUCCESS'
GROUP BY c.customer_id,c.customer_number,t.channel
ORDER BY successful_value DESC;