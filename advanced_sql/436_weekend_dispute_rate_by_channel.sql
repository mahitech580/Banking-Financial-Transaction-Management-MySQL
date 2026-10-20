-- Business question: Compare dispute volume and disputed value across the weekday of the source transaction.
SELECT t.channel,
       CASE WHEN DAYOFWEEK(t.transaction_time) IN (1, 7) THEN 'WEEKEND' ELSE 'WEEKDAY' END AS transaction_day_type,
       COUNT(DISTINCT t.transaction_id) AS transaction_count,
       COUNT(DISTINCT d.dispute_id) AS dispute_count,
       COALESCE(SUM(d.disputed_amount), 0) AS disputed_value,
       ROUND(100.0 * COUNT(DISTINCT d.dispute_id) / NULLIF(COUNT(DISTINCT t.transaction_id), 0), 2) AS disputes_per_transaction_pct
FROM transactions AS t
LEFT JOIN disputes AS d ON d.transaction_id = t.transaction_id
GROUP BY t.channel, transaction_day_type
ORDER BY disputes_per_transaction_pct DESC, disputed_value DESC;
