-- Card inventory and card transaction analysis.
USE banking_financial_management;

-- 1. Card portfolio by type and status
SELECT card_type, status, COUNT(*) AS card_count,
       SUM(credit_limit) AS total_credit_limit,
       AVG(credit_limit) AS average_credit_limit
FROM cards
GROUP BY card_type, status
ORDER BY card_type, status;

-- 2. Merchant and channel analysis for card transactions
SELECT m.merchant_name, m.merchant_category, ct.channel,
       COUNT(*) AS attempts,
       SUM(ct.status = 'SUCCESS') AS successful_count,
       SUM(CASE WHEN ct.status = 'SUCCESS' THEN ct.amount ELSE 0 END) AS successful_value
FROM card_transactions AS ct
JOIN merchants AS m ON m.merchant_id = ct.merchant_id
GROUP BY m.merchant_id, m.merchant_name, m.merchant_category, ct.channel
ORDER BY successful_value DESC;

-- 3. Failed or reversed card activity by card and customer
SELECT c.card_number, CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
       ct.reference_code, ct.amount, ct.transaction_time, ct.status, m.merchant_name
FROM card_transactions AS ct
JOIN cards AS c ON c.card_id = ct.card_id
JOIN customers AS cu ON cu.customer_id = c.customer_id
JOIN merchants AS m ON m.merchant_id = ct.merchant_id
WHERE ct.status IN ('FAILED', 'REVERSED')
ORDER BY ct.transaction_time DESC;

-- 4. Rule-based outlier candidates. A high amount is a review signal, not a fraud conclusion.
SELECT ct.reference_code, c.card_number, m.merchant_name, ct.amount,
       ct.transaction_time, ct.channel, ct.status
FROM card_transactions AS ct
JOIN cards AS c ON c.card_id = ct.card_id
JOIN merchants AS m ON m.merchant_id = ct.merchant_id
WHERE ct.amount >= 25000 OR HOUR(ct.transaction_time) BETWEEN 0 AND 4
ORDER BY ct.amount DESC;


SELECT c.card_type,ct.status,COUNT(*) AS attempt_count,SUM(ct.amount) AS attempted_value,ROUND(AVG(ct.amount),2) AS average_amount FROM card_transactions ct JOIN cards c ON c.card_id=ct.card_id GROUP BY c.card_type,ct.status ORDER BY c.card_type,attempt_count DESC;
