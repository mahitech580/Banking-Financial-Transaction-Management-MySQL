-- Business question: Which transactions have multiple settlement rows and therefore deserve lifecycle/reconciliation review?
-- Grain: one row per transaction with more than one settlement record; multiple rows may be legitimate lifecycle history.
SELECT t.transaction_id, t.reference_code, t.status AS transaction_status, t.amount AS transaction_amount,
  COUNT(s.settlement_id) AS settlement_record_count,
  SUM(s.status = 'SETTLED') AS settled_record_count,
  SUM(s.status = 'PENDING') AS pending_record_count,
  SUM(s.status = 'FAILED') AS failed_record_count,
  COALESCE(SUM(CASE WHEN s.status = 'SETTLED' THEN s.settlement_amount ELSE 0 END), 0.00)
    AS total_settled_record_amount,
  MIN(s.settled_at) AS first_settled_at, MAX(s.settled_at) AS last_settled_at
FROM transactions t
JOIN settlements s ON s.transaction_id = t.transaction_id
GROUP BY t.transaction_id, t.reference_code, t.status, t.amount
HAVING COUNT(s.settlement_id) > 1
ORDER BY settlement_record_count DESC, t.transaction_id;
