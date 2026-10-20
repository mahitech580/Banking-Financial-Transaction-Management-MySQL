-- Business question: How old are unsettled records, and where is their value concentrated?
SELECT t.channel, s.status,
       CASE WHEN s.settled_at IS NOT NULL THEN 'SETTLEMENT_TIMESTAMP_PRESENT'
            WHEN TIMESTAMPDIFF(HOUR, t.transaction_time, CURRENT_TIMESTAMP) < 24 THEN 'UNDER_24_HOURS'
            WHEN TIMESTAMPDIFF(HOUR, t.transaction_time, CURRENT_TIMESTAMP) < 72 THEN '24_TO_72_HOURS'
            WHEN TIMESTAMPDIFF(HOUR, t.transaction_time, CURRENT_TIMESTAMP) < 168 THEN '3_TO_7_DAYS'
            ELSE 'OVER_7_DAYS' END AS settlement_age_band,
       COUNT(*) AS settlement_rows,
       SUM(s.settlement_amount) AS settlement_value
FROM settlements AS s
JOIN transactions AS t ON t.transaction_id = s.transaction_id
WHERE s.status <> 'SETTLED' OR s.settled_at IS NULL
GROUP BY t.channel, s.status, settlement_age_band
ORDER BY settlement_value DESC;
