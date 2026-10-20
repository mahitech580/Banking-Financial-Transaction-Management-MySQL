-- Business question: How often do ledger transactions include a merchant reference, by channel, type, and outcome?
-- Grain: one channel/type/status group. A missing merchant ID is not automatically a data defect because the field is optional.
SELECT channel, transaction_type, status AS transaction_status,
  COUNT(*) AS transaction_count,
  SUM(merchant_id IS NOT NULL) AS transactions_with_merchant,
  SUM(merchant_id IS NULL) AS transactions_without_merchant,
  ROUND(100.0 * SUM(merchant_id IS NOT NULL) / NULLIF(COUNT(*), 0), 2) AS merchant_reference_coverage_pct,
  COALESCE(SUM(CASE WHEN status = 'SUCCESS' AND merchant_id IS NULL THEN amount ELSE 0 END), 0.00)
    AS successful_value_without_merchant
FROM transactions
GROUP BY channel, transaction_type, status
ORDER BY channel, transaction_type, transaction_status;
