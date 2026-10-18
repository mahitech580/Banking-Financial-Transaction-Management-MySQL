-- Business question: Which transaction types contribute to successful transaction volume?
SELECT transaction_type,
       COUNT(*) AS total_rows,
       SUM(status = 'SUCCESS') AS successes,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(100 * SUM(status = 'SUCCESS') / NULLIF(COUNT(*), 0), 2) AS success_pct
FROM transactions
GROUP BY transaction_type
ORDER BY successful_value DESC;