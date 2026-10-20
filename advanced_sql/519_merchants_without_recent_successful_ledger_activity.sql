-- Business question: Find merchants with historic successful ledger traffic but no success in the past 30 days.
WITH merchant_history AS (
  SELECT merchant_id,
         MAX(CASE WHEN status = 'SUCCESS' THEN transaction_time END) AS last_success_at,
         COUNT(*) AS all_attempts,
         SUM(status = 'SUCCESS') AS all_successes
  FROM transactions
  WHERE merchant_id IS NOT NULL
  GROUP BY merchant_id
)
SELECT m.merchant_id, m.merchant_name, m.merchant_category, m.risk_level,
       h.all_attempts, h.all_successes, h.last_success_at,
       DATEDIFF(CURRENT_DATE, DATE(h.last_success_at)) AS days_since_success
FROM merchants AS m
JOIN merchant_history AS h ON h.merchant_id = m.merchant_id
WHERE h.all_successes > 0
  AND (h.last_success_at IS NULL OR h.last_success_at < CURRENT_TIMESTAMP - INTERVAL 30 DAY)
ORDER BY days_since_success DESC, h.all_attempts DESC;
