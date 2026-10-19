-- Business question: Which settlement amounts differ from their linked transaction amounts?
-- Legitimate fees, currency conversion, partial settlement, or posting rules may explain differences.
SELECT s.settlement_id,s.transaction_id,t.reference_code,s.status,s.settlement_amount,t.amount transaction_amount,
       ROUND(s.settlement_amount-t.amount,2) amount_difference,
       ROUND(100*(s.settlement_amount-t.amount)/NULLIF(t.amount,0),2) variance_pct
FROM settlements s JOIN transactions t ON t.transaction_id=s.transaction_id
WHERE ABS(s.settlement_amount-t.amount)>=0.01
ORDER BY ABS(s.settlement_amount-t.amount) DESC,s.settlement_id;