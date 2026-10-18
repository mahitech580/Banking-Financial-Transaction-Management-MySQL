-- Business question: What was the monthly net flow from explicit CREDIT and DEBIT records?
SELECT DATE_FORMAT(transaction_time, '%Y-%m') AS month,
       SUM(CASE WHEN transaction_type = 'CREDIT' AND status = 'SUCCESS' THEN amount ELSE 0 END) AS credits,
       SUM(CASE WHEN transaction_type = 'DEBIT' AND status = 'SUCCESS' THEN amount ELSE 0 END) AS debits,
       SUM(CASE WHEN transaction_type = 'CREDIT' AND status = 'SUCCESS' THEN amount
                WHEN transaction_type = 'DEBIT' AND status = 'SUCCESS' THEN -amount ELSE 0 END) AS net_flow
FROM transactions
GROUP BY DATE_FORMAT(transaction_time, '%Y-%m')
ORDER BY month;