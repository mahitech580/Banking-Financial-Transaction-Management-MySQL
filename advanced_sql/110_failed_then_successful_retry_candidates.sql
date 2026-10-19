-- Business question: Find a failed attempt followed by a same-account, same-amount success within 24 hours.
-- This identifies possible retry patterns, not confirmed duplicate processing.
SELECT f.account_id,f.transaction_id failed_transaction_id,s.transaction_id successful_transaction_id,
       f.amount,f.channel failed_channel,s.channel successful_channel,
       f.transaction_time failed_at,s.transaction_time succeeded_at,
       TIMESTAMPDIFF(MINUTE,f.transaction_time,s.transaction_time) minutes_to_success
FROM transactions f JOIN transactions s
  ON s.account_id=f.account_id AND s.amount=f.amount
 AND s.status='SUCCESS' AND s.transaction_time>f.transaction_time
 AND s.transaction_time<=f.transaction_time+INTERVAL 24 HOUR
WHERE f.status='FAILED'
ORDER BY minutes_to_success,f.account_id LIMIT 200;