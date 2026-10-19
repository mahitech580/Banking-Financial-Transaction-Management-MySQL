-- Business question: Compare stored account balance with observed successful credit/debit flow.
-- This is a diagnostic only: it does not know the original opening balance or all posting rules.
WITH ledger AS (
  SELECT account_id,
         SUM(CASE WHEN transaction_type='CREDIT' THEN amount
                  WHEN transaction_type='DEBIT' THEN -amount ELSE 0 END) observed_net_flow,
         SUM(CASE WHEN transaction_type='CREDIT' THEN amount ELSE 0 END) successful_credit_value,
         SUM(CASE WHEN transaction_type='DEBIT' THEN amount ELSE 0 END) successful_debit_value,
         COUNT(*) successful_credit_debit_count
  FROM transactions
  WHERE status='SUCCESS' AND transaction_type IN ('CREDIT','DEBIT')
  GROUP BY account_id
)
SELECT a.account_id,a.account_number,a.account_type,a.current_balance,
       COALESCE(l.observed_net_flow,0) observed_net_flow,
       ROUND(a.current_balance-COALESCE(l.observed_net_flow,0),2) unexplained_without_opening_balance,
       ROUND(COALESCE(l.successful_credit_value,0),2) successful_credit_value,
       ROUND(COALESCE(l.successful_debit_value,0),2) successful_debit_value,
       COALESCE(l.successful_credit_debit_count,0) successful_credit_debit_count
FROM accounts a LEFT JOIN ledger l ON l.account_id=a.account_id
ORDER BY ABS(a.current_balance-COALESCE(l.observed_net_flow,0)) DESC,a.account_id;