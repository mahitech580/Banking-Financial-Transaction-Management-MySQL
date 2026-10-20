-- Business question: Which branches show the largest week-over-week change in successful transaction value?
WITH weekly AS (
  SELECT a.branch_id, YEARWEEK(t.transaction_time, 3) AS iso_year_week,
         SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value,
         COUNT(*) AS attempts
  FROM transactions AS t
  JOIN accounts AS a ON a.account_id = t.account_id
  GROUP BY a.branch_id, YEARWEEK(t.transaction_time, 3)
),
compared AS (
  SELECT weekly.*,
         LAG(successful_value) OVER (PARTITION BY branch_id ORDER BY iso_year_week) AS prior_week_value
  FROM weekly
)
SELECT b.branch_name, iso_year_week, attempts, successful_value, prior_week_value,
       successful_value - prior_week_value AS absolute_change,
       ROUND(100.0 * (successful_value - prior_week_value) / NULLIF(prior_week_value, 0), 2) AS percent_change
FROM compared
JOIN branches AS b ON b.branch_id = compared.branch_id
ORDER BY iso_year_week DESC, ABS(successful_value - COALESCE(prior_week_value, 0)) DESC;
