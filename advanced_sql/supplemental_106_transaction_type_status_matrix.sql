-- Business question: How do transaction status outcomes vary by transaction type?
SELECT transaction_type,status,COUNT(*) transaction_count,
       ROUND(SUM(amount),2) gross_amount,
       ROUND(AVG(amount),2) mean_amount,
       MIN(transaction_time) first_seen,MAX(transaction_time) last_seen
FROM transactions
GROUP BY transaction_type,status
ORDER BY transaction_type,status;