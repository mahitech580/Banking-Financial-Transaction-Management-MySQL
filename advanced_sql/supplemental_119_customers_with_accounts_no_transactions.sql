-- Business question: Which customers have one or more accounts but no transaction attempts recorded?
SELECT c.customer_id,c.customer_number,CONCAT(c.first_name,' ',c.last_name) customer_name,
       COUNT(DISTINCT a.account_id) account_count,MIN(a.opened_at) earliest_account_opened_at
FROM customers c JOIN accounts a ON a.customer_id=c.customer_id
LEFT JOIN transactions t ON t.account_id=a.account_id
GROUP BY c.customer_id,c.customer_number,c.first_name,c.last_name
HAVING COUNT(t.transaction_id)=0
ORDER BY earliest_account_opened_at,c.customer_id;