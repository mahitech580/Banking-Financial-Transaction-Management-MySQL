-- Business question: Compare aggregate settlement value for each transaction with the source transaction amount.
WITH settlement_totals AS (
  SELECT transaction_id, COUNT(*) AS settlement_rows,
         SUM(settlement_amount) AS total_settlement_amount,
         SUM(status = 'SETTLED') AS settled_rows
  FROM settlements GROUP BY transaction_id
)
SELECT t.reference_code, t.amount AS transaction_amount, t.status AS transaction_status,
       COALESCE(s.settlement_rows, 0) AS settlement_rows,
       COALESCE(s.total_settlement_amount, 0) AS total_settlement_amount,
       COALESCE(s.total_settlement_amount, 0) - t.amount AS settlement_variance,
       COALESCE(s.settled_rows, 0) AS settled_row_count
FROM transactions AS t
LEFT JOIN settlement_totals AS s ON s.transaction_id = t.transaction_id
WHERE s.transaction_id IS NULL OR s.total_settlement_amount <> t.amount
ORDER BY ABS(COALESCE(s.total_settlement_amount, 0) - t.amount) DESC, t.transaction_id;
