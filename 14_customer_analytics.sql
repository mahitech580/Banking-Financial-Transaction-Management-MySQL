USE banking_financial_management;
SELECT c.customer_id,CONCAT(c.first_name,' ',c.last_name) customer,COUNT(t.transaction_id) transactions,SUM(t.amount) total_value FROM customers c JOIN accounts a ON a.customer_id=c.customer_id JOIN transactions t ON t.account_id=a.account_id WHERE t.status='SUCCESS' GROUP BY c.customer_id,customer ORDER BY total_value DESC;
