-- Merchant failure rates with a minimum sample threshold; descriptive, not a fraud verdict.
SELECT m.merchant_id,m.merchant_name,m.merchant_category,m.risk_level,COUNT(t.transaction_id) attempts,
SUM(t.status='FAILED') failures,ROUND(100*SUM(t.status='FAILED')/NULLIF(COUNT(t.transaction_id),0),2) failure_rate_pct
FROM merchants m JOIN transactions t ON t.merchant_id=m.merchant_id
GROUP BY m.merchant_id,m.merchant_name,m.merchant_category,m.risk_level HAVING COUNT(t.transaction_id)>=3
ORDER BY failure_rate_pct DESC,attempts DESC;