-- Business question: Which transaction states appear inconsistent with the presence of successful settlement rows?
-- Grain: one transaction. Not every transaction type requires settlement, so missing rows must be assessed against operational scope.
WITH settlement_summary AS (
  SELECT transaction_id, COUNT(*) AS settlement_rows,
    SUM(status = 'SETTLED') AS settled_rows,
    SUM(status = 'PENDING') AS pending_rows,
    SUM(status = 'FAILED') AS failed_rows
  FROM settlements GROUP BY transaction_id
)
SELECT t.transaction_id, t.reference_code, t.transaction_type, t.channel,
  t.status AS transaction_status, t.amount,
  COALESCE(ss.settlement_rows, 0) AS settlement_rows,
  COALESCE(ss.settled_rows, 0) AS settled_rows,
  COALESCE(ss.pending_rows, 0) AS pending_rows,
  COALESCE(ss.failed_rows, 0) AS failed_rows,
  CASE WHEN t.status = 'SUCCESS' AND COALESCE(ss.settled_rows, 0) = 0
    THEN 'SUCCESS_WITHOUT_SETTLED_ROW'
    WHEN t.status <> 'SUCCESS' AND COALESCE(ss.settled_rows, 0) > 0
    THEN 'NON_SUCCESS_WITH_SETTLED_ROW' END AS review_reason
FROM transactions t LEFT JOIN settlement_summary ss ON ss.transaction_id = t.transaction_id
WHERE (t.status = 'SUCCESS' AND COALESCE(ss.settled_rows, 0) = 0)
   OR (t.status <> 'SUCCESS' AND COALESCE(ss.settled_rows, 0) > 0)
ORDER BY review_reason, t.transaction_time DESC, t.transaction_id;
