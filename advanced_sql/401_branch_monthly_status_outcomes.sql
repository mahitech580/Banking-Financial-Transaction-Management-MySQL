-- Business question: How do transaction outcomes and successful value change by branch and month?
SELECT b.branch_id, b.branch_name, DATE_FORMAT(t.transaction_time, '%Y-%m') AS transaction_month,
       t.status, COUNT(*) AS attempts,
       SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value,
       ROUND(100.0 * SUM(t.status = 'SUCCESS') / COUNT(*), 2) AS success_rate_pct
FROM transactions AS t
JOIN accounts AS a ON a.account_id = t.account_id
JOIN branches AS b ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name, DATE_FORMAT(t.transaction_time, '%Y-%m'), t.status
ORDER BY transaction_month DESC, b.branch_name, t.status;
