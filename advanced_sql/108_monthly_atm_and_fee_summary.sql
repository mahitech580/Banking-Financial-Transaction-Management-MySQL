-- Business question: Track gross ATM and fee transaction amounts by month.
-- Amount is stored as positive magnitude; this report does not infer net cash impact or fee revenue recognition.
SELECT DATE_FORMAT(transaction_time,'%Y-%m') month,transaction_type,channel,status,
       COUNT(*) transaction_count,ROUND(SUM(amount),2) gross_amount
FROM transactions
WHERE transaction_type IN ('ATM','FEE')
GROUP BY DATE_FORMAT(transaction_time,'%Y-%m'),transaction_type,channel,status
ORDER BY month,transaction_type,channel,status;