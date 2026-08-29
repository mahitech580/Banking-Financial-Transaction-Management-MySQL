USE banking_financial_management;
SELECT account_id,transaction_id,amount,transaction_time,RANK() OVER(PARTITION BY account_id ORDER BY amount DESC) AS amount_rank,SUM(amount) OVER(PARTITION BY account_id ORDER BY transaction_time) AS running_value FROM transactions WHERE status='SUCCESS';
SELECT account_id,transaction_time,amount,LAG(amount) OVER(PARTITION BY account_id ORDER BY transaction_time) previous_amount,LEAD(amount) OVER(PARTITION BY account_id ORDER BY transaction_time) next_amount FROM transactions;
