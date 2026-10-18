-- Business question: Which settlements do not match their linked transaction amount?
SELECT s.settlement_id, s.status, s.settlement_amount,
       t.transaction_id, t.reference_code, t.amount AS transaction_amount,
       s.settlement_amount - t.amount AS amount_difference
FROM settlements s
JOIN transactions t ON t.transaction_id = s.transaction_id
WHERE s.settlement_amount <> t.amount
ORDER BY ABS(s.settlement_amount - t.amount) DESC;