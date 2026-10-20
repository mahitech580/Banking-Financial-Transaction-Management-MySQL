-- Business question: Compare branch balances across customers' stored risk classifications.
SELECT b.branch_id, b.branch_name, c.risk_level,
       COUNT(DISTINCT c.customer_id) AS customer_count,
       COUNT(a.account_id) AS account_count,
       SUM(a.current_balance) AS total_balance,
       SUM(a.status = 'ACTIVE') AS active_accounts,
       ROUND(AVG(a.current_balance), 2) AS average_balance
FROM branches AS b
LEFT JOIN customers AS c ON c.branch_id = b.branch_id
LEFT JOIN accounts AS a ON a.customer_id = c.customer_id
GROUP BY b.branch_id, b.branch_name, c.risk_level
ORDER BY b.branch_name, total_balance DESC;
