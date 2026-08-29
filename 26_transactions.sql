USE banking_financial_management;
START TRANSACTION;
UPDATE accounts SET current_balance=current_balance-1000 WHERE account_id=1;
UPDATE accounts SET current_balance=current_balance+1000 WHERE account_id=2;
COMMIT;
