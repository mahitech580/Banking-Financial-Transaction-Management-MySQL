-- Business question: What is the rolling successful value across seven observed transaction dates?
-- ROWS counts observed dates in this result set, not calendar days with no activity.
WITH daily AS (
  SELECT DATE(transaction_time) AS activity_day,
         SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
  FROM transactions
  GROUP BY DATE(transaction_time)
)
SELECT activity_day, successful_value,
       SUM(successful_value) OVER (
         ORDER BY activity_day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) AS seven_observed_day_value
FROM daily
ORDER BY activity_day;
