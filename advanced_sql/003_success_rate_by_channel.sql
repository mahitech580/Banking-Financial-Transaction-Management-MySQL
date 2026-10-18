-- Business question: Which channels have the highest success rate?
SELECT channel, COUNT(*) AS attempts,
       SUM(status = 'SUCCESS') AS successes,
       SUM(status = 'FAILED') AS failures,
       ROUND(100 * SUM(status = 'SUCCESS') / NULLIF(COUNT(*), 0), 2) AS success_rate_pct
FROM transactions
GROUP BY channel
ORDER BY success_rate_pct DESC, attempts DESC;