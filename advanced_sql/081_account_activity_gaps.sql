-- Largest gaps between consecutive transactions on an account.
WITH ordered AS (SELECT account_id,transaction_id,transaction_time,amount,status,LAG(transaction_time) OVER(PARTITION BY account_id ORDER BY transaction_time,transaction_id) previous_time FROM transactions)
SELECT account_id,transaction_id,previous_time,transaction_time,TIMESTAMPDIFF(HOUR,previous_time,transaction_time) gap_hours,amount,status
FROM ordered WHERE previous_time IS NOT NULL ORDER BY gap_hours DESC,account_id LIMIT 100;