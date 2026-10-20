-- Business question: Track successful card transaction volume and values by card type each month.
SELECT c.card_type, ct.channel,
       DATE_FORMAT(ct.transaction_time, '%Y-%m') AS activity_month,
       COUNT(*) AS successful_card_transactions,
       SUM(ct.amount) AS successful_card_value,
       ROUND(AVG(ct.amount), 2) AS average_successful_ticket,
       COUNT(DISTINCT ct.card_id) AS cards_used
FROM card_transactions AS ct
JOIN cards AS c ON c.card_id = ct.card_id
WHERE ct.status = 'SUCCESS'
GROUP BY c.card_type, ct.channel, DATE_FORMAT(ct.transaction_time, '%Y-%m')
ORDER BY activity_month DESC, successful_card_value DESC;
