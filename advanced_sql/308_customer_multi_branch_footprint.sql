-- Business question: How many customers hold accounts across multiple branch locations?
SELECT c.customer_id,c.customer_number,c.risk_level,
       COUNT(a.account_id) account_count,COUNT(DISTINCT a.branch_id) distinct_account_branches,
       GROUP_CONCAT(DISTINCT b.branch_name ORDER BY b.branch_name SEPARATOR ', ') branch_names,
       ROUND(SUM(a.current_balance),2) aggregate_stored_balance,
       MIN(a.opened_at) first_account_opened_at,MAX(a.opened_at) latest_account_opened_at
FROM customers c JOIN accounts a ON a.customer_id=c.customer_id
JOIN branches b ON b.branch_id=a.branch_id
GROUP BY c.customer_id,c.customer_number,c.risk_level
HAVING COUNT(DISTINCT a.branch_id)>1
ORDER BY distinct_account_branches DESC,account_count DESC;