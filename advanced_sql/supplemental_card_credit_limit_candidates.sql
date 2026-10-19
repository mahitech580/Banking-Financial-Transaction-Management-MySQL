-- Business question: Are card types aligned with the credit-limit values recorded on their card rows?
-- Treat this as a configuration check; product-specific rules may permit exceptions.
SELECT card_id,card_type,status,credit_limit,issued_at,customer_id,account_id,
       CASE WHEN card_type='DEBIT' AND credit_limit>0 THEN 'DEBIT_WITH_CREDIT_LIMIT'
            WHEN card_type='CREDIT' AND credit_limit<=0 THEN 'CREDIT_WITHOUT_POSITIVE_LIMIT'
            ELSE 'REVIEW' END review_candidate
FROM cards
WHERE (card_type='DEBIT' AND credit_limit>0)
   OR (card_type='CREDIT' AND credit_limit<=0)
ORDER BY card_type,credit_limit,card_id;