-- Business question: Find same-account, same-amount transaction pairs within five minutes for operational review.
-- Matching amounts and short intervals are not proof of duplicate posting or fraud.
SELECT t1.account_id,t1.transaction_id first_transaction_id,t2.transaction_id second_transaction_id,
       t1.amount,t1.status first_status,t2.status second_status,
       t1.transaction_time first_time,t2.transaction_time second_time,
       TIMESTAMPDIFF(SECOND,t1.transaction_time,t2.transaction_time) seconds_apart
FROM transactions t1 JOIN transactions t2
  ON t2.account_id=t1.account_id AND t2.transaction_id>t1.transaction_id
 AND t2.amount=t1.amount
 AND t2.transaction_time>=t1.transaction_time
 AND t2.transaction_time<=t1.transaction_time+INTERVAL 5 MINUTE
ORDER BY seconds_apart,t1.account_id LIMIT 200;