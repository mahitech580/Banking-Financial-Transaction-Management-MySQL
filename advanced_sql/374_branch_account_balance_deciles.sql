-- Business question: How are stored account balances distributed across deciles within each branch and account type?
-- Grain: one branch/type/decile bucket. Deciles are relative rankings, not suitability or risk classifications.
WITH ranked_balances AS (
  SELECT a.branch_id, a.account_type, a.account_id, a.status, a.current_balance,
    NTILE(10) OVER (PARTITION BY a.branch_id, a.account_type ORDER BY a.current_balance, a.account_id) AS balance_decile
  FROM accounts a
)
SELECT branch_id, account_type, balance_decile, COUNT(*) AS account_count,
  SUM(status = 'ACTIVE') AS active_accounts,
  ROUND(AVG(current_balance), 2) AS average_balance,
  MIN(current_balance) AS minimum_balance, MAX(current_balance) AS maximum_balance,
  SUM(current_balance) AS total_balance
FROM ranked_balances
GROUP BY branch_id, account_type, balance_decile
ORDER BY branch_id, account_type, balance_decile;
