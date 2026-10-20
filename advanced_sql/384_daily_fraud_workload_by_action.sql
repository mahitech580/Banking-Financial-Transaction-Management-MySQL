-- Business question: How does the daily recorded fraud-event workload vary by event type and action?
-- Grain: one detection date/type/action. This measures recorded events and does not imply the events are confirmed fraud.
SELECT DATE(f.detected_at) AS detection_date, f.fraud_type, f.action_taken,
  COUNT(*) AS event_count, COUNT(DISTINCT f.transaction_id) AS linked_transactions,
  ROUND(AVG(f.risk_score), 2) AS average_risk_score,
  MAX(f.risk_score) AS maximum_risk_score,
  SUM(f.risk_score >= 80) AS high_score_events
FROM fraud_events f
GROUP BY DATE(f.detected_at), f.fraud_type, f.action_taken
ORDER BY detection_date DESC, event_count DESC, f.fraud_type, f.action_taken;
