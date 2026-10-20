-- Business question: Count the number of account, card, and loan product groups held by each customer.
WITH products AS (
  SELECT customer_id, 'ACCOUNT' AS product_group FROM accounts
  UNION
  SELECT customer_id, 'CARD' AS product_group FROM cards
  UNION
  SELECT customer_id, 'LOAN' AS product_group FROM loans
)
SELECT c.customer_number, c.risk_level,
       COUNT(DISTINCT p.product_group) AS distinct_product_groups,
       GROUP_CONCAT(DISTINCT p.product_group ORDER BY p.product_group) AS product_groups,
       COUNT(DISTINCT a.account_id) AS account_count,
       COUNT(DISTINCT cd.card_id) AS card_count,
       COUNT(DISTINCT l.loan_id) AS loan_count
FROM customers AS c
LEFT JOIN products AS p ON p.customer_id = c.customer_id
LEFT JOIN accounts AS a ON a.customer_id = c.customer_id
LEFT JOIN cards AS cd ON cd.customer_id = c.customer_id
LEFT JOIN loans AS l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_number, c.risk_level
ORDER BY distinct_product_groups DESC, account_count DESC;
