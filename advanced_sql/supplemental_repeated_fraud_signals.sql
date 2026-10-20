-- Business question: Which transactions have repeated events of the same fraud type on the same calendar day?
-- Repeated signals may reflect retries or rule overlap; they are not proof of fraud.
SELECT f.transaction_id,t.reference_code,f.fraud_type,DATE(f.detected_at) detected_date,
       COUNT(*) event_count,MIN(f.detected_at) first_detected_at,MAX(f.detected_at) last_detected_at,
       ROUND(AVG(f.risk_score),2) average_risk_score,
       GROUP_CONCAT(DISTINCT f.action_taken ORDER BY f.action_taken) observed_actions
FROM fraud_events f JOIN transactions t ON t.transaction_id=f.transaction_id
GROUP BY f.transaction_id,t.reference_code,f.fraud_type,DATE(f.detected_at)
HAVING COUNT(*)>1
ORDER BY event_count DESC,average_risk_score DESC;