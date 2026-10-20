-- Business question: Which dispute reasons and transaction segments account for the most reported disputed amount?
-- Grain: one reason/status/customer-risk/channel segment. Disputed amount is not the same as a confirmed loss or refund.
SELECT d.reason, d.status AS dispute_status, c.risk_level AS customer_risk_level,
  t.channel, t.transaction_type, COUNT(*) AS dispute_count,
  SUM(d.disputed_amount) AS total_disputed_amount,
  ROUND(AVG(d.disputed_amount), 2) AS average_disputed_amount,
  SUM(d.disputed_amount > t.amount) AS disputes_above_linked_transaction_amount
FROM disputes d
JOIN transactions t ON t.transaction_id = d.transaction_id
JOIN accounts a ON a.account_id = t.account_id
JOIN customers c ON c.customer_id = a.customer_id
GROUP BY d.reason, d.status, c.risk_level, t.channel, t.transaction_type
ORDER BY total_disputed_amount DESC, dispute_count DESC;
