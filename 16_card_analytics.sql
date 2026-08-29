USE banking_financial_management;
SELECT card_type,status,COUNT(*) card_count,SUM(credit_limit) total_limit FROM cards GROUP BY card_type,status;
