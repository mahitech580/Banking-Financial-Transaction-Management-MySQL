-- Business question: How does successful credit-minus-debit flow evolve by customer and quarter?
SELECT c.customer_id,c.customer_number,
       YEAR(t.transaction_time) activity_year,QUARTER(t.transaction_time) activity_quarter,
       SUM(CASE WHEN t.transaction_type='CREDIT' THEN t.amount
                WHEN t.transaction_type='DEBIT' THEN -t.amount ELSE 0 END) net_flow,
       SUM(t.transaction_type='CREDIT') credit_count,
       SUM(t.transaction_type='DEBIT') debit_count,
       COUNT(*) successful_ledger_rows
FROM customers c
JOIN accounts a ON a.customer_id=c.customer_id
JOIN transactions t ON t.account_id=a.account_id AND t.status='SUCCESS'
WHERE t.transaction_type IN ('CREDIT','DEBIT')
GROUP BY c.customer_id,c.customer_number,YEAR(t.transaction_time),QUARTER(t.transaction_time)
ORDER BY c.customer_id,activity_year,activity_quarter;