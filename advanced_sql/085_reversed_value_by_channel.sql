-- Monthly reversed gross value by channel; gross reversal value is not net financial loss.
SELECT channel,DATE_FORMAT(transaction_time,'%Y-%m') month,COUNT(*) reversed_count,ROUND(SUM(amount),2) reversed_gross_value,ROUND(AVG(amount),2) average_reversed_amount
FROM transactions WHERE status='REVERSED' GROUP BY channel,DATE_FORMAT(transaction_time,'%Y-%m') ORDER BY month,reversed_gross_value DESC;