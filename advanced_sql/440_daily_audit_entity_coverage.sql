-- Business question: Monitor how broadly audit events cover entities each day.
SELECT DATE(action_at) AS audit_day, entity_name, action_type,
       COUNT(*) AS event_count,
       COUNT(DISTINCT entity_id) AS distinct_entities,
       ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT entity_id), 0), 2) AS events_per_entity,
       MIN(action_at) AS first_event_at,
       MAX(action_at) AS last_event_at
FROM audit_log
GROUP BY DATE(action_at), entity_name, action_type
ORDER BY audit_day DESC, event_count DESC;
