-- Business question: How are recorded fraud-event scores distributed across follow-up actions?
-- Grain: one score band/action pair. The numeric thresholds are illustrative audit slices, not a validated detection policy.
SELECT CASE WHEN risk_score >= 80 THEN '80_TO_100'
  WHEN risk_score >= 60 THEN '60_TO_79_99'
  WHEN risk_score >= 30 THEN '30_TO_59_99'
  ELSE 'BELOW_30' END AS score_band,
  action_taken, fraud_type, COUNT(*) AS event_count,
  ROUND(AVG(risk_score), 2) AS average_risk_score,
  MIN(risk_score) AS minimum_score, MAX(risk_score) AS maximum_score,
  SUM(action_taken = 'ALLOW' AND risk_score >= 80) AS high_score_allowed_events,
  SUM(action_taken = 'BLOCK' AND risk_score < 30) AS low_score_blocked_events
FROM fraud_events
GROUP BY score_band, action_taken, fraud_type
ORDER BY FIELD(score_band, '80_TO_100', '60_TO_79_99', '30_TO_59_99', 'BELOW_30'),
  high_score_allowed_events DESC, event_count DESC;
