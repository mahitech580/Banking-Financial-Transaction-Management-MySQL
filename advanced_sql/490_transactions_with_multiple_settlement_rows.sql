-- Business question: Find transaction IDs with repeated settlement rows for reconciliation.
SELECT t.transaction_id, t.reference_code, t.amount AS transaction_amount,
       COUNT(s.settlement_id) AS settlement_row_count,
       SUM(s.settlement_amount) AS total_settlement_amount,
       SUM(s.status = 'SETTLED') AS settled_row_count,
       SUM(s.status = 'PENDING') AS pending_row_count,
       SUM(s.status = 'FAILED') AS failed_row_count
FROM transactions AS t
JOIN settlements AS s ON s.transaction_id = t.transaction_id
GROUP BY t.transaction_id, t.reference_code, t.amount
HAVING COUNT(s.settlement_id) > 1
ORDER BY settlement_row_count DESC, total_settlement_amount DESC;
