-- Business question: Compare disputed value against original transaction value across dispute reasons.
SELECT d.reason, d.status,
       COUNT(*) AS dispute_count,
       SUM(d.disputed_amount) AS disputed_value,
       SUM(t.amount) AS source_transaction_value,
       ROUND(100.0 * SUM(d.disputed_amount) / NULLIF(SUM(t.amount), 0), 2) AS aggregate_dispute_ratio_pct,
       ROUND(AVG(100.0 * d.disputed_amount / NULLIF(t.amount, 0)), 2) AS average_row_dispute_ratio_pct
FROM disputes AS d
JOIN transactions AS t ON t.transaction_id = d.transaction_id
GROUP BY d.reason, d.status
ORDER BY disputed_value DESC;
