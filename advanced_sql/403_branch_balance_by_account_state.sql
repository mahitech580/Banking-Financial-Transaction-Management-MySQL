-- Business question: Compare the count and balance of accounts in each state by branch.
SELECT b.branch_id, b.branch_name, a.status AS account_status,
       COUNT(*) AS account_count,
       SUM(a.current_balance) AS total_balance,
       ROUND(AVG(a.current_balance), 2) AS average_balance
FROM branches AS b
JOIN accounts AS a ON a.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name, a.status
ORDER BY b.branch_name, a.status;
