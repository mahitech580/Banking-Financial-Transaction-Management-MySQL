-- Business question: Find transactions with multiple fraud events, which may represent repeated signals or separate investigations.
SELECT t.transaction_id, t.reference_code, t.status AS transaction_status,
       COUNT(f.fraud_event_id) AS fraud_event_count,
       COUNT(DISTINCT f.fraud_type) AS distinct_signal_types,
       MIN(f.detected_at) AS first_detection_at,
       MAX(f.detected_at) AS last_detection_at,
       MAX(f.risk_score) AS maximum_risk_score
FROM transactions AS t
JOIN fraud_events AS f ON f.transaction_id = t.transaction_id
GROUP BY t.transaction_id, t.reference_code, t.status
HAVING COUNT(f.fraud_event_id) > 1
ORDER BY fraud_event_count DESC, maximum_risk_score DESC;
