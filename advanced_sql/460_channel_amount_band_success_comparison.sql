-- Business question: Compare transaction success rates across channel-specific amount bands.
SELECT channel,
       CASE WHEN amount < 100 THEN 'UNDER_100'
            WHEN amount < 1000 THEN '100_TO_999'
            WHEN amount < 10000 THEN '1000_TO_9999'
            ELSE '10000_PLUS' END AS amount_band,
       status, COUNT(*) AS attempts,
       SUM(amount) AS attempted_value,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(100.0 * SUM(status = 'SUCCESS') / COUNT(*), 2) AS success_rate_pct
FROM transactions
GROUP BY channel, amount_band, status
ORDER BY channel, amount_band, status;
