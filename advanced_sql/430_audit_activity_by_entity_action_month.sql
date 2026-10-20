-- Business question: Which entity types and action classes generate the most audit-log activity?
SELECT entity_name, action_type,
       DATE_FORMAT(action_at, '%Y-%m') AS audit_month,
       COUNT(*) AS event_count,
       COUNT(DISTINCT entity_id) AS entities_touched,
       MIN(action_at) AS first_event_at,
       MAX(action_at) AS last_event_at
FROM audit_log
GROUP BY entity_name, action_type, DATE_FORMAT(action_at, '%Y-%m')
ORDER BY audit_month DESC, event_count DESC;
