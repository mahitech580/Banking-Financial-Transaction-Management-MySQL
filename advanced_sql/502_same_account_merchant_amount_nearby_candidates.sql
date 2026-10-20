-- Business question: Find same-account same-merchant same-amount ledger events close in time for review.
-- Candidate matches require manual review; timestamps and amounts alone do not prove duplication.
SELECT t1.account_id, a.account_number, t1.merchant_id,
       t1.transaction_id AS first_transaction_id, t2.transaction_id AS second_transaction_id,
       t1.reference_code AS first_reference, t2.reference_code AS second_reference,
       t1.amount, t1.transaction_time AS first_time, t2.transaction_time AS second_time,
       TIMESTAMPDIFF(SECOND, t1.transaction_time, t2.transaction_time) AS seconds_apart
FROM transactions AS t1
JOIN transactions AS t2
  ON t2.account_id = t1.account_id
 AND t2.merchant_id = t1.merchant_id
 AND t2.amount = t1.amount
 AND t2.transaction_id > t1.transaction_id
 AND t2.transaction_time BETWEEN t1.transaction_time AND t1.transaction_time + INTERVAL 5 MINUTE
JOIN accounts AS a ON a.account_id = t1.account_id
WHERE t1.merchant_id IS NOT NULL
ORDER BY seconds_apart, t1.account_id;
