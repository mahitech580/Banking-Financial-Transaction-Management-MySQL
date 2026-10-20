-- Business question: What share of successful ledger entries have at least one settlement record?
WITH settlement_coverage AS (
  SELECT transaction_id, COUNT(*) AS settlement_rows,
         SUM(status = 'SETTLED') AS settled_rows,
         SUM(settlement_amount) AS recorded_settlement_value
  FROM settlements
  GROUP BY transaction_id
)
SELECT t.channel, COUNT(*) AS successful_transaction_count,
       SUM(sc.transaction_id IS NOT NULL) AS transactions_with_settlement,
       SUM(COALESCE(sc.settlement_rows, 0)) AS settlement_row_count,
       ROUND(100.0 * SUM(sc.transaction_id IS NOT NULL) / COUNT(*), 2) AS record_coverage_pct,
       SUM(t.amount) AS successful_transaction_value,
       SUM(COALESCE(sc.recorded_settlement_value, 0)) AS recorded_settlement_value
FROM transactions AS t
LEFT JOIN settlement_coverage AS sc ON sc.transaction_id = t.transaction_id
WHERE t.status = 'SUCCESS'
GROUP BY t.channel
ORDER BY record_coverage_pct, successful_transaction_value DESC;
