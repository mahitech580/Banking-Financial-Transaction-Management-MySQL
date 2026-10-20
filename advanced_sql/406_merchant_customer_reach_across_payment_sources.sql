-- Business question: How many distinct customers reach each merchant through ledger and card transactions?
WITH merchant_events AS (
  SELECT t.merchant_id, a.customer_id, 'ACCOUNT_LEDGER' AS source_name,
         t.transaction_time AS event_time, t.status, t.amount
  FROM transactions AS t
  JOIN accounts AS a ON a.account_id = t.account_id
  WHERE t.merchant_id IS NOT NULL
  UNION ALL
  SELECT ct.merchant_id, c.customer_id, 'CARD_ACTIVITY' AS source_name,
         ct.transaction_time AS event_time, ct.status, ct.amount
  FROM card_transactions AS ct
  JOIN cards AS c ON c.card_id = ct.card_id
)
SELECT m.merchant_id, m.merchant_name, m.merchant_category,
       COUNT(DISTINCT e.customer_id) AS distinct_customers,
       COUNT(DISTINCT CASE WHEN e.status = 'SUCCESS' THEN e.customer_id END) AS successful_customers,
       SUM(e.source_name = 'ACCOUNT_LEDGER') AS ledger_attempts,
       SUM(e.source_name = 'CARD_ACTIVITY') AS card_attempts,
       SUM(CASE WHEN e.status = 'SUCCESS' THEN e.amount ELSE 0 END) AS combined_successful_value
FROM merchants AS m
LEFT JOIN merchant_events AS e ON e.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name, m.merchant_category
ORDER BY distinct_customers DESC, combined_successful_value DESC;
