-- Seed balances equal the net result of the successful ledger entries in 07_transaction_data.sql.
-- Failed, pending, and reversed attempts do not change the account balance.
USE banking_financial_management;

INSERT INTO accounts
  (account_number, customer_id, branch_id, account_type, opened_at, status, current_balance)
VALUES
  ('SB100001',1,1,'SAVINGS','2022-01-10','ACTIVE',29800.00),
  ('SB100002',2,1,'SAVINGS','2021-06-15','ACTIVE',67500.00),
  ('CA100003',3,2,'CURRENT','2020-03-22','ACTIVE',98000.00),
  ('SB100004',4,3,'SAVINGS','2023-04-09','ACTIVE',33800.00),
  ('CA100005',5,1,'BUSINESS','2019-09-01','ACTIVE',152000.00),
  ('SB100006',6,1,'SALARY','2024-02-11','ACTIVE',52800.00),
  ('SB100007',7,2,'SAVINGS','2020-11-19','ACTIVE',17000.00),
  ('SB100008',8,3,'SAVINGS','2024-05-05','ACTIVE',25500.00),
  ('SB100009',9,1,'SAVINGS','2022-08-18','ACTIVE',77500.00),
  ('SB100010',10,2,'SAVINGS','2023-01-07','ACTIVE',39500.00);
