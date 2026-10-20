-- Business question: Find card records where the customer and linked account owners do not match.
SELECT cd.card_id, cd.card_type, cd.status AS card_status,
       cd.customer_id AS card_customer_id,
       a.customer_id AS account_customer_id,
       cd.account_id, a.account_number,
       c.customer_number AS card_customer_number,
       ac.customer_number AS account_customer_number
FROM cards AS cd
JOIN accounts AS a ON a.account_id = cd.account_id
JOIN customers AS c ON c.customer_id = cd.customer_id
JOIN customers AS ac ON ac.customer_id = a.customer_id
WHERE cd.customer_id <> a.customer_id
ORDER BY cd.card_id;
