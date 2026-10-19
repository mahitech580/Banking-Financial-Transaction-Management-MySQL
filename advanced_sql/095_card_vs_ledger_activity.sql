-- Compare card stream and account ledger separately; do not sum them without a de-duplication policy.
WITH ledger AS (SELECT a.customer_id,COUNT(t.transaction_id) ledger_count,SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END) ledger_value
FROM accounts a LEFT JOIN transactions t ON t.account_id=a.account_id GROUP BY a.customer_id),
card AS (SELECT c.customer_id,COUNT(ct.card_transaction_id) card_count,SUM(CASE WHEN ct.status='SUCCESS' THEN ct.amount ELSE 0 END) card_value
FROM cards c LEFT JOIN card_transactions ct ON ct.card_id=c.card_id GROUP BY c.customer_id)
SELECT cu.customer_id,cu.customer_number,COALESCE(l.ledger_count,0) ledger_count,COALESCE(ca.card_count,0) card_count,
COALESCE(l.ledger_value,0) ledger_success_value,COALESCE(ca.card_value,0) card_success_value
FROM customers cu LEFT JOIN ledger l ON l.customer_id=cu.customer_id LEFT JOIN card ca ON ca.customer_id=cu.customer_id ORDER BY cu.customer_id;