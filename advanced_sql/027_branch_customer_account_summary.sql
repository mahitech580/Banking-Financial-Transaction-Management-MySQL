-- Business question: How many customers, accounts, and account balances does each branch support?
-- Aggregate customers and accounts independently to prevent join fan-out from inflating balances.
SELECT b.branch_id, b.branch_code, b.branch_name, b.city, b.state,
       COALESCE(c.customer_count, 0) AS customers,
       COALESCE(a.account_count, 0) AS accounts,
       COALESCE(a.total_balance, 0) AS total_balance
FROM branches AS b
LEFT JOIN (
  SELECT branch_id, COUNT(*) AS customer_count
  FROM customers
  GROUP BY branch_id
) AS c ON c.branch_id = b.branch_id
LEFT JOIN (
  SELECT branch_id,
         COUNT(*) AS account_count,
         SUM(current_balance) AS total_balance
  FROM accounts
  GROUP BY branch_id
) AS a ON a.branch_id = b.branch_id
ORDER BY customers DESC, accounts DESC, b.branch_id;
