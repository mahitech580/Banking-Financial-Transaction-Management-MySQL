-- Business question: Identify active cards whose linked deposit/account record is not active.
SELECT cd.card_id, cd.card_type, cd.status AS card_status,
       cd.account_id, a.account_number, a.status AS account_status,
       c.customer_number, cd.issued_at,
       DATEDIFF(CURRENT_DATE, cd.issued_at) AS days_since_issue
FROM cards AS cd
JOIN accounts AS a ON a.account_id = cd.account_id
JOIN customers AS c ON c.customer_id = cd.customer_id
WHERE cd.status = 'ACTIVE' AND a.status <> 'ACTIVE'
ORDER BY cd.issued_at, cd.card_id;
