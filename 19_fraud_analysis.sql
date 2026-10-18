-- Investigation queries. Rule matches are review candidates, not confirmed fraud.
USE banking_financial_management;

-- 1. Recorded fraud events by type, action and severity
SELECT fraud_type, action_taken, COUNT(*) AS event_count,
       ROUND(AVG(risk_score), 2) AS average_score,
       MAX(risk_score) AS maximum_score
FROM fraud_events
GROUP BY fraud_type, action_taken
ORDER BY maximum_score DESC;

-- 2. Fraud events enriched with transaction and customer context
SELECT f.fraud_event_id, f.detected_at, f.fraud_type, f.risk_score, f.action_taken,
       t.reference_code, t.amount, t.channel, t.status,
       a.account_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM fraud_events AS f
JOIN transactions AS t ON t.transaction_id = f.transaction_id
JOIN accounts AS a ON a.account_id = t.account_id
JOIN customers AS c ON c.customer_id = a.customer_id
ORDER BY f.risk_score DESC, f.detected_at DESC;

-- 3. Simple high-value / late-night rule candidates in the ledger
SELECT t.reference_code, t.amount, t.transaction_time, t.channel, t.status,
       a.account_number, m.merchant_name
FROM transactions AS t
JOIN accounts AS a ON a.account_id = t.account_id
LEFT JOIN merchants AS m ON m.merchant_id = t.merchant_id
WHERE t.amount >= 50000
   OR (HOUR(t.transaction_time) BETWEEN 0 AND 4 AND t.channel IN ('ONLINE','MOBILE'))
ORDER BY t.amount DESC, t.transaction_time DESC;

-- 4. Repeated failed attempts by account (threshold is illustrative)
SELECT a.account_number, COUNT(*) AS failed_attempts,
       SUM(t.amount) AS attempted_value,
       MIN(t.transaction_time) AS first_attempt,
       MAX(t.transaction_time) AS last_attempt
FROM transactions AS t
JOIN accounts AS a ON a.account_id = t.account_id
WHERE t.status = 'FAILED'
GROUP BY a.account_id, a.account_number
HAVING COUNT(*) >= 1
ORDER BY failed_attempts DESC, attempted_value DESC;

-- 5. Card outlier candidates
SELECT ct.reference_code, c.card_number, m.merchant_name,
       ct.amount, ct.transaction_time, ct.status
FROM card_transactions AS ct
JOIN cards AS c ON c.card_id = ct.card_id
JOIN merchants AS m ON m.merchant_id = ct.merchant_id
WHERE ct.status IN ('FAILED','REVERSED')
   OR ct.amount >= 25000
   OR HOUR(ct.transaction_time) BETWEEN 0 AND 4
ORDER BY ct.amount DESC;
