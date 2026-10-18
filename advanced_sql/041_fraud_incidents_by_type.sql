-- Business question: Which recorded fraud categories have the most alerts?
SELECT fraud_type, COUNT(*) AS incidents,
       AVG(risk_score) AS average_risk_score,
       MAX(risk_score) AS highest_risk_score,
       SUM(action_taken = 'BLOCK') AS blocked_count,
       SUM(action_taken = 'REVIEW') AS review_count
FROM fraud_events
GROUP BY fraud_type
ORDER BY incidents DESC, average_risk_score DESC;