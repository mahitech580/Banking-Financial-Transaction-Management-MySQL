USE banking_financial_management;
SELECT c.customer_number, CONCAT(c.first_name,' ',c.last_name) AS customer_name, a.account_number, a.account_type, a.current_balance FROM customers c JOIN accounts a ON a.customer_id=c.customer_id ORDER BY c.customer_id;
SELECT t.transaction_id, a.account_number, CONCAT(c.first_name,' ',c.last_name) customer_name, m.merchant_name, t.amount, t.transaction_time FROM transactions t JOIN accounts a ON a.account_id=t.account_id JOIN customers c ON c.customer_id=a.customer_id LEFT JOIN merchants m ON m.merchant_id=t.merchant_id;
