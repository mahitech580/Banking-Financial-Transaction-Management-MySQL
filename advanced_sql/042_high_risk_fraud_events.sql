-- Business question: Which fraud events have a risk score of 80 or higher?
SELECT f.fraud_event_id, f.detected_at, f.fraud_type, f.risk_score, f.action_taken,
       t.reference_code, t.amount, t.channel, t.status
FROM fraud_events f
JOIN transactions t ON t.transaction_id = f.transaction_id
WHERE f.risk_score >= 80
ORDER BY f.risk_score DESC, f.detected_at DESC;