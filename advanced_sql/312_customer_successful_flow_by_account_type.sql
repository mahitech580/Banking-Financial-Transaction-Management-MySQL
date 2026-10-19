-- Business question: Compare customer successful credits and debits by account type and quarter.
SELECT a.account_type,YEAR(t.transaction_time) activity_year,QUARTER(t.transaction_time) activity_quarter,
       COUNT(DISTINCT c.customer_id) active_customers,COUNT(*) successful_transactions,
       SUM(CASE WHEN t.transaction_type='CREDIT' THEN t.amount ELSE 0 END) credit_value,
       SUM(CASE WHEN t.transaction_type='DEBIT' THEN t.amount ELSE 0 END) debit_value,
       SUM(CASE WHEN t.transaction_type='CREDIT' THEN t.amount
                WHEN t.transaction_type='DEBIT' THEN -t.amount ELSE 0 END) net_flow
FROM transactions t JOIN accounts a ON a.account_id=t.account_id
JOIN customers c ON c.customer_id=a.customer_id
WHERE t.status='SUCCESS' AND t.transaction_type IN ('CREDIT','DEBIT')
GROUP BY a.account_type,YEAR(t.transaction_time),QUARTER(t.transaction_time)
ORDER BY activity_year,activity_quarter,a.account_type;