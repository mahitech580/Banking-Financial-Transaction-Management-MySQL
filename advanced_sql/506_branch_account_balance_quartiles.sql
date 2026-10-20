-- Business question: Rank accounts into balance quartiles separately within each branch.
WITH ranked_balances AS (
  SELECT b.branch_id, b.branch_name, a.account_id, a.account_number,
         a.account_type, a.status, a.current_balance,
         NTILE(4) OVER (PARTITION BY b.branch_id ORDER BY a.current_balance, a.account_id) AS balance_quartile
  FROM branches AS b
  JOIN accounts AS a ON a.branch_id = b.branch_id
)
SELECT branch_id, branch_name, balance_quartile,
       COUNT(*) AS account_count,
       MIN(current_balance) AS minimum_balance,
       ROUND(AVG(current_balance), 2) AS average_balance,
       MAX(current_balance) AS maximum_balance,
       SUM(current_balance) AS total_balance
FROM ranked_balances
GROUP BY branch_id, branch_name, balance_quartile
ORDER BY branch_name, balance_quartile;
