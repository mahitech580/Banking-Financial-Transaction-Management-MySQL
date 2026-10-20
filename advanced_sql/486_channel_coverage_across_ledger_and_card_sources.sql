-- Business question: Compare channel coverage for account-ledger and card transaction sources.
WITH source_events AS (
  SELECT channel, status, 'ACCOUNT_LEDGER' AS source_name, amount FROM transactions
  UNION ALL
  SELECT channel, status, 'CARD_ACTIVITY' AS source_name, amount FROM card_transactions
)
SELECT source_name, channel, status, COUNT(*) AS attempt_count,
       SUM(amount) AS attempted_value,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(100.0 * SUM(status = 'SUCCESS') / COUNT(*), 2) AS success_rate_pct
FROM source_events
GROUP BY source_name, channel, status
ORDER BY source_name, channel, status;
