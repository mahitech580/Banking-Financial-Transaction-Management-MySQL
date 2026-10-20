-- Business question: Compare current account balances with signed successful ledger flow over 90 days.
WITH recent_flow AS (
 SELECT account_id,
        SUM(CASE WHEN transaction_type = 'CREDIT' THEN amount WHEN transaction_type = 'DEBIT' THEN -amount ELSE 0 END) AS signed_flow,
        COUNT(*) AS entry_count
 FROM transactions
 WHERE status = 'SUCCESS' AND transaction_time >= CURRENT_DATE - INTERVAL 90 DAY
   AND transaction_type IN ('CREDIT', 'DEBIT')
 GROUP BY account_id
)
SELECT a.account_number, a.current_balance, COALESCE(r.signed_flow, 0) AS signed_flow_90d,
       a.current_balance - COALESCE(r.signed_flow, 0) AS balance_minus_recent_flow,
       COALESCE(r.entry_count, 0) AS successful_entry_count
FROM accounts AS a
LEFT JOIN recent_flow AS r ON r.account_id = a.account_id
ORDER BY ABS(a.current_balance - COALESCE(r.signed_flow, 0)) DESC;
