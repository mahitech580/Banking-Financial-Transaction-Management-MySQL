USE banking_financial_management;
SELECT status,COUNT(*) payment_count,SUM(amount_paid) paid_amount FROM loan_payments GROUP BY status;
