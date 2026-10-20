-- Business question: Classify settlement delays for records marked settled with an actual timestamp.
SELECT t.channel,
       CASE WHEN TIMESTAMPDIFF(HOUR, t.transaction_time, s.settled_at) < 24 THEN 'UNDER_24_HOURS'
            WHEN TIMESTAMPDIFF(HOUR, t.transaction_time, s.settled_at) < 72 THEN '24_TO_71_HOURS'
            WHEN TIMESTAMPDIFF(HOUR, t.transaction_time, s.settled_at) < 168 THEN '3_TO_6_DAYS'
            ELSE '7_DAYS_PLUS' END AS settlement_lag_band,
       COUNT(*) AS settled_rows,
       SUM(s.settlement_amount) AS settled_value,
       ROUND(AVG(TIMESTAMPDIFF(HOUR, t.transaction_time, s.settled_at)), 2) AS average_lag_hours
FROM settlements AS s
JOIN transactions AS t ON t.transaction_id = s.transaction_id
WHERE s.status = 'SETTLED' AND s.settled_at IS NOT NULL
GROUP BY t.channel, settlement_lag_band
ORDER BY t.channel, settlement_lag_band;
