-- Business question: Which individual entities have the most insert/update/delete audit events?
SELECT entity_name,entity_id,COUNT(*) total_audit_events,
       SUM(action_type='INSERT') insert_events,
       SUM(action_type='UPDATE') update_events,
       SUM(action_type='DELETE') delete_events,
       MIN(action_at) first_audited_at,MAX(action_at) last_audited_at
FROM audit_log
GROUP BY entity_name,entity_id
HAVING COUNT(*)>=2
ORDER BY total_audit_events DESC,last_audited_at DESC
LIMIT 200;