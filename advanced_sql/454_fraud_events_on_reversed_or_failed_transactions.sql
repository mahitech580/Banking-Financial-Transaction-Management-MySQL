-- Business question: Review recorded fraud events whose linked ledger entry failed or was reversed.
SELECT f.fraud_event_id, f.detected_at, f.fraud_type, f.risk_score, f.action_taken,
       t.reference_code, t.transaction_time, t.status AS transaction_status,
       t.amount, t.channel, a.account_number
FROM fraud_events AS f
JOIN transactions AS t ON t.transaction_id = f.transaction_id
JOIN accounts AS a ON a.account_id = t.account_id
WHERE t.status IN ('FAILED','REVERSED')
ORDER BY f.detected_at DESC, f.risk_score DESC;
