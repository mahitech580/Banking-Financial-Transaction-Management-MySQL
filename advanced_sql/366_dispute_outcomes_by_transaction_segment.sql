-- Business question: How do dispute statuses and disputed amounts vary by transaction channel, type and customer risk?
-- Grain: one segment and dispute status. No resolved timestamp exists, so this report compares outcomes without claiming resolution time.
SELECT t.channel, t.transaction_type, c.risk_level AS customer_risk_level,
  d.status AS dispute_status, d.reason,
  COUNT(*) AS dispute_count,
  COUNT(DISTINCT d.transaction_id) AS distinct_disputed_transactions,
  SUM(d.disputed_amount) AS disputed_amount,
  ROUND(AVG(d.disputed_amount), 2) AS average_disputed_amount,
  SUM(t.status = 'SUCCESS') AS linked_transactions_marked_success,
  SUM(t.status = 'REVERSED') AS linked_transactions_marked_reversed
FROM disputes d
JOIN transactions t ON t.transaction_id = d.transaction_id
JOIN accounts a ON a.account_id = t.account_id
JOIN customers c ON c.customer_id = a.customer_id
GROUP BY t.channel, t.transaction_type, c.risk_level, d.status, d.reason
ORDER BY disputed_amount DESC, dispute_count DESC;
