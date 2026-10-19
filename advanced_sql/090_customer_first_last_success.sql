-- First and most recent successful activity for each customer, including customers without activity.
WITH activity AS (SELECT a.customer_id,MIN(t.transaction_time) first_success_at,MAX(t.transaction_time) last_success_at,COUNT(*) successful_count
FROM accounts a JOIN transactions t ON t.account_id=a.account_id WHERE t.status='SUCCESS' GROUP BY a.customer_id)
SELECT c.customer_id,c.customer_number,c.customer_since,ac.first_success_at,ac.last_success_at,COALESCE(ac.successful_count,0) successful_count
FROM customers c LEFT JOIN activity ac ON ac.customer_id=c.customer_id ORDER BY ac.last_success_at DESC,c.customer_id;