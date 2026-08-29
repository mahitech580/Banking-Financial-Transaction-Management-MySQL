USE banking_financial_management;
SELECT loan_type,COUNT(*) loans,SUM(principal) principal,AVG(interest_rate) avg_rate,AVG(tenure_months) avg_tenure FROM loans GROUP BY loan_type;
SELECT status,COUNT(*) installments,SUM(amount_due) due,SUM(amount_paid) paid FROM loan_payments GROUP BY status;
