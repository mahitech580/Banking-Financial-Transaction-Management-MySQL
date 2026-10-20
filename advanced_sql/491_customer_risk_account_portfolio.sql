-- Business question: Compare customer account counts and balance exposure by stored risk label.
SELECT c.risk_level, a.account_type, a.status AS account_status,
       COUNT(*) AS account_count,
       COUNT(DISTINCT c.customer_id) AS customer_count,
       SUM(a.current_balance) AS balance_exposure,
       ROUND(AVG(a.current_balance), 2) AS average_account_balance
FROM customers AS c
JOIN accounts AS a ON a.customer_id = c.customer_id
GROUP BY c.risk_level, a.account_type, a.status
ORDER BY balance_exposure DESC;
