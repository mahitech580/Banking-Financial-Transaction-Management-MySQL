-- Business question: Which accounts send or receive the most completed transfer value?
-- Grain: one account/direction. Transfer records are counted separately from transaction-ledger rows to avoid double counting the same movement.
WITH transfer_roles AS (
  SELECT from_account_id AS account_id, 'OUTBOUND' AS transfer_direction,
    status, transfer_amount AS amount, initiated_at
  FROM transfers
  UNION ALL
  SELECT to_account_id AS account_id, 'INBOUND' AS transfer_direction,
    status, transfer_amount AS amount, initiated_at
  FROM transfers
)
SELECT a.account_id, a.account_number, a.customer_id, a.account_type, a.status AS account_status,
  tr.transfer_direction, COUNT(*) AS transfer_record_count,
  SUM(tr.status = 'COMPLETED') AS completed_count,
  SUM(tr.status = 'FAILED') AS failed_count,
  COALESCE(SUM(CASE WHEN tr.status = 'COMPLETED' THEN tr.amount ELSE 0 END), 0.00)
    AS completed_transfer_value,
  MAX(tr.initiated_at) AS latest_transfer_initiated_at
FROM transfer_roles tr JOIN accounts a ON a.account_id = tr.account_id
GROUP BY a.account_id, a.account_number, a.customer_id, a.account_type, a.status, tr.transfer_direction
ORDER BY completed_transfer_value DESC, a.account_id, tr.transfer_direction;
