-- Business question: What amount is settled, pending, or failed?
SELECT status, COUNT(*) AS settlement_count,
       SUM(settlement_amount) AS total_amount,
       AVG(settlement_amount) AS average_amount
FROM settlements
GROUP BY status
ORDER BY total_amount DESC;