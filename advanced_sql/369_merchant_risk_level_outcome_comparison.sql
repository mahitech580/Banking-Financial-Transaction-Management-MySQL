-- Business question: Does recorded transaction outcome mix differ by merchant risk category and merchant category?
-- Grain: one merchant risk/category/source/outcome grouping. Merchant labels are supplied metadata, not an independent fraud assessment.
WITH merchant_events AS (
  SELECT m.risk_level AS merchant_risk_level, m.merchant_category,
    'ACCOUNT_LEDGER' AS event_source, t.status AS event_status, t.amount
  FROM transactions t JOIN merchants m ON m.merchant_id = t.merchant_id
  UNION ALL
  SELECT m.risk_level, m.merchant_category, 'CARD_ACTIVITY', ct.status, ct.amount
  FROM card_transactions ct JOIN merchants m ON m.merchant_id = ct.merchant_id
)
SELECT merchant_risk_level, merchant_category, event_source, event_status,
  COUNT(*) AS event_count,
  ROUND(100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (
    PARTITION BY merchant_risk_level, merchant_category, event_source), 0), 2) AS outcome_share_pct,
  COALESCE(SUM(CASE WHEN event_status = 'SUCCESS' THEN amount ELSE 0 END), 0.00)
    AS successful_gross_value
FROM merchant_events
GROUP BY merchant_risk_level, merchant_category, event_source, event_status
ORDER BY merchant_risk_level, merchant_category, event_source, event_count DESC;
