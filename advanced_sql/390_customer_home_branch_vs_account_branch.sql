-- Business question: How many customer accounts are held at the customer's recorded home branch versus other branches?
-- Grain: one home-branch/account-branch pairing. Cross-branch banking is valid; the report describes distribution rather than an error.
SELECT c.branch_id AS customer_home_branch_id, home.branch_name AS customer_home_branch,
  a.branch_id AS account_branch_id, account_branch.branch_name AS account_branch,
  CASE WHEN c.branch_id IS NULL THEN 'HOME_BRANCH_NOT_RECORDED'
    WHEN c.branch_id = a.branch_id THEN 'SAME_BRANCH'
    ELSE 'CROSS_BRANCH' END AS branch_relationship,
  COUNT(*) AS account_count, COUNT(DISTINCT c.customer_id) AS customer_count,
  SUM(a.status = 'ACTIVE') AS active_account_count,
  SUM(a.current_balance) AS stored_balance_total
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
LEFT JOIN branches home ON home.branch_id = c.branch_id
JOIN branches account_branch ON account_branch.branch_id = a.branch_id
GROUP BY c.branch_id, home.branch_name, a.branch_id, account_branch.branch_name, branch_relationship
ORDER BY account_count DESC, customer_home_branch_id, account_branch_id;
