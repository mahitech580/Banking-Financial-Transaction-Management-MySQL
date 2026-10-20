-- Business question: How many account, card, and loan product families are represented for each customer?
-- Grain: one customer. Card and loan amounts are kept separate from balances so unlike exposure measures are not incorrectly summed.
WITH account_summary AS (
  SELECT customer_id, COUNT(*) AS account_count,
    SUM(status = 'ACTIVE') AS active_account_count,
    COALESCE(SUM(current_balance), 0.00) AS total_stored_account_balance,
    COUNT(DISTINCT account_type) AS account_type_count
  FROM accounts GROUP BY customer_id
),
card_summary AS (
  SELECT customer_id, COUNT(*) AS card_count,
    SUM(status = 'ACTIVE') AS active_card_count,
    COUNT(DISTINCT card_type) AS card_type_count,
    COALESCE(SUM(CASE WHEN card_type = 'CREDIT' THEN credit_limit ELSE 0 END), 0.00) AS total_credit_limit
  FROM cards GROUP BY customer_id
),
loan_summary AS (
  SELECT customer_id, COUNT(*) AS loan_count,
    SUM(status = 'ACTIVE') AS active_loan_count,
    COALESCE(SUM(CASE WHEN status = 'ACTIVE' THEN principal ELSE 0 END), 0.00) AS active_loan_principal
  FROM loans GROUP BY customer_id
)
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, c.risk_level,
  COALESCE(a.account_count, 0) AS account_count, COALESCE(a.active_account_count, 0) AS active_account_count,
  COALESCE(a.account_type_count, 0) AS account_type_count,
  COALESCE(a.total_stored_account_balance, 0.00) AS total_stored_account_balance,
  COALESCE(cs.card_count, 0) AS card_count, COALESCE(cs.active_card_count, 0) AS active_card_count,
  COALESCE(cs.card_type_count, 0) AS card_type_count, COALESCE(cs.total_credit_limit, 0.00) AS total_credit_limit,
  COALESCE(ls.loan_count, 0) AS loan_count, COALESCE(ls.active_loan_count, 0) AS active_loan_count,
  COALESCE(ls.active_loan_principal, 0.00) AS active_loan_principal,
  (COALESCE(a.account_count, 0) > 0) + (COALESCE(cs.card_count, 0) > 0)
    + (COALESCE(ls.loan_count, 0) > 0) AS product_family_count
FROM customers c
LEFT JOIN account_summary a ON a.customer_id = c.customer_id
LEFT JOIN card_summary cs ON cs.customer_id = c.customer_id
LEFT JOIN loan_summary ls ON ls.customer_id = c.customer_id
ORDER BY product_family_count DESC, active_account_count DESC, c.customer_id;
