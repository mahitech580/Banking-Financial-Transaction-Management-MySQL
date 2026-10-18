-- Synthetic reference data for the portfolio demo. Run once on a freshly initialized schema.
USE banking_financial_management;

INSERT INTO branches (branch_code, branch_name, city, state) VALUES
  ('HYD001', 'Central Hyderabad', 'Hyderabad', 'Telangana'),
  ('BLR001', 'Central Bengaluru', 'Bengaluru', 'Karnataka'),
  ('CHE001', 'Central Chennai', 'Chennai', 'Tamil Nadu');

INSERT INTO merchants (merchant_name, merchant_category, city, risk_level) VALUES
  ('Metro Mart', 'Grocery', 'Hyderabad', 'LOW'),
  ('Travel Hub', 'Travel', 'Hyderabad', 'MEDIUM'),
  ('Tech Store', 'Electronics', 'Bengaluru', 'MEDIUM'),
  ('Quick Eats', 'Food', 'Chennai', 'LOW'),
  ('Online Marketplace', 'Ecommerce', 'Hyderabad', 'HIGH');


-- Branch reference coverage
SELECT state, COUNT(*) AS branch_count,
       GROUP_CONCAT(branch_code ORDER BY branch_code SEPARATOR ', ') AS branch_codes
FROM branches
GROUP BY state
ORDER BY branch_count DESC, state;


-- Merchant risk distribution
SELECT risk_level, COUNT(*) AS merchant_count,
       GROUP_CONCAT(merchant_name ORDER BY merchant_name SEPARATOR ', ') AS merchants
FROM merchants
GROUP BY risk_level
ORDER BY FIELD(risk_level, 'HIGH', 'MEDIUM', 'LOW');


-- Unused merchant check
SELECT m.merchant_id, m.merchant_name, m.merchant_category
FROM merchants AS m
LEFT JOIN transactions AS t ON t.merchant_id = m.merchant_id
LEFT JOIN card_transactions AS ct ON ct.merchant_id = m.merchant_id
WHERE t.transaction_id IS NULL AND ct.card_transaction_id IS NULL
ORDER BY m.merchant_name;
