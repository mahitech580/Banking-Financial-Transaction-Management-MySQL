-- Business question: Which cards currently marked active are attached to frozen or closed accounts?
-- Grain: one card/account pair. This is a current-state relationship check and does not prove that the card was active after account closure.
SELECT c.card_id, c.customer_id, c.card_type, c.status AS card_status,
  c.issued_at, a.account_id, a.account_number, a.account_type,
  a.status AS account_status, a.opened_at, a.current_balance,
  b.branch_name, b.city AS branch_city
FROM cards c
JOIN accounts a ON a.account_id = c.account_id
JOIN branches b ON b.branch_id = a.branch_id
WHERE c.status = 'ACTIVE' AND a.status IN ('FROZEN', 'CLOSED')
ORDER BY a.status, c.issued_at, c.card_id;
