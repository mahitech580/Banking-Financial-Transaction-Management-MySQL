-- Core relational schema. Requires MySQL 8.0.16+ for enforced CHECK constraints.
USE banking_financial_management;

CREATE TABLE IF NOT EXISTS branches (
  branch_id INT PRIMARY KEY AUTO_INCREMENT,
  branch_code VARCHAR(20) NOT NULL UNIQUE,
  branch_name VARCHAR(100) NOT NULL,
  city VARCHAR(80) NOT NULL,
  state VARCHAR(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS customers (
  customer_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  customer_number VARCHAR(30) NOT NULL UNIQUE,
  first_name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(20),
  date_of_birth DATE NOT NULL,
  customer_since DATE NOT NULL,
  risk_level ENUM('LOW','MEDIUM','HIGH') NOT NULL DEFAULT 'LOW',
  branch_id INT,
  CONSTRAINT fk_customers_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS accounts (
  account_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  account_number VARCHAR(30) NOT NULL UNIQUE,
  customer_id BIGINT NOT NULL,
  branch_id INT NOT NULL,
  account_type ENUM('SAVINGS','CURRENT','SALARY','BUSINESS') NOT NULL,
  opened_at DATE NOT NULL,
  status ENUM('ACTIVE','FROZEN','CLOSED') NOT NULL DEFAULT 'ACTIVE',
  current_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT fk_accounts_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_accounts_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS cards (
  card_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  card_number VARCHAR(32) NOT NULL UNIQUE,
  customer_id BIGINT NOT NULL,
  account_id BIGINT NOT NULL,
  card_type ENUM('DEBIT','CREDIT') NOT NULL,
  issued_at DATE NOT NULL,
  credit_limit DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  status ENUM('ACTIVE','BLOCKED','EXPIRED') NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_cards_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_cards_account FOREIGN KEY (account_id) REFERENCES accounts(account_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS merchants (
  merchant_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  merchant_name VARCHAR(150) NOT NULL,
  merchant_category VARCHAR(80) NOT NULL,
  city VARCHAR(80),
  risk_level ENUM('LOW','MEDIUM','HIGH') NOT NULL DEFAULT 'LOW'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS transactions (
  transaction_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  account_id BIGINT NOT NULL,
  transaction_type ENUM('CREDIT','DEBIT','TRANSFER','ATM','FEE') NOT NULL,
  amount DECIMAL(18,2) NOT NULL,
  transaction_time DATETIME NOT NULL,
  reference_code VARCHAR(50) NOT NULL UNIQUE,
  channel ENUM('BRANCH','ATM','ONLINE','MOBILE','POS') NOT NULL,
  merchant_id BIGINT NULL,
  status ENUM('PENDING','SUCCESS','FAILED','REVERSED') NOT NULL DEFAULT 'SUCCESS',
  CONSTRAINT chk_transactions_amount CHECK (amount > 0),
  CONSTRAINT fk_transactions_account FOREIGN KEY (account_id) REFERENCES accounts(account_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_transactions_merchant FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS transfers (
  transfer_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  transaction_id BIGINT NOT NULL UNIQUE,
  from_account_id BIGINT NOT NULL,
  to_account_id BIGINT NOT NULL,
  transfer_amount DECIMAL(18,2) NOT NULL,
  initiated_at DATETIME NOT NULL,
  status ENUM('PENDING','COMPLETED','FAILED','REVERSED') NOT NULL DEFAULT 'COMPLETED',
  CONSTRAINT chk_transfer_amount CHECK (transfer_amount > 0),
  CONSTRAINT chk_transfer_different_accounts CHECK (from_account_id <> to_account_id),
  CONSTRAINT fk_transfers_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_transfers_source FOREIGN KEY (from_account_id) REFERENCES accounts(account_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_transfers_destination FOREIGN KEY (to_account_id) REFERENCES accounts(account_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS card_transactions (
  card_transaction_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  card_id BIGINT NOT NULL,
  merchant_id BIGINT NOT NULL,
  reference_code VARCHAR(50) NOT NULL UNIQUE,
  amount DECIMAL(18,2) NOT NULL,
  transaction_time DATETIME NOT NULL,
  channel ENUM('ATM','ONLINE','MOBILE','POS') NOT NULL,
  status ENUM('PENDING','SUCCESS','FAILED','REVERSED') NOT NULL DEFAULT 'SUCCESS',
  CONSTRAINT chk_card_transaction_amount CHECK (amount > 0),
  CONSTRAINT fk_card_transactions_card FOREIGN KEY (card_id) REFERENCES cards(card_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_card_transactions_merchant FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS loans (
  loan_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  customer_id BIGINT NOT NULL,
  account_id BIGINT NOT NULL,
  loan_type ENUM('PERSONAL','HOME','AUTO','BUSINESS','EDUCATION') NOT NULL,
  principal DECIMAL(18,2) NOT NULL,
  interest_rate DECIMAL(6,3) NOT NULL COMMENT 'Annual nominal rate, percentage points',
  tenure_months INT NOT NULL,
  start_date DATE NOT NULL,
  status ENUM('ACTIVE','CLOSED','DEFAULTED') NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT chk_loan_values CHECK (principal > 0 AND interest_rate >= 0 AND tenure_months > 0),
  CONSTRAINT fk_loans_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_loans_account FOREIGN KEY (account_id) REFERENCES accounts(account_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS loan_payments (
  payment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  loan_id BIGINT NOT NULL,
  due_date DATE NOT NULL,
  paid_date DATE NULL,
  amount_due DECIMAL(18,2) NOT NULL,
  amount_paid DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  status ENUM('DUE','PAID','LATE','MISSED') NOT NULL DEFAULT 'DUE',
  CONSTRAINT chk_loan_payment_values CHECK (amount_due > 0 AND amount_paid >= 0 AND amount_paid <= amount_due),
  CONSTRAINT fk_loan_payments_loan FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS fraud_events (
  fraud_event_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  transaction_id BIGINT NOT NULL,
  detected_at DATETIME NOT NULL,
  fraud_type VARCHAR(100) NOT NULL,
  risk_score DECIMAL(5,2) NOT NULL,
  action_taken ENUM('REVIEW','BLOCK','ALLOW') NOT NULL,
  CONSTRAINT chk_fraud_risk_score CHECK (risk_score BETWEEN 0 AND 100),
  CONSTRAINT fk_fraud_events_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS disputes (
  dispute_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  transaction_id BIGINT NOT NULL,
  opened_at DATETIME NOT NULL,
  reason VARCHAR(200) NOT NULL,
  disputed_amount DECIMAL(18,2) NOT NULL,
  status ENUM('OPEN','WON','LOST','REFUNDED') NOT NULL DEFAULT 'OPEN',
  CONSTRAINT chk_dispute_amount CHECK (disputed_amount > 0),
  CONSTRAINT fk_disputes_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS settlements (
  settlement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  transaction_id BIGINT NOT NULL,
  settled_at DATETIME NULL,
  settlement_amount DECIMAL(18,2) NOT NULL,
  status ENUM('PENDING','SETTLED','FAILED') NOT NULL DEFAULT 'PENDING',
  CONSTRAINT chk_settlement_amount CHECK (settlement_amount > 0),
  CONSTRAINT fk_settlements_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS audit_log (
  audit_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  entity_name VARCHAR(64) NOT NULL,
  entity_id BIGINT NOT NULL,
  action_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  action_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  details JSON NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Schema inventory
-- Review all tables and storage engines after schema creation.
SELECT table_name, engine, table_rows
FROM information_schema.tables
WHERE table_schema = DATABASE()
ORDER BY table_name;


-- Column definition audit
-- Inspect nullability and types for the financial ledger.
SELECT table_name, column_name, column_type, is_nullable, column_key
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name IN ('accounts', 'transactions', 'transfers')
ORDER BY table_name, ordinal_position;


-- Foreign key map
-- List declared foreign keys to make the relationship model easy to inspect.
SELECT table_name, column_name, constraint_name, referenced_table_name, referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = DATABASE() AND referenced_table_name IS NOT NULL
ORDER BY table_name, constraint_name;
