-- Business question: Track weekly successful ledger value, activity coverage and failure rates by branch and channel.
SELECT b.branch_id,b.branch_name,YEARWEEK(t.transaction_time,3) iso_year_week,t.channel,
       COUNT(*) attempts,COUNT(DISTINCT a.account_id) accounts_with_attempts,
       COUNT(DISTINCT CASE WHEN t.status='SUCCESS' THEN a.customer_id END) customers_with_success,
       SUM(t.status='SUCCESS') successes,SUM(t.status='FAILED') failures,
       ROUND(100*SUM(t.status='SUCCESS')/NULLIF(COUNT(*),0),2) success_rate_pct,
       ROUND(SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END),2) successful_value
FROM transactions t JOIN accounts a ON a.account_id=t.account_id
JOIN branches b ON b.branch_id=a.branch_id
GROUP BY b.branch_id,b.branch_name,YEARWEEK(t.transaction_time,3),t.channel
ORDER BY iso_year_week,b.branch_name,t.channel;