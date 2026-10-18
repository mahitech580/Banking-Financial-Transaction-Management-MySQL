-- Business question: Which successful transactions took place between midnight and 5 AM?
SELECT t.transaction_id, t.reference_code, t.account_id, t.transaction_type,
       t.amount, t.transaction_time, t.channel
FROM transactions t
WHERE t.status = 'SUCCESS'
  AND (HOUR(t.transaction_time) >= 0 AND HOUR(t.transaction_time) < 5)
ORDER BY t.transaction_time;