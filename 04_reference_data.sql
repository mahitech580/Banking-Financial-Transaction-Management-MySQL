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
