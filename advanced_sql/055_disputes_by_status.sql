-- Business question: How many disputes and disputed amounts fall in each status?
SELECT status, COUNT(*) AS dispute_count,
       SUM(disputed_amount) AS disputed_value,
       AVG(disputed_amount) AS average_disputed_value
FROM disputes
GROUP BY status
ORDER BY disputed_value DESC;