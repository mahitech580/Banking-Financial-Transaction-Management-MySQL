-- Business question: Identify active cards with no successful card transaction in the last 90 days.
WITH recent_use AS (
  SELECT DISTINCT card_id
  FROM card_transactions
  WHERE status = 'SUCCESS'
    AND transaction_time >= CURRENT_TIMESTAMP - INTERVAL 90 DAY
)
SELECT c.card_id, c.card_type, c.status, c.issued_at,
       c.credit_limit, cu.customer_number, a.account_number,
       DATEDIFF(CURRENT_DATE, c.issued_at) AS days_since_issue
FROM cards AS c
JOIN customers AS cu ON cu.customer_id = c.customer_id
JOIN accounts AS a ON a.account_id = c.account_id
LEFT JOIN recent_use AS ru ON ru.card_id = c.card_id
WHERE c.status = 'ACTIVE' AND ru.card_id IS NULL
ORDER BY c.issued_at, c.card_id;
