USE banking_financial_management;
SELECT account_type,AVG(current_balance) avg_balance,MIN(current_balance) min_balance,MAX(current_balance) max_balance,SUM(current_balance) total_balance FROM accounts GROUP BY account_type;
