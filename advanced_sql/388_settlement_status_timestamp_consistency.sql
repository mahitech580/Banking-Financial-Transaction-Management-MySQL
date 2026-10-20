-- Business question: Which settlement rows have a status/timestamp combination that deserves a lifecycle check?
-- Grain: one settlement record. The table has no status-history timestamp, so this validates field alignment only.
SELECT s.settlement_id, s.transaction_id, t.reference_code, t.status AS transaction_status,
  s.status AS settlement_status, s.settled_at, s.settlement_amount,
  CASE WHEN s.status = 'SETTLED' AND s.settled_at IS NULL THEN 'SETTLED_WITHOUT_SETTLED_TIMESTAMP'
    WHEN s.status <> 'SETTLED' AND s.settled_at IS NOT NULL THEN 'NON_SETTLED_WITH_SETTLED_TIMESTAMP'
    ELSE 'STATUS_TIMESTAMP_ALIGNS' END AS timestamp_review
FROM settlements s JOIN transactions t ON t.transaction_id = s.transaction_id
WHERE (s.status = 'SETTLED' AND s.settled_at IS NULL)
   OR (s.status <> 'SETTLED' AND s.settled_at IS NOT NULL)
ORDER BY s.status, s.settlement_id;
