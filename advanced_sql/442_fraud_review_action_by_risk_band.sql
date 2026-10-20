-- Business question: Review how stored fraud scores align with the action recorded by the system.
SELECT CASE WHEN risk_score < 25 THEN '0_TO_24'
            WHEN risk_score < 50 THEN '25_TO_49'
            WHEN risk_score < 75 THEN '50_TO_74'
            ELSE '75_TO_100' END AS risk_score_band,
       action_taken, fraud_type,
       COUNT(*) AS event_count,
       ROUND(AVG(risk_score), 2) AS average_risk_score,
       MIN(detected_at) AS first_detection_at,
       MAX(detected_at) AS last_detection_at
FROM fraud_events
GROUP BY risk_score_band, action_taken, fraud_type
ORDER BY risk_score_band, event_count DESC;
