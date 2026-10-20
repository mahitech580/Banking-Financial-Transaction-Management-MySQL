-- Business question: Track fraud-event action volume and risk-score ranges by month.
SELECT DATE_FORMAT(detected_at, '%Y-%m') AS detection_month,
       action_taken, fraud_type, COUNT(*) AS event_count,
       ROUND(AVG(risk_score), 2) AS average_risk_score,
       MIN(risk_score) AS minimum_risk_score, MAX(risk_score) AS maximum_risk_score,
       COUNT(DISTINCT transaction_id) AS transactions_flagged
FROM fraud_events
GROUP BY DATE_FORMAT(detected_at, '%Y-%m'), action_taken, fraud_type
ORDER BY detection_month DESC, event_count DESC;
