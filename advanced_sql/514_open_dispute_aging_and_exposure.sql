-- Business question: Review unresolved disputes by age band and source transaction channel.
SELECT t.channel,
       CASE WHEN TIMESTAMPDIFF(DAY, d.opened_at, CURRENT_TIMESTAMP) < 7 THEN 'UNDER_7_DAYS'
            WHEN TIMESTAMPDIFF(DAY, d.opened_at, CURRENT_TIMESTAMP) < 30 THEN '7_TO_29_DAYS'
            WHEN TIMESTAMPDIFF(DAY, d.opened_at, CURRENT_TIMESTAMP) < 90 THEN '30_TO_89_DAYS'
            ELSE '90_DAYS_PLUS' END AS open_age_band,
       COUNT(*) AS open_dispute_count,
       SUM(d.disputed_amount) AS disputed_value,
       MIN(d.opened_at) AS oldest_opened_at
FROM disputes AS d
JOIN transactions AS t ON t.transaction_id = d.transaction_id
WHERE d.status = 'OPEN'
GROUP BY t.channel, open_age_band
ORDER BY disputed_value DESC;
