-- Business question: What customer and account context is linked to each fraud event?
SELECT f.fraud_event_id, f.detected_at, f.fraud_type, f.risk_score, f.action_taken,
       t.reference_code, t.transaction_type, t.amount, t.channel, t.status,
       a.account_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.risk_level AS customer_risk_level
FROM fraud_events f
JOIN transactions t ON t.transaction_id = f.transaction_id
JOIN accounts a ON a.account_id = t.account_id
JOIN customers c ON c.customer_id = a.customer_id
ORDER BY f.risk_score DESC, f.detected_at DESC;