-- Business question: Which successful transactions do not yet have a settlement row?
SELECT t.transaction_id, t.reference_code, t.transaction_time, t.amount, t.channel
FROM transactions t
WHERE t.status = 'SUCCESS'
  AND NOT EXISTS (
    SELECT 1 FROM settlements s WHERE s.transaction_id = t.transaction_id
  )
ORDER BY t.transaction_time DESC;