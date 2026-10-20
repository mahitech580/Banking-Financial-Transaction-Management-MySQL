-- Business question: Identify recurring successful card-merchant pairs and their aggregate spend.
SELECT c.card_id, c.card_type, c.status AS current_card_status,
       m.merchant_id, m.merchant_name, m.merchant_category,
       COUNT(*) AS successful_transaction_count,
       SUM(ct.amount) AS successful_spend,
       MIN(ct.transaction_time) AS first_success_at,
       MAX(ct.transaction_time) AS last_success_at
FROM card_transactions AS ct
JOIN cards AS c ON c.card_id = ct.card_id
JOIN merchants AS m ON m.merchant_id = ct.merchant_id
WHERE ct.status = 'SUCCESS'
GROUP BY c.card_id, c.card_type, c.status, m.merchant_id, m.merchant_name, m.merchant_category
HAVING COUNT(*) >= 2
ORDER BY successful_spend DESC, successful_transaction_count DESC;
