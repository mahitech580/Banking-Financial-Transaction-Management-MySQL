-- Business question: Are any transaction amounts zero or negative despite the schema's positive-amount rule?
-- Expected result on a correctly constrained MySQL 8 schema: no rows.
SELECT transaction_id,account_id,reference_code,amount,transaction_type,status,transaction_time
FROM transactions
WHERE amount<=0
ORDER BY transaction_id;