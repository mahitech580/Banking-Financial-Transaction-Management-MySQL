-- Business question: Compare transaction amount with total recorded settlement amounts at transaction grain.
WITH settlement_totals AS (
  SELECT transaction_id, COUNT(*) AS settlement_rows,
         SUM(settlement_amount) AS total_settlement_amount,
         SUM(status = 'SETTLED') AS settled_rows
  FROM settlements
  GROUP BY transaction_id
)
SELECT t.channel, t.status AS transaction_status,
       COUNT(*) AS transaction_count,
       SUM(t.amount) AS transaction_value,
       SUM(COALESCE(s.total_settlement_amount, 0)) AS recorded_settlement_value,
       SUM(COALESCE(s.total_settlement_amount, 0) - t.amount) AS total_variance,
       SUM(s.transaction_id IS NULL) AS transactions_without_settlement,
       SUM(COALESCE(s.settlement_rows, 0) > 1) AS transactions_with_multiple_settlements
FROM transactions AS t
LEFT JOIN settlement_totals AS s ON s.transaction_id = t.transaction_id
GROUP BY t.channel, t.status
ORDER BY ABS(total_variance) DESC;
