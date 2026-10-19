-- Weekly channel-level attempt and success rate, ordered by ISO week.
WITH weekly AS (SELECT channel,YEARWEEK(transaction_time,3) iso_year_week,COUNT(*) attempts,SUM(status='SUCCESS') successes,SUM(status='FAILED') failures
FROM transactions GROUP BY channel,YEARWEEK(transaction_time,3))
SELECT channel,iso_year_week,attempts,successes,failures,ROUND(100*successes/NULLIF(attempts,0),2) success_rate_pct,
successes-LAG(successes) OVER(PARTITION BY channel ORDER BY iso_year_week) success_count_change
FROM weekly ORDER BY channel,iso_year_week;