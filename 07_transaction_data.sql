-- Synthetic account ledger rows for the banking demo.
-- Run once after 04_reference_data.sql, 05_customer_data.sql and 06_account_data.sql.
-- Demo dates are deliberately recent so the 14-day dashboard charts have meaningful data.
USE banking_financial_management;

INSERT INTO transactions
  (account_id, transaction_type, amount, transaction_time, reference_code, channel, merchant_id, status)
VALUES
  (1,'CREDIT',50000.00,'2026-10-03 09:10:00','TX10001','ONLINE',NULL,'SUCCESS'),
  (1,'DEBIT',4200.00,'2026-10-05 18:30:00','TX10002','POS',1,'SUCCESS'),
  (1,'DEBIT',15000.00,'2026-10-10 12:15:00','TX10003','ONLINE',NULL,'SUCCESS'),
  (2,'CREDIT',75000.00,'2026-10-04 10:00:00','TX10004','ONLINE',NULL,'SUCCESS'),
  (2,'DEBIT',8500.00,'2026-10-08 20:05:00','TX10005','POS',2,'SUCCESS'),
  (3,'CREDIT',120000.00,'2026-10-06 11:20:00','TX10006','BRANCH',NULL,'SUCCESS'),
  (3,'DEBIT',22000.00,'2026-10-09 16:40:00','TX10007','ONLINE',3,'SUCCESS'),
  (4,'CREDIT',40000.00,'2026-10-07 09:00:00','TX10008','MOBILE',NULL,'SUCCESS'),
  (4,'DEBIT',6200.00,'2026-10-11 19:25:00','TX10009','POS',4,'SUCCESS'),
  (5,'CREDIT',250000.00,'2026-10-02 14:00:00','TX10010','BRANCH',NULL,'SUCCESS'),
  (5,'DEBIT',98000.00,'2026-10-12 02:15:00','TX10011','ONLINE',5,'SUCCESS'),
  (6,'CREDIT',60000.00,'2026-10-03 09:30:00','TX10012','ONLINE',NULL,'SUCCESS'),
  (6,'DEBIT',7200.00,'2026-10-13 13:20:00','TX10013','POS',1,'SUCCESS'),
  (7,'CREDIT',35000.00,'2026-10-05 10:15:00','TX10014','MOBILE',NULL,'SUCCESS'),
  (7,'DEBIT',18000.00,'2026-10-14 01:45:00','TX10015','ONLINE',5,'SUCCESS'),
  (8,'CREDIT',30000.00,'2026-10-06 08:45:00','TX10016','ONLINE',NULL,'SUCCESS'),
  (8,'DEBIT',4500.00,'2026-10-15 17:00:00','TX10017','POS',4,'SUCCESS'),
  (9,'CREDIT',90000.00,'2026-10-07 10:30:00','TX10018','ONLINE',NULL,'SUCCESS'),
  (9,'DEBIT',12500.00,'2026-10-16 21:30:00','TX10019','POS',2,'SUCCESS'),
  (10,'CREDIT',45000.00,'2026-10-08 09:45:00','TX10020','MOBILE',NULL,'SUCCESS'),
  (10,'DEBIT',5500.00,'2026-10-17 18:15:00','TX10021','POS',1,'SUCCESS'),
  (1,'DEBIT',125000.00,'2026-10-18 02:10:00','TX10022','ONLINE',5,'FAILED'),
  (5,'DEBIT',25000.00,'2026-10-18 08:15:00','TX10023','ONLINE',5,'PENDING'),
  (8,'DEBIT',9800.00,'2026-10-18 09:25:00','TX10024','POS',3,'REVERSED'),
  (1,'DEBIT',1000.00,'2026-10-18 10:00:00','TRF-OUT-10025','ONLINE',NULL,'SUCCESS'),
  (2,'CREDIT',1000.00,'2026-10-18 10:00:01','TRF-IN-10026','ONLINE',NULL,'SUCCESS');

INSERT INTO transfers
  (transaction_id, from_account_id, to_account_id, transfer_amount, initiated_at, status)
VALUES (25, 1, 2, 1000.00, '2026-10-18 10:00:00', 'COMPLETED');


-- Ledger volume check
SELECT status, COUNT(*) AS row_count,
       SUM(amount) AS attempted_amount,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_amount
FROM transactions
GROUP BY status
ORDER BY status;


-- Merchant linkage audit
SELECT channel, COUNT(*) AS total_rows,
       SUM(merchant_id IS NOT NULL) AS merchant_linked_rows,
       SUM(merchant_id IS NULL) AS direct_or_unlinked_rows
FROM transactions
GROUP BY channel
ORDER BY total_rows DESC;
