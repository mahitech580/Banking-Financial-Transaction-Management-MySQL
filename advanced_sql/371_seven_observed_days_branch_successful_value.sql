-- Business question: How does successful transaction value compare with the preceding seven observed transaction-days for each branch?
-- Grain: one branch-date with activity. The window contains up to seven observed dates, not necessarily seven consecutive calendar days.
WITH branch_daily AS (
  SELECT a.branch_id, DATE(t.transaction_time) AS transaction_date,
    COUNT(*) AS attempt_count, SUM(t.status = 'SUCCESS') AS success_count,
    COALESCE(SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END), 0.00) AS successful_value
  FROM accounts a JOIN transactions t ON t.account_id = a.account_id
  GROUP BY a.branch_id, DATE(t.transaction_time)
),
rolling AS (
  SELECT bd.*,
    SUM(successful_value) OVER (PARTITION BY branch_id ORDER BY transaction_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS successful_value_last_seven_observed_days,
    COUNT(*) OVER (PARTITION BY branch_id ORDER BY transaction_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS observed_days_in_window
  FROM branch_daily bd
)
SELECT branch_id, transaction_date, attempt_count, success_count, successful_value,
  observed_days_in_window, successful_value_last_seven_observed_days,
  ROUND(successful_value_last_seven_observed_days / NULLIF(observed_days_in_window, 0), 2)
    AS average_successful_value_per_observed_day
FROM rolling
ORDER BY branch_id, transaction_date DESC;
