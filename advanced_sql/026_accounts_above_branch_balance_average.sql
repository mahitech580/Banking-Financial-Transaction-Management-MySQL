-- Business question: Which accounts have balances above their branch average?
WITH account_branch AS (
  SELECT a.account_id, a.account_number, a.current_balance, b.branch_name,
         AVG(a.current_balance) OVER (PARTITION BY a.branch_id) AS branch_average
  FROM accounts a JOIN branches b ON b.branch_id = a.branch_id
)
SELECT account_number, branch_name, current_balance,
       ROUND(branch_average, 2) AS branch_average
FROM account_branch
WHERE current_balance > branch_average
ORDER BY branch_name, current_balance DESC;