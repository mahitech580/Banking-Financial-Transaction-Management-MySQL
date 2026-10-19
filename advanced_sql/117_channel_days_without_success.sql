-- Business question: Which observed channel-days had transaction attempts but no successful outcomes?
SELECT DATE(transaction_time) activity_date,channel,COUNT(*) attempts,
       SUM(status='FAILED') failures,SUM(status='PENDING') pending,SUM(status='REVERSED') reversed_count,
       ROUND(SUM(amount),2) attempted_gross_amount
FROM transactions
GROUP BY DATE(transaction_time),channel
HAVING SUM(status='SUCCESS')=0
ORDER BY activity_date,attempts DESC;