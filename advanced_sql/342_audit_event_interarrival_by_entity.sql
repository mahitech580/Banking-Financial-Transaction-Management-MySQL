-- Business question: Which audited entities have the largest gaps and bursts between recorded audit events?
WITH ordered AS (
  SELECT entity_name,entity_id,audit_id,action_type,action_at,
         LAG(action_at) OVER(PARTITION BY entity_name,entity_id ORDER BY action_at,audit_id) previous_event_at
  FROM audit_log
)
SELECT entity_name,entity_id,COUNT(*) observed_events,
       ROUND(AVG(TIMESTAMPDIFF(SECOND,previous_event_at,action_at)),2) average_gap_seconds,
       MIN(TIMESTAMPDIFF(SECOND,previous_event_at,action_at)) shortest_gap_seconds,
       MAX(TIMESTAMPDIFF(SECOND,previous_event_at,action_at)) longest_gap_seconds,
       SUM(TIMESTAMPDIFF(SECOND,previous_event_at,action_at)<=60) events_within_one_minute,
       MIN(action_at) first_observed_at,MAX(action_at) last_observed_at
FROM ordered WHERE previous_event_at IS NOT NULL
GROUP BY entity_name,entity_id
HAVING COUNT(*)>=2
ORDER BY events_within_one_minute DESC,observed_events DESC
LIMIT 200;