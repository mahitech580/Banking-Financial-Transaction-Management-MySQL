-- Business question: Quantify accounts held outside the customer's registered home branch.
SELECT home.branch_id AS customer_home_branch_id,
       home.branch_name AS customer_home_branch,
       account_branch.branch_id AS account_branch_id,
       account_branch.branch_name AS account_branch,
       COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(a.account_id) AS accounts,
       SUM(a.current_balance) AS current_balance
FROM customers AS c
JOIN accounts AS a ON a.customer_id = c.customer_id
LEFT JOIN branches AS home ON home.branch_id = c.branch_id
JOIN branches AS account_branch ON account_branch.branch_id = a.branch_id
WHERE c.branch_id IS NULL OR c.branch_id <> a.branch_id
GROUP BY home.branch_id, home.branch_name, account_branch.branch_id, account_branch.branch_name
ORDER BY accounts DESC, current_balance DESC;
