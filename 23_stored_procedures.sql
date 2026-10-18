-- Stored procedures for repeatable read operations and an atomic demo transfer.
USE banking_financial_management;

DROP PROCEDURE IF EXISTS get_customer_transactions;
DROP PROCEDURE IF EXISTS get_customer_financial_summary;
DROP PROCEDURE IF EXISTS sp_transfer_funds;

DELIMITER $$

CREATE PROCEDURE get_customer_transactions(
  IN p_customer_id BIGINT,
  IN p_limit INT,
  IN p_offset INT
)
BEGIN
  DECLARE v_limit INT DEFAULT 100;
  DECLARE v_offset INT DEFAULT 0;

  SET v_limit = LEAST(GREATEST(COALESCE(p_limit, 100), 1), 500);
  SET v_offset = GREATEST(COALESCE(p_offset, 0), 0);

  SELECT t.transaction_id, t.reference_code, t.transaction_type, t.amount,
         t.transaction_time, t.channel, t.status, a.account_number
  FROM transactions AS t
  JOIN accounts AS a ON a.account_id = t.account_id
  WHERE a.customer_id = p_customer_id
  ORDER BY t.transaction_time DESC, t.transaction_id DESC
  LIMIT v_limit OFFSET v_offset;
END$$

CREATE PROCEDURE get_customer_financial_summary(IN p_customer_id BIGINT)
BEGIN
  SELECT c.customer_id, c.customer_number,
         CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
         (SELECT COUNT(*) FROM accounts a WHERE a.customer_id = c.customer_id) AS account_count,
         (SELECT COALESCE(SUM(a.current_balance), 0)
          FROM accounts a WHERE a.customer_id = c.customer_id) AS total_balance,
         (SELECT COUNT(*)
          FROM accounts a JOIN transactions t ON t.account_id = a.account_id
          WHERE a.customer_id = c.customer_id) AS transaction_count,
         (SELECT COALESCE(SUM(t.amount), 0)
          FROM accounts a JOIN transactions t ON t.account_id = a.account_id
          WHERE a.customer_id = c.customer_id AND t.status = 'SUCCESS') AS successful_gross_value,
         (SELECT COUNT(*) FROM loans l
          WHERE l.customer_id = c.customer_id AND l.status = 'ACTIVE') AS active_loan_count
  FROM customers AS c
  WHERE c.customer_id = p_customer_id;
END$$

CREATE PROCEDURE sp_transfer_funds(
  IN p_from_account_id BIGINT,
  IN p_to_account_id BIGINT,
  IN p_amount DECIMAL(18,2)
)
BEGIN
  DECLARE v_source_status VARCHAR(10);
  DECLARE v_destination_status VARCHAR(10);
  DECLARE v_source_balance DECIMAL(18,2);
  DECLARE v_account_missing TINYINT DEFAULT 0;
  DECLARE v_outgoing_transaction_id BIGINT;
  DECLARE v_outgoing_reference VARCHAR(50);
  DECLARE v_incoming_reference VARCHAR(50);
  DECLARE v_transfer_time DATETIME;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_account_missing = 1;

  IF p_from_account_id IS NULL OR p_to_account_id IS NULL
     OR p_from_account_id = p_to_account_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source and destination accounts must be different valid IDs';
  END IF;
  IF p_amount IS NULL OR p_amount <= 0 OR p_amount > 1000000000000.00 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer amount must be positive and within the demo limit';
  END IF;

  START TRANSACTION;

  -- Lock in ascending account-id order to reduce deadlock risk for opposing transfers.
  IF p_from_account_id < p_to_account_id THEN
    SELECT status, current_balance INTO v_source_status, v_source_balance
    FROM accounts WHERE account_id = p_from_account_id FOR UPDATE;
    SELECT status INTO v_destination_status
    FROM accounts WHERE account_id = p_to_account_id FOR UPDATE;
  ELSE
    SELECT status INTO v_destination_status
    FROM accounts WHERE account_id = p_to_account_id FOR UPDATE;
    SELECT status, current_balance INTO v_source_status, v_source_balance
    FROM accounts WHERE account_id = p_from_account_id FOR UPDATE;
  END IF;

  IF v_account_missing = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or both accounts do not exist';
  END IF;
  IF v_source_status <> 'ACTIVE' OR v_destination_status <> 'ACTIVE' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Both accounts must be active';
  END IF;
  IF v_source_balance < p_amount THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient available balance';
  END IF;

  UPDATE accounts
  SET current_balance = current_balance - p_amount
  WHERE account_id = p_from_account_id AND current_balance >= p_amount;
  IF ROW_COUNT() <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debit validation failed';
  END IF;

  UPDATE accounts
  SET current_balance = current_balance + p_amount
  WHERE account_id = p_to_account_id AND status = 'ACTIVE';
  IF ROW_COUNT() <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Credit validation failed';
  END IF;

  SET v_transfer_time = NOW();
  SET v_outgoing_reference = CONCAT('TRF-', REPLACE(UUID(), '-', ''), '-D');
  SET v_incoming_reference = CONCAT('TRF-', REPLACE(UUID(), '-', ''), '-C');

  INSERT INTO transactions
    (account_id, transaction_type, amount, transaction_time, reference_code, channel, status)
  VALUES
    (p_from_account_id, 'DEBIT', p_amount, v_transfer_time, v_outgoing_reference, 'ONLINE', 'SUCCESS');
  SET v_outgoing_transaction_id = LAST_INSERT_ID();

  INSERT INTO transactions
    (account_id, transaction_type, amount, transaction_time, reference_code, channel, status)
  VALUES
    (p_to_account_id, 'CREDIT', p_amount, v_transfer_time, v_incoming_reference, 'ONLINE', 'SUCCESS');

  INSERT INTO transfers
    (transaction_id, from_account_id, to_account_id, transfer_amount, initiated_at, status)
  VALUES
    (v_outgoing_transaction_id, p_from_account_id, p_to_account_id, p_amount, v_transfer_time, 'COMPLETED');

  COMMIT;

  SELECT v_outgoing_transaction_id AS transaction_id,
         v_outgoing_reference AS reference_code,
         p_amount AS transferred_amount,
         p_from_account_id AS from_account_id,
         p_to_account_id AS to_account_id,
         'COMPLETED' AS status;
END$$

DELIMITER ;

-- Example read calls:
-- CALL get_customer_transactions(1, 25, 0);
-- CALL get_customer_financial_summary(1);
-- Example transfer call is kept in 26_transactions.sql.


-- Example pagination: inspect the first 20 ledger entries for customer ID 1.
CALL get_customer_transactions(1, 20, 0);


-- Run a read-only summary after data loading.
CALL get_customer_financial_summary(1);
