-- Business question: Which cards have high purchase activity but a narrow merchant footprint?
SELECT c.card_id,c.card_type,c.status,COUNT(ct.card_transaction_id) purchase_attempts,
       COUNT(DISTINCT ct.merchant_id) distinct_merchants,
       SUM(ct.status='SUCCESS') successful_purchases,
       ROUND(SUM(CASE WHEN ct.status='SUCCESS' THEN ct.amount ELSE 0 END),2) successful_purchase_value,
       ROUND(COUNT(ct.card_transaction_id)/NULLIF(COUNT(DISTINCT ct.merchant_id),0),2) attempts_per_merchant
FROM cards c LEFT JOIN card_transactions ct ON ct.card_id=c.card_id
GROUP BY c.card_id,c.card_type,c.status
HAVING COUNT(ct.card_transaction_id)>0
ORDER BY attempts_per_merchant DESC,purchase_attempts DESC;