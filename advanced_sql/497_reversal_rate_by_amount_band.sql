-- Business question: Compare reversed outcomes across channel-specific transaction amount bands.
SELECT channel,
       CASE WHEN amount < 100 THEN 'UNDER_100'
            WHEN amount < 1000 THEN '100_TO_999'
            WHEN amount < 10000 THEN '1000_TO_9999'
            ELSE '10000_PLUS' END AS amount_band,
       COUNT(*) AS attempts,
       SUM(status = 'REVERSED') AS reversed_attempts,
       ROUND(100.0 * SUM(status = 'REVERSED') / COUNT(*), 2) AS reversal_share_pct,
       SUM(CASE WHEN status = 'REVERSED' THEN amount ELSE 0 END) AS reversed_value
FROM transactions
GROUP BY channel, amount_band
ORDER BY reversal_share_pct DESC, reversed_value DESC;
