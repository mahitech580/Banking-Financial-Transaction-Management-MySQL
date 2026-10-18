-- Triggers demonstrate defensive validation and immutable audit events.
-- Audit logging is not a replacement for production-grade access controls or retention policy.
USE banking_financial_management;

DROP TRIGGER IF EXISTS trg_validate_loan_payment_insert;
DROP TRIGGER IF EXISTS trg_validate_loan_payment_update;
DROP TRIGGER IF EXISTS trg_audit_transaction_insert;
DROP TRIGGER IF EXISTS trg_audit_loan_payment_update;

DELIMITER $$

CREATE TRIGGER trg_validate_loan_payment_insert
BEFORE INSERT ON loan_payments
FOR EACH ROW
BEGIN
  IF NEW.amount_due <= 0 OR NEW.amount_paid < 0 OR NEW.amount_paid > NEW.amount_due THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan payment amounts are inconsistent';
  END IF;
  IF NEW.status = 'PAID' AND NEW.amount_paid < NEW.amount_due THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A PAID installment must be fully paid';
  END IF;
END$$

CREATE TRIGGER trg_validate_loan_payment_update
BEFORE UPDATE ON loan_payments
FOR EACH ROW
BEGIN
  IF NEW.amount_due <= 0 OR NEW.amount_paid < 0 OR NEW.amount_paid > NEW.amount_due THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan payment amounts are inconsistent';
  END IF;
  IF NEW.status = 'PAID' AND NEW.amount_paid < NEW.amount_due THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A PAID installment must be fully paid';
  END IF;
END$$

CREATE TRIGGER trg_audit_transaction_insert
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (entity_name, entity_id, action_type, details)
  VALUES (
    'transactions', NEW.transaction_id, 'INSERT',
    JSON_OBJECT('reference_code', NEW.reference_code,
                'transaction_type', NEW.transaction_type,
                'amount', NEW.amount,
                'status', NEW.status,
                'channel', NEW.channel)
  );
END$$

CREATE TRIGGER trg_audit_loan_payment_update
AFTER UPDATE ON loan_payments
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (entity_name, entity_id, action_type, details)
  VALUES (
    'loan_payments', NEW.payment_id, 'UPDATE',
    JSON_OBJECT('old_status', OLD.status,
                'new_status', NEW.status,
                'old_amount_paid', OLD.amount_paid,
                'new_amount_paid', NEW.amount_paid)
  );
END$$

DELIMITER ;
