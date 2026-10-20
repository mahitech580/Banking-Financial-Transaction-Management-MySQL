-- Business question: How often do transaction groups by channel and status have settlement records, and what is their settled amount?
-- Grain: one channel/transaction-status bucket. Coverage is record presence, not an assumption that every transaction type requires settlement.
WITH per_transaction_settlement AS (
  SELECT transaction_id, COUNT(*) AS settlement_rows,
    SUM(status = 'SETTLED') AS settled_rows,
    COALESCE(SUM(CASE WHEN status = 'SETTLED' THEN settlement_amount ELSE 0 END), 0.00) AS settled_value
  FROM settlements GROUP BY transaction_id
)
SELECT t.channel, t.status AS transaction_status, COUNT(*) AS transaction_count,
  SUM(COALESCE(ps.settlement_rows, 0) > 0) AS transactions_with_settlement_records,
  SUM(COALESCE(ps.settled_rows, 0) > 0) AS transactions_with_settled_rows,
  ROUND(100.0 * SUM(COALESCE(ps.settlement_rows, 0) > 0) / NULLIF(COUNT(*), 0), 2)
    AS settlement_record_coverage_pct,
  COALESCE(SUM(ps.settled_value), 0.00) AS settled_record_value
FROM transactions t LEFT JOIN per_transaction_settlement ps ON ps.transaction_id = t.transaction_id
GROUP BY t.channel, t.status
ORDER BY t.channel, t.status;
