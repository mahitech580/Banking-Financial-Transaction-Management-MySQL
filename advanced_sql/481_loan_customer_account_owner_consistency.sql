-- Business question: Find loans where the declared borrower differs from the linked account owner.
SELECT l.loan_id, l.loan_type, l.status AS loan_status,
       l.customer_id AS borrower_customer_id, a.customer_id AS account_owner_customer_id,
       l.account_id, a.account_number, borrower.customer_number AS borrower_number,
       owner.customer_number AS account_owner_number, l.principal, l.start_date
FROM loans AS l
JOIN accounts AS a ON a.account_id = l.account_id
JOIN customers AS borrower ON borrower.customer_id = l.customer_id
JOIN customers AS owner ON owner.customer_id = a.customer_id
WHERE l.customer_id <> a.customer_id
ORDER BY l.loan_id;
