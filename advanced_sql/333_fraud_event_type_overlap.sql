-- Business question: Which transactions carry multiple distinct fraud-event types or conflicting actions?
-- Multiple signals are for case review; their scores must not be interpreted as a calibrated combined probability.
SELECT f.transaction_id,t.reference_code,t.status transaction_status,t.channel,
       COUNT(*) fraud_event_count,COUNT(DISTINCT f.fraud_type) distinct_fraud_types,
       COUNT(DISTINCT f.action_taken) distinct_actions,
       ROUND(AVG(f.risk_score),2) average_risk_score,MAX(f.risk_score) maximum_risk_score,
       GROUP_CONCAT(DISTINCT f.action_taken ORDER BY f.action_taken) observed_actions,
       MIN(f.detected_at) first_detection_at,MAX(f.detected_at) last_detection_at
FROM fraud_events f JOIN transactions t ON t.transaction_id=f.transaction_id
GROUP BY f.transaction_id,t.reference_code,t.status,t.channel
HAVING COUNT(DISTINCT f.fraud_type)>1 OR COUNT(DISTINCT f.action_taken)>1
ORDER BY distinct_fraud_types DESC,maximum_risk_score DESC;