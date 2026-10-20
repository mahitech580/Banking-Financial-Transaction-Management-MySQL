-- Business question: For transactions with settled rows, does the sum of recorded settled amounts equal the linked transaction amount?
-- Grain: one transaction with at least one settled row. Multiple lifecycle rows and partial settlements need interpretation before escalation.
WITH settled_by_transaction AS (
  SELECT transaction_id, COUNT(*) AS settled_row_count,
    SUM(settlement_amount) AS total_settled_amount,
    MIN(settled_at) AS first_settled_at, MAX(settled_at) AS last_settled_at
  FROM settlements
  WHERE status = 'SETTLED'
  GROUP BY transaction_id
)
SELECT t.transaction_id, t.reference_code, t.status AS transaction_status,
  t.amount AS transaction_amount, s.settled_row_count, s.total_settled_amount,
  s.total_settled_amount - t.amount AS settled_minus_transaction_amount,
  s.first_settled_at, s.last_settled_at,
  CASE WHEN ABS(s.total_settled_amount - t.amount) < 0.01 THEN 'AMOUNTS_MATCH'
    WHEN s.total_settled_amount < t.amount THEN 'SETTLED_TOTAL_BELOW_TRANSACTION'
    ELSE 'SETTLED_TOTAL_ABOVE_TRANSACTION' END AS reconciliation_band
FROM transactions t JOIN settled_by_transaction s ON s.transaction_id = t.transaction_id
WHERE ABS(s.total_settled_amount - t.amount) >= 0.01
ORDER BY ABS(s.total_settled_amount - t.amount) DESC, t.transaction_id;
