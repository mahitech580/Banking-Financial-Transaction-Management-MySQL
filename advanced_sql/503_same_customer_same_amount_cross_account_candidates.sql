-- Business question: Find close-in-time equal-amount transactions for a customer across different linked accounts.
-- These are reconciliation candidates, not definitive duplicate-payment findings.
SELECT c.customer_number, a1.account_number AS first_account, a2.account_number AS second_account,
       t1.reference_code AS first_reference, t2.reference_code AS second_reference,
       t1.amount, t1.status AS first_status, t2.status AS second_status,
       t1.transaction_time AS first_time, t2.transaction_time AS second_time,
       TIMESTAMPDIFF(SECOND, t1.transaction_time, t2.transaction_time) AS seconds_apart
FROM transactions AS t1
JOIN accounts AS a1 ON a1.account_id = t1.account_id
JOIN customers AS c ON c.customer_id = a1.customer_id
JOIN accounts AS a2 ON a2.customer_id = c.customer_id AND a2.account_id <> a1.account_id
JOIN transactions AS t2 ON t2.account_id = a2.account_id
 AND t2.amount = t1.amount
 AND t2.transaction_time BETWEEN t1.transaction_time AND t1.transaction_time + INTERVAL 2 MINUTE
 AND t2.transaction_id > t1.transaction_id
ORDER BY seconds_apart, c.customer_number;
