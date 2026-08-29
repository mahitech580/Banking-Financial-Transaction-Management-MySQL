USE banking_financial_management;
WITH customer_spend AS (SELECT a.customer_id,SUM(CASE WHEN t.transaction_type='DEBIT' THEN t.amount ELSE 0 END) spend FROM accounts a JOIN transactions t ON t.account_id=a.account_id WHERE t.status='SUCCESS' GROUP BY a.customer_id) SELECT c.customer_id,CONCAT(c.first_name,' ',c.last_name) customer,spend FROM customer_spend s JOIN customers c ON c.customer_id=s.customer_id ORDER BY spend DESC;
WITH RECURSIVE months AS (SELECT 1 AS month_no UNION ALL SELECT month_no+1 FROM months WHERE month_no<12) SELECT month_no FROM months;
