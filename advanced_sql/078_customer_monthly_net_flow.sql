-- Successful credit/debit flow per customer and month; non-success rows do not affect net flow.
SELECT c.customer_id,c.customer_number,DATE_FORMAT(t.transaction_time,'%Y-%m') month,
SUM(CASE WHEN t.status='SUCCESS' AND t.transaction_type='CREDIT' THEN t.amount ELSE 0 END) successful_credits,
SUM(CASE WHEN t.status='SUCCESS' AND t.transaction_type='DEBIT' THEN t.amount ELSE 0 END) successful_debits,
SUM(CASE WHEN t.status='SUCCESS' AND t.transaction_type='CREDIT' THEN t.amount WHEN t.status='SUCCESS' AND t.transaction_type='DEBIT' THEN -t.amount ELSE 0 END) net_flow
FROM customers c JOIN accounts a ON a.customer_id=c.customer_id JOIN transactions t ON t.account_id=a.account_id
GROUP BY c.customer_id,c.customer_number,DATE_FORMAT(t.transaction_time,'%Y-%m') ORDER BY c.customer_id,month;