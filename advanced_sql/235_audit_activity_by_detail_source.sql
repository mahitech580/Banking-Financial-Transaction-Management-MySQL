-- audit log activity review grouped by source field in details; read-only analysis over the banking demo schema.
SELECT COALESCE(JSON_UNQUOTE(JSON_EXTRACT(al.details,'$.source')),'Not recorded') AS grouping_value,
  COUNT(*) AS audit_event_count,
  COUNT(DISTINCT al.entity_id) AS distinct_entity_ids,
  COUNT(DISTINCT al.entity_name) AS entity_type_count,
  SUM(al.details IS NOT NULL) AS events_with_details,
  SUM(al.action_type='INSERT') AS insert_events,
  SUM(al.action_type='UPDATE') AS update_events,
  SUM(al.action_type='DELETE') AS delete_events
FROM audit_log al
GROUP BY 1
ORDER BY 2 DESC;
