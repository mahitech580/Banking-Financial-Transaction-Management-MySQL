-- Business question: Which same-customer accounts record the same amount within ten minutes of one another?
-- These pairs may be legitimate transfers or separate purchases; neither account movement is automatically invalid.
SELECT c.customer_id,c.customer_number,
       t1.account_id first_account_id,t1.transaction_id first_transaction_id,t1.transaction_time first_time,
       t2.account_id second_account_id,t2.transaction_id second_transaction_id,t2.transaction_time second_time,
       t1.amount,t1.status first_status,t2.status second_status,
       TIMESTAMPDIFF(SECOND,t1.transaction_time,t2.transaction_time) seconds_apart
FROM transactions t1 JOIN accounts a1 ON a1.account_id=t1.account_id
JOIN transactions t2 ON t2.transaction_id>t1.transaction_id AND t2.amount=t1.amount
 AND t2.transaction_time>=t1.transaction_time
 AND t2.transaction_time<=t1.transaction_time+INTERVAL 10 MINUTE
JOIN accounts a2 ON a2.account_id=t2.account_id AND a2.customer_id=a1.customer_id AND a2.account_id<>a1.account_id
JOIN customers c ON c.customer_id=a1.customer_id
ORDER BY seconds_apart,c.customer_id LIMIT 200;