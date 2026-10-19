-- Business question: How long after a transaction was recorded were fraud events detected, by action?
SELECT f.action_taken,f.fraud_type,COUNT(*) event_count,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE,t.transaction_time,f.detected_at)),2) average_detection_lag_minutes,
       MIN(TIMESTAMPDIFF(MINUTE,t.transaction_time,f.detected_at)) minimum_lag_minutes,
       MAX(TIMESTAMPDIFF(MINUTE,t.transaction_time,f.detected_at)) maximum_lag_minutes,
       ROUND(AVG(f.risk_score),2) average_risk_score
FROM fraud_events f JOIN transactions t ON t.transaction_id=f.transaction_id
GROUP BY f.action_taken,f.fraud_type
ORDER BY average_detection_lag_minutes DESC;