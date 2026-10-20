-- Business question: How quickly are fraud-event records created after their linked transaction timestamps?
-- Grain: one row per event type and action. Negative intervals are timestamp anomalies requiring context, not proof of bad data.
WITH event_latency AS (
  SELECT f.fraud_event_id, f.fraud_type, f.action_taken, f.risk_score,
    TIMESTAMPDIFF(SECOND, t.transaction_time, f.detected_at) AS detection_latency_seconds
  FROM fraud_events f JOIN transactions t ON t.transaction_id = f.transaction_id
)
SELECT fraud_type, action_taken, COUNT(*) AS event_count,
  SUM(detection_latency_seconds < 0) AS negative_latency_count,
  MIN(detection_latency_seconds) AS minimum_latency_seconds,
  ROUND(AVG(CASE WHEN detection_latency_seconds >= 0 THEN detection_latency_seconds END), 2)
    AS average_nonnegative_latency_seconds,
  MAX(CASE WHEN detection_latency_seconds >= 0 THEN detection_latency_seconds END)
    AS maximum_nonnegative_latency_seconds,
  SUM(detection_latency_seconds BETWEEN 0 AND 60) AS detected_within_one_minute,
  SUM(detection_latency_seconds BETWEEN 0 AND 3600) AS detected_within_one_hour,
  ROUND(AVG(risk_score), 2) AS average_recorded_risk_score
FROM event_latency
GROUP BY fraud_type, action_taken
ORDER BY negative_latency_count DESC, average_nonnegative_latency_seconds DESC, fraud_type;
