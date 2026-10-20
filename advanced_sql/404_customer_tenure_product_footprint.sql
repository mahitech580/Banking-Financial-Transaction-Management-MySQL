-- Business question: Summarize each customer's relationship age and attached product counts.
WITH account_counts AS (
  SELECT customer_id, COUNT(*) AS account_count, SUM(status = 'ACTIVE') AS active_accounts,
         SUM(current_balance) AS total_balance
  FROM accounts GROUP BY customer_id
), card_counts AS (
  SELECT customer_id, COUNT(*) AS card_count, SUM(status = 'ACTIVE') AS active_cards
  FROM cards GROUP BY customer_id
), loan_counts AS (
  SELECT customer_id, COUNT(*) AS loan_count,
         SUM(CASE WHEN status = 'ACTIVE' THEN principal ELSE 0 END) AS active_principal
  FROM loans GROUP BY customer_id
)
SELECT c.customer_number, DATEDIFF(CURRENT_DATE, c.customer_since) AS relationship_days,
       COALESCE(a.account_count, 0) AS account_count,
       COALESCE(a.active_accounts, 0) AS active_accounts,
       COALESCE(cd.card_count, 0) AS card_count,
       COALESCE(cd.active_cards, 0) AS active_cards,
       COALESCE(l.loan_count, 0) AS loan_count,
       COALESCE(l.active_principal, 0) AS active_principal,
       COALESCE(a.total_balance, 0) AS total_balance
FROM customers AS c
LEFT JOIN account_counts AS a ON a.customer_id = c.customer_id
LEFT JOIN card_counts AS cd ON cd.customer_id = c.customer_id
LEFT JOIN loan_counts AS l ON l.customer_id = c.customer_id
ORDER BY relationship_days DESC, c.customer_number;
