-- Business question: Compare activity footprint for merchants across the two separate transaction sources.
WITH ledger_activity AS (
  SELECT merchant_id, COUNT(*) AS ledger_rows,
         SUM(status = 'SUCCESS') AS ledger_successes
  FROM transactions WHERE merchant_id IS NOT NULL GROUP BY merchant_id
), card_activity AS (
  SELECT merchant_id, COUNT(*) AS card_rows,
         SUM(status = 'SUCCESS') AS card_successes
  FROM card_transactions GROUP BY merchant_id
)
SELECT m.merchant_id, m.merchant_name, m.merchant_category,
       COALESCE(l.ledger_rows, 0) AS ledger_rows,
       COALESCE(l.ledger_successes, 0) AS ledger_successes,
       COALESCE(c.card_rows, 0) AS card_rows,
       COALESCE(c.card_successes, 0) AS card_successes,
       CASE WHEN l.merchant_id IS NULL AND c.merchant_id IS NULL THEN 'NO_ACTIVITY'
            WHEN l.merchant_id IS NULL THEN 'CARD_ONLY'
            WHEN c.merchant_id IS NULL THEN 'LEDGER_ONLY'
            ELSE 'BOTH_SOURCES' END AS source_coverage
FROM merchants AS m
LEFT JOIN ledger_activity AS l ON l.merchant_id = m.merchant_id
LEFT JOIN card_activity AS c ON c.merchant_id = m.merchant_id
ORDER BY source_coverage, ledger_rows + card_rows DESC;
