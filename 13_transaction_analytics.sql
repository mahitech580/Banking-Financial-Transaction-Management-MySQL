USE banking_financial_management;
SELECT DATE(transaction_time) transaction_date,COUNT(*) transaction_count,SUM(amount) total_value,AVG(amount) avg_value FROM transactions WHERE status='SUCCESS' GROUP BY DATE(transaction_time) ORDER BY transaction_date;
SELECT HOUR(transaction_time) hour_of_day,COUNT(*) transaction_count,SUM(amount) value FROM transactions GROUP BY HOUR(transaction_time) ORDER BY value DESC;
SELECT transaction_type,COUNT(*) count,SUM(amount) value,AVG(amount) average_amount FROM transactions GROUP BY transaction_type;
