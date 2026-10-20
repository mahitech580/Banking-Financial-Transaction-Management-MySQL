-- Business question: Which open disputes are linked to transactions currently marked reversed?
-- Grain: one dispute. The combination may reflect a legitimate workflow or timing difference and needs lifecycle context.
SELECT d.dispute_id, d.transaction_id, t.reference_code, d.opened_at,
  d.reason, d.disputed_amount, d.status AS dispute_status,
  t.status AS transaction_status, t.transaction_type, t.channel, t.amount AS linked_transaction_amount
FROM disputes d JOIN transactions t ON t.transaction_id = d.transaction_id
WHERE d.status = 'OPEN' AND t.status = 'REVERSED'
ORDER BY d.opened_at, d.dispute_id;
