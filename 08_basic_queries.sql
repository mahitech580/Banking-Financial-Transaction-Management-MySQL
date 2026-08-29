USE banking_financial_management;
SELECT COUNT(*) AS customers FROM customers;
SELECT account_type, COUNT(*) AS accounts, SUM(current_balance) AS total_balance FROM accounts GROUP BY account_type;
SELECT status, COUNT(*) AS transaction_count, SUM(amount) AS transaction_value FROM transactions GROUP BY status;
SELECT channel, COUNT(*) AS transactions, SUM(amount) AS value FROM transactions GROUP BY channel ORDER BY value DESC;
