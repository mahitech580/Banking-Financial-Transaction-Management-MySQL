-- Successful activity on accounts not currently marked active deserves operational review.
SELECT a.account_id,a.account_number,a.status account_status,COUNT(t.transaction_id) successful_transactions,MAX(t.transaction_time) latest_success_at,ROUND(SUM(t.amount),2) successful_gross_value
FROM accounts a JOIN transactions t ON t.account_id=a.account_id WHERE a.status<>'ACTIVE' AND t.status='SUCCESS'
GROUP BY a.account_id,a.account_number,a.status ORDER BY successful_gross_value DESC;