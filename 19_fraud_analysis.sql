USE banking_financial_management;
SELECT fraud_type,COUNT(*) incidents,AVG(risk_score) avg_risk,MAX(risk_score) max_risk FROM fraud_events GROUP BY fraud_type ORDER BY avg_risk DESC;
SELECT t.transaction_id,t.amount,f.fraud_type,f.risk_score,f.action_taken FROM fraud_events f JOIN transactions t ON t.transaction_id=f.transaction_id ORDER BY f.risk_score DESC;
