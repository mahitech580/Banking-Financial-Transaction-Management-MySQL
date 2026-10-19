-- Descriptive activity distribution by assigned customer risk label; not a lending or fraud decision.
SELECT c.risk_level,COUNT(DISTINCT c.customer_id) customers,COUNT(DISTINCT a.account_id) accounts,COUNT(t.transaction_id) successful_transactions,
ROUND(COALESCE(SUM(t.amount),0),2) successful_value
FROM customers c LEFT JOIN accounts a ON a.customer_id=c.customer_id LEFT JOIN transactions t ON t.account_id=a.account_id AND t.status='SUCCESS'
GROUP BY c.risk_level ORDER BY FIELD(c.risk_level,'LOW','MEDIUM','HIGH');