-- Business question: How much disputed transaction value is associated with each customer risk segment?
-- Disputed amount is a claim amount, not automatically a confirmed loss.
SELECT c.risk_level,d.status,COUNT(*) dispute_records,
       COUNT(DISTINCT c.customer_id) affected_customers,
       COUNT(DISTINCT d.transaction_id) disputed_transactions,
       ROUND(SUM(d.disputed_amount),2) gross_disputed_amount,
       ROUND(AVG(d.disputed_amount),2) average_disputed_amount,
       ROUND(AVG(TIMESTAMPDIFF(DAY,d.opened_at,CURRENT_TIMESTAMP)),2) average_case_age_days
FROM disputes d JOIN transactions t ON t.transaction_id=d.transaction_id
JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id
GROUP BY c.risk_level,d.status
ORDER BY gross_disputed_amount DESC;