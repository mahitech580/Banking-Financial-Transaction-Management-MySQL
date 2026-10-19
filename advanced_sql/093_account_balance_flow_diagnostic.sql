-- Compare stored balances with successful credit/debit net flow; opening balances and transfer semantics may explain differences.
WITH flow AS (SELECT account_id,SUM(CASE WHEN status='SUCCESS' AND transaction_type='CREDIT' THEN amount WHEN status='SUCCESS' AND transaction_type='DEBIT' THEN -amount ELSE 0 END) net_flow FROM transactions GROUP BY account_id)
SELECT a.account_id,a.account_number,a.current_balance,COALESCE(f.net_flow,0) ledger_net_flow,
ROUND(a.current_balance-COALESCE(f.net_flow,0),2) difference
FROM accounts a LEFT JOIN flow f ON f.account_id=a.account_id
WHERE ABS(a.current_balance-COALESCE(f.net_flow,0))>=0.01 ORDER BY ABS(a.current_balance-COALESCE(f.net_flow,0)) DESC;