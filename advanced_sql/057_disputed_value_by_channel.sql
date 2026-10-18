-- Business question: Which transaction channels account for the most disputed value?
SELECT t.channel, COUNT(d.dispute_id) AS dispute_count,
       SUM(d.disputed_amount) AS disputed_value,
       AVG(d.disputed_amount) AS average_disputed_value
FROM disputes d
JOIN transactions t ON t.transaction_id = d.transaction_id
GROUP BY t.channel
ORDER BY disputed_value DESC;