-- Business question: Which branch, hour, and channel combinations carry the most attempts and successful gross value?
-- Grain: one branch/hour/channel bucket, attributed using the account's current branch association.
SELECT b.branch_id, b.branch_name, b.city,
  HOUR(t.transaction_time) AS transaction_hour, t.channel,
  COUNT(*) AS attempt_count,
  SUM(t.status = 'SUCCESS') AS successful_count,
  SUM(t.status = 'FAILED') AS failed_count,
  ROUND(100.0 * SUM(t.status = 'SUCCESS') / NULLIF(COUNT(*), 0), 2) AS success_rate_pct,
  COALESCE(SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END), 0.00) AS successful_gross_value
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
JOIN branches b ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, HOUR(t.transaction_time), t.channel
ORDER BY attempt_count DESC, b.branch_id, transaction_hour, t.channel;
