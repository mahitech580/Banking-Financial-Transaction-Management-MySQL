-- Business question: Does each loan's recorded customer own its linked repayment account?
-- This is a data-quality review: foreign keys alone do not require both customer IDs to match.
SELECT l.loan_id,l.loan_type,l.status,l.customer_id AS loan_customer_id,
       a.customer_id AS account_customer_id,l.account_id,l.principal
FROM loans l JOIN accounts a ON a.account_id=l.account_id
WHERE l.customer_id<>a.customer_id
ORDER BY l.loan_id;