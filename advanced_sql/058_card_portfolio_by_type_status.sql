-- Business question: How many cards and how much credit limit exist by card type and status?
SELECT card_type, status, COUNT(*) AS card_count,
       SUM(credit_limit) AS total_credit_limit,
       AVG(credit_limit) AS average_credit_limit
FROM cards
GROUP BY card_type, status
ORDER BY card_type, status;