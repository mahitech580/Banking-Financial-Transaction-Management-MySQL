-- Business question: How many accounts does each customer hold outside their recorded primary branch?
-- Accounts at other branches may be valid; this report describes cross-branch usage.
SELECT c.customer_id,c.customer_number,c.branch_id AS customer_primary_branch_id,
       a.branch_id AS account_branch_id,b.branch_name AS account_branch_name,
       COUNT(*) account_count,ROUND(SUM(a.current_balance),2) stored_balance
FROM customers c
JOIN accounts a ON a.customer_id=c.customer_id
JOIN branches b ON b.branch_id=a.branch_id
WHERE c.branch_id IS NOT NULL AND c.branch_id<>a.branch_id
GROUP BY c.customer_id,c.customer_number,c.branch_id,a.branch_id,b.branch_name
ORDER BY account_count DESC,stored_balance DESC,c.customer_id;