-- Business question: How do account-level credits, debits, and net transaction flow evolve each month?
SELECT a.account_id, a.account_number,
       DATE_FORMAT(t.transaction_time, '%Y-%m') AS transaction_month,
       SUM(CASE WHEN t.status = 'SUCCESS' AND t.transaction_type = 'CREDIT' THEN t.amount ELSE 0 END) AS successful_credits,
       SUM(CASE WHEN t.status = 'SUCCESS' AND t.transaction_type = 'DEBIT' THEN t.amount ELSE 0 END) AS successful_debits,
       SUM(CASE WHEN t.status = 'SUCCESS' AND t.transaction_type = 'CREDIT' THEN t.amount
                WHEN t.status = 'SUCCESS' AND t.transaction_type = 'DEBIT' THEN -t.amount ELSE 0 END) AS net_credit_debit_flow,
       COUNT(*) AS transaction_attempts
FROM accounts AS a
JOIN transactions AS t ON t.account_id = a.account_id
GROUP BY a.account_id, a.account_number, DATE_FORMAT(t.transaction_time, '%Y-%m')
ORDER BY a.account_id, transaction_month;
