-- Business question: How many banking product types and how much recorded balance/principal does each customer hold?
-- Account balances and loan principal are summarized separately to avoid join fan-out.
WITH account_summary AS (
  SELECT customer_id,COUNT(*) account_count,
         SUM(status='ACTIVE') active_account_count,SUM(current_balance) stored_balance
  FROM accounts GROUP BY customer_id
),
card_summary AS (
  SELECT customer_id,COUNT(*) card_count,SUM(status='ACTIVE') active_card_count
  FROM cards GROUP BY customer_id
),
loan_summary AS (
  SELECT customer_id,COUNT(*) loan_count,SUM(status='ACTIVE') active_loan_count,
         SUM(principal) gross_loan_principal
  FROM loans GROUP BY customer_id
)
SELECT c.customer_id,c.customer_number,c.risk_level,
       COALESCE(a.account_count,0) account_count,COALESCE(a.active_account_count,0) active_accounts,
       COALESCE(cd.card_count,0) card_count,COALESCE(cd.active_card_count,0) active_cards,
       COALESCE(l.loan_count,0) loan_count,COALESCE(l.active_loan_count,0) active_loans,
       ROUND(COALESCE(a.stored_balance,0),2) stored_balance,
       ROUND(COALESCE(l.gross_loan_principal,0),2) gross_loan_principal
FROM customers c LEFT JOIN account_summary a ON a.customer_id=c.customer_id
LEFT JOIN card_summary cd ON cd.customer_id=c.customer_id
LEFT JOIN loan_summary l ON l.customer_id=c.customer_id
ORDER BY (COALESCE(a.account_count,0)+COALESCE(cd.card_count,0)+COALESCE(l.loan_count,0)) DESC,c.customer_id;