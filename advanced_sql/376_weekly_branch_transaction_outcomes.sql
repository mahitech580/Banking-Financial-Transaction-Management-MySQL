-- Business question: Which branches have the highest weekly successful value, attempt volume, and failure share?
-- Grain: one ISO week and current account branch. Branch transfers or account relocations may change how historical rows are attributed.
SELECT b.branch_id, b.branch_name, YEARWEEK(t.transaction_time, 3) AS iso_year_week,
  MIN(DATE(t.transaction_time)) AS first_transaction_date_in_week,
  COUNT(*) AS attempt_count, COUNT(DISTINCT t.account_id) AS accounts_with_activity,
  SUM(t.status = 'SUCCESS') AS successful_count,
  SUM(t.status = 'FAILED') AS failed_count,
  ROUND(100.0 * SUM(t.status = 'FAILED') / NULLIF(COUNT(*), 0), 2) AS failed_attempt_share_pct,
  COALESCE(SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END), 0.00) AS successful_gross_value
FROM transactions t JOIN accounts a ON a.account_id = t.account_id
JOIN branches b ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name, YEARWEEK(t.transaction_time, 3)
ORDER BY iso_year_week DESC, successful_gross_value DESC, b.branch_id;
