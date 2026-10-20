-- Business question: Compare the share of DELETE actions in audit logs across entity types.
SELECT entity_name,
       COUNT(*) AS audit_events,
       SUM(action_type = 'DELETE') AS delete_events,
       SUM(action_type = 'UPDATE') AS update_events,
       SUM(action_type = 'INSERT') AS insert_events,
       ROUND(100.0 * SUM(action_type = 'DELETE') / COUNT(*), 2) AS delete_share_pct,
       COUNT(DISTINCT entity_id) AS distinct_entities_touched
FROM audit_log
GROUP BY entity_name
ORDER BY delete_share_pct DESC, audit_events DESC;
