-- Business question: Compare recorded fraud actions with broad illustrative risk-score bands.
-- This is an audit prompt only; the sample thresholds are not a production decision rule.
SELECT action_taken,
       CASE WHEN risk_score < 25 THEN 'LOW_SCORE'
            WHEN risk_score < 50 THEN 'MODERATE_SCORE'
            WHEN risk_score < 75 THEN 'ELEVATED_SCORE'
            ELSE 'HIGH_SCORE' END AS score_band,
       COUNT(*) AS event_count,
       ROUND(AVG(risk_score), 2) AS average_score,
       SUM(action_taken = 'ALLOW') AS allow_events,
       SUM(action_taken = 'REVIEW') AS review_events,
       SUM(action_taken = 'BLOCK') AS block_events
FROM fraud_events
GROUP BY action_taken, score_band
ORDER BY score_band, event_count DESC;
