-- Business question: Measure recorded time between a source transaction and its fraud-event detection.
SELECT t.channel, f.action_taken, f.fraud_type,
       COUNT(*) AS fraud_event_count,
       ROUND(AVG(TIMESTAMPDIFF(SECOND, t.transaction_time, f.detected_at)), 1) AS average_detection_lag_seconds,
       MIN(TIMESTAMPDIFF(SECOND, t.transaction_time, f.detected_at)) AS minimum_detection_lag_seconds,
       MAX(TIMESTAMPDIFF(SECOND, t.transaction_time, f.detected_at)) AS maximum_detection_lag_seconds
FROM fraud_events AS f
JOIN transactions AS t ON t.transaction_id = f.transaction_id
GROUP BY t.channel, f.action_taken, f.fraud_type
ORDER BY average_detection_lag_seconds DESC;
