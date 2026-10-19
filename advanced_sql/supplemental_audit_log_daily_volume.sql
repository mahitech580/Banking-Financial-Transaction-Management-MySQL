-- Business question: Which entity/action combinations generate the highest daily audit-log volume?
SELECT DATE(action_at) action_date,entity_name,action_type,
       COUNT(*) event_count,COUNT(DISTINCT entity_id) distinct_entities,
       MIN(action_at) first_event_at,MAX(action_at) last_event_at
FROM audit_log
GROUP BY DATE(action_at),entity_name,action_type
ORDER BY action_date DESC,event_count DESC;