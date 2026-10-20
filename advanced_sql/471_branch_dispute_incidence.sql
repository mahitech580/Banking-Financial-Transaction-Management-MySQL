-- Business question: Compare dispute counts and values relative to ledger activity by account branch.
WITH ledger AS (
  SELECT a.branch_id, COUNT(*) AS transaction_count,
         SUM(t.amount) AS attempted_value
  FROM accounts AS a
  JOIN transactions AS t ON t.account_id = a.account_id
  GROUP BY a.branch_id
), dispute_totals AS (
  SELECT a.branch_id, COUNT(d.dispute_id) AS dispute_count,
         SUM(d.disputed_amount) AS disputed_value
  FROM accounts AS a
  JOIN transactions AS t ON t.account_id = a.account_id
  JOIN disputes AS d ON d.transaction_id = t.transaction_id
  GROUP BY a.branch_id
)
SELECT b.branch_name, COALESCE(l.transaction_count, 0) AS transaction_count,
       COALESCE(d.dispute_count, 0) AS dispute_count,
       COALESCE(d.disputed_value, 0) AS disputed_value,
       ROUND(100.0 * COALESCE(d.dispute_count, 0) / NULLIF(l.transaction_count, 0), 2) AS dispute_rows_per_transaction_pct,
       COALESCE(l.attempted_value, 0) AS attempted_value
FROM branches AS b
LEFT JOIN ledger AS l ON l.branch_id = b.branch_id
LEFT JOIN dispute_totals AS d ON d.branch_id = b.branch_id
ORDER BY disputed_value DESC;
