USE banking_financial_management;
SELECT account_number,current_balance FROM accounts WHERE current_balance > (SELECT AVG(current_balance) FROM accounts);
SELECT c.customer_id, c.first_name,c.last_name FROM customers c WHERE c.customer_id IN (SELECT customer_id FROM loans WHERE status='ACTIVE');
SELECT m.merchant_id,m.merchant_name FROM merchants m WHERE EXISTS (SELECT 1 FROM transactions t WHERE t.merchant_id=m.merchant_id AND t.amount > 50000);
