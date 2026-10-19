-- Compare channel activity and successful value across branch portfolios.
SELECT b.branch_id,b.branch_code,b.branch_name,t.channel,COUNT(*) attempts,SUM(t.status='SUCCESS') successes,
ROUND(SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END),2) successful_value
FROM branches b JOIN accounts a ON a.branch_id=b.branch_id JOIN transactions t ON t.account_id=a.account_id
GROUP BY b.branch_id,b.branch_code,b.branch_name,t.channel ORDER BY b.branch_name,successful_value DESC;