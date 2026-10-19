-- Business question: Do card customer ownership and linked account ownership agree?
-- The schema enforces both foreign keys independently, so this query checks the cross-table business rule.
SELECT cd.card_id,cd.card_type,cd.status,cd.customer_id AS card_customer_id,
       a.customer_id AS account_customer_id,cd.account_id,cd.issued_at
FROM cards cd JOIN accounts a ON a.account_id=cd.account_id
WHERE cd.customer_id<>a.customer_id
ORDER BY cd.card_id;