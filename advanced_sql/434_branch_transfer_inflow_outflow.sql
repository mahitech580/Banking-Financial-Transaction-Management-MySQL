-- Business question: Compare completed transfer amounts sent and received by each branch.
WITH outgoing AS (
  SELECT a.branch_id, COUNT(*) AS transfer_count, SUM(tr.transfer_amount) AS transfer_value
  FROM transfers AS tr
  JOIN accounts AS a ON a.account_id = tr.from_account_id
  WHERE tr.status = 'COMPLETED'
  GROUP BY a.branch_id
), incoming AS (
  SELECT a.branch_id, COUNT(*) AS transfer_count, SUM(tr.transfer_amount) AS transfer_value
  FROM transfers AS tr
  JOIN accounts AS a ON a.account_id = tr.to_account_id
  WHERE tr.status = 'COMPLETED'
  GROUP BY a.branch_id
)
SELECT b.branch_id, b.branch_name,
       COALESCE(o.transfer_count, 0) AS outgoing_count,
       COALESCE(o.transfer_value, 0) AS outgoing_value,
       COALESCE(i.transfer_count, 0) AS incoming_count,
       COALESCE(i.transfer_value, 0) AS incoming_value,
       COALESCE(i.transfer_value, 0) - COALESCE(o.transfer_value, 0) AS net_transfer_flow
FROM branches AS b
LEFT JOIN outgoing AS o ON o.branch_id = b.branch_id
LEFT JOIN incoming AS i ON i.branch_id = b.branch_id
ORDER BY ABS(COALESCE(i.transfer_value, 0) - COALESCE(o.transfer_value, 0)) DESC;
