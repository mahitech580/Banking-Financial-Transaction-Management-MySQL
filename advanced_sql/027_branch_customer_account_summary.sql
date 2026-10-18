-- Business question: How many customers and accounts does each branch support?
SELECT b.branch_id, b.branch_code, b.branch_name, b.city, b.state,
       COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(DISTINCT a.account_id) AS accounts,
       COALESCE(SUM(DISTINCT a.current_balance), 0) AS note_distinct_balance_not_reliable
FROM branches b
LEFT JOIN customers c ON c.branch_id = b.branch_id
LEFT JOIN accounts a ON a.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_code, b.branch_name, b.city, b.state
ORDER BY customers DESC, accounts DESC;