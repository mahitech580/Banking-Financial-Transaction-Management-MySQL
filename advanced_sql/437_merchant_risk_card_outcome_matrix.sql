-- Business question: Review card-payment outcomes across merchant risk classifications.
SELECT m.risk_level, m.merchant_category, ct.channel, ct.status,
       COUNT(*) AS card_attempts,
       SUM(ct.amount) AS attempted_value,
       SUM(CASE WHEN ct.status = 'SUCCESS' THEN ct.amount ELSE 0 END) AS successful_value,
       ROUND(100.0 * SUM(ct.status = 'SUCCESS') / COUNT(*), 2) AS success_rate_pct
FROM card_transactions AS ct
JOIN merchants AS m ON m.merchant_id = ct.merchant_id
GROUP BY m.risk_level, m.merchant_category, ct.channel, ct.status
ORDER BY m.risk_level, card_attempts DESC;
