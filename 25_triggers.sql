USE banking_financial_management;
DROP TRIGGER IF EXISTS trg_prevent_negative_payment;
DELIMITER $$
CREATE TRIGGER trg_prevent_negative_payment BEFORE INSERT ON loan_payments FOR EACH ROW
BEGIN
 IF NEW.amount_paid < 0 OR NEW.amount_due <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid loan payment amount'; END IF;
END$$
DELIMITER ;
