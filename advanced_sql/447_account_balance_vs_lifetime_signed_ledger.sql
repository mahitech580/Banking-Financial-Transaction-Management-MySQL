-- Business question: Compare current account balances to the observed signed successful credit/debit ledger flow.
-- This is a diagnostic comparison, not a proof of an error; opening balances may predate the ledger.
WITH signed_ledger AS (
  SELECT account_id,
         SUM(CASE WHEN transaction_type = 'CREDIT' THEN amount
                  WHEN transaction_type = 'DEBIT' THEN -amount ELSE 0 END) AS lifetime_signed_flow,
         COUNT(*) AS successful_entries
  FROM transactions
  WHERE status = 'SUCCESS' AND transaction_type IN ('CREDIT', 'DEBIT')
  GROUP BY account_id
)
SELECT a.account_number, a.current_balance,
       COALESCE(s.lifetime_signed_flow, 0) AS lifetime_signed_flow,
       a.current_balance - COALESCE(s.lifetime_signed_flow, 0) AS balance_minus_observed_flow,
       COALESCE(s.successful_entries, 0) AS successful_entries,
       'RECONCILE_OPENING_BALANCE_BEFORE_INTERPRETING' AS interpretation_note
FROM accounts AS a
LEFT JOIN signed_ledger AS s ON s.account_id = a.account_id
ORDER BY ABS(a.current_balance - COALESCE(s.lifetime_signed_flow, 0)) DESC;
