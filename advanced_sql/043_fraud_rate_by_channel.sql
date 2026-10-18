-- Business question: Which channels have the highest share of transactions linked to fraud events?
SELECT t.channel,
       COUNT(DISTINCT t.transaction_id) AS transactions,
       COUNT(DISTINCT f.transaction_id) AS flagged_transactions,
       ROUND(100 * COUNT(DISTINCT f.transaction_id) / NULLIF(COUNT(DISTINCT t.transaction_id), 0), 2) AS flagged_pct
FROM transactions t
LEFT JOIN fraud_events f ON f.transaction_id = t.transaction_id
GROUP BY t.channel
ORDER BY flagged_pct DESC, transactions DESC;