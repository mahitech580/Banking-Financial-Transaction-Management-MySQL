-- Business question: Which settlement records are still pending?
SELECT s.settlement_id, s.transaction_id, t.reference_code, s.settlement_amount,
       s.status, s.settled_at, TIMESTAMPDIFF(DAY, t.transaction_time, NOW()) AS transaction_age_days
FROM settlements s
JOIN transactions t ON t.transaction_id = s.transaction_id
WHERE s.status = 'PENDING'
ORDER BY transaction_age_days DESC;