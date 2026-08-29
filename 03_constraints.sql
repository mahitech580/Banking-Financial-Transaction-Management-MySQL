USE banking_financial_management;
ALTER TABLE accounts ADD CONSTRAINT chk_balance CHECK (current_balance >= 0);
ALTER TABLE loans ADD CONSTRAINT chk_loan_values CHECK (principal > 0 AND interest_rate >= 0 AND tenure_months > 0);
ALTER TABLE loan_payments ADD CONSTRAINT chk_payment_values CHECK (amount_due > 0 AND amount_paid >= 0);
ALTER TABLE fraud_events ADD CONSTRAINT chk_risk_score CHECK (risk_score BETWEEN 0 AND 100);
