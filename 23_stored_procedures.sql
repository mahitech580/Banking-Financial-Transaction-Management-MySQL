USE banking_financial_management;
DROP PROCEDURE IF EXISTS get_customer_transactions;
DELIMITER $$
CREATE PROCEDURE get_customer_transactions(IN p_customer_id BIGINT)
BEGIN
 SELECT t.* FROM transactions t JOIN accounts a ON a.account_id=t.account_id WHERE a.customer_id=p_customer_id ORDER BY t.transaction_time DESC;
END$$
DELIMITER ;
