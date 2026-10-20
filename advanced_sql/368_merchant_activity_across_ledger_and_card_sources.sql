-- Business question: What are merchant transaction outcomes across account-ledger and card activity, kept in separate source groups?
-- Grain: one merchant/source/status combination. Do not add the two source totals without a documented deduplication model.
WITH source_events AS (
  SELECT m.merchant_id, m.merchant_name, m.merchant_category, m.risk_level AS merchant_risk_level,
    'ACCOUNT_LEDGER' AS event_source, t.status AS event_status, t.amount, t.transaction_time
  FROM transactions t JOIN merchants m ON m.merchant_id = t.merchant_id
  UNION ALL
  SELECT m.merchant_id, m.merchant_name, m.merchant_category, m.risk_level AS merchant_risk_level,
    'CARD_ACTIVITY' AS event_source, ct.status AS event_status, ct.amount, ct.transaction_time
  FROM card_transactions ct JOIN merchants m ON m.merchant_id = ct.merchant_id
)
SELECT merchant_id, merchant_name, merchant_category, merchant_risk_level,
  event_source, event_status, COUNT(*) AS event_count,
  COALESCE(SUM(CASE WHEN event_status = 'SUCCESS' THEN amount ELSE 0 END), 0.00) AS successful_gross_value,
  ROUND(AVG(amount), 2) AS average_attempt_amount,
  MIN(transaction_time) AS first_event_at, MAX(transaction_time) AS latest_event_at
FROM source_events
GROUP BY merchant_id, merchant_name, merchant_category, merchant_risk_level, event_source, event_status
ORDER BY merchant_name, event_source, event_status;
