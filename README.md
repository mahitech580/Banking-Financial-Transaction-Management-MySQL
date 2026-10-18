# Banking & Financial Transaction Management System

A **MySQL-only capstone project** designed to model, manage, and analyze a realistic banking and financial transaction environment using advanced SQL and relational database concepts.

The project focuses entirely on the **database layer**. It covers the lifecycle of customers, accounts, banking transactions, transfers, cards, loans, repayments, payments, fraud events, risk analysis, settlements, and financial performance.

The objective is to demonstrate how I can use **MySQL to design a structured relational database, maintain data integrity, perform complex analysis, implement database-level business logic, and optimize SQL queries.**



## About the Project

I built this project as a practical SQL capstone rather than a simple CRUD database.

Instead of creating a basic bank management system with only customers and accounts, I designed the database around multiple connected financial operations.

The project represents how different banking entities interact:

```text
Customer
   |
   +----------------------+
   |                      |
   v                      v
Account                  Loan
   |                      |
   v                      v
Transaction              EMI
   |                      |
   +----------+-----------+
              |
              v
           Payment
              |
              v
         Settlement

Account
   |
   v
Card
   |
   v
Card Transaction
   |
   +--------------------+
   |                    |
   v                    v
Merchant            Fraud Event
                         |
                         v
                    Risk Analysis
```

The database is designed so that operational data can be transformed into meaningful financial, customer, transaction, fraud, and risk insights using SQL.

---

## Project Objective

The main objective of this project is to demonstrate practical knowledge of **MySQL and advanced SQL** by building a realistic relational database system.

The project focuses on:

* Database architecture
* Relational data modeling
* Normalization
* Data integrity
* Financial transaction processing
* Complex SQL querying
* Business analytics
* Customer analysis
* Account analysis
* Loan analysis
* Payment analysis
* Fraud analysis
* Risk analysis
* Database programming
* Transaction management
* Indexing
* Query optimization

---

# Banking Transaction Lifecycle

The project follows a realistic financial data flow:

```text
Customer
    ↓
Account
    ↓
Banking Transaction
    ↓
Transfer / Payment
    ↓
Settlement
    ↓
Fraud & Risk Analysis
```

Additional financial flows are modeled separately:

```text
Customer
    ↓
Loan
    ↓
EMI Schedule
    ↓
Repayment
    ↓
Outstanding Balance
    ↓
Default / Risk Analysis
```

Card-based transactions are also modeled:

```text
Customer
    ↓
Card
    ↓
Card Transaction
    ↓
Merchant
    ↓
Authorization
    ↓
Settlement
    ↓
Fraud Detection
```

---

# Core Database Entities

The database is organized around multiple related entities.

## Customers

Stores customer-level information and customer relationships.

Examples:

* Customer identification
* Personal information
* Contact information
* Customer status
* Registration details
* Customer risk information

---

## Branches

Represents banking branches and their operational information.

Examples:

* Branch details
* Branch location
* Branch status
* Customer relationships
* Account relationships
* Transaction activity

---

## Accounts

Represents customer bank accounts.

Examples:

* Account number
* Account type
* Account status
* Opening date
* Current balance
* Branch
* Account owner

---

## Transactions

Represents financial activity occurring through customer accounts.

Examples:

* Deposits
* Withdrawals
* Transfers
* Payments
* Transaction channels
* Transaction status
* Transaction amount
* Transaction timestamps

---

## Cards

Represents debit and credit cards connected to customer accounts.

Examples:

* Card type
* Card status
* Issue date
* Expiry date
* Linked account
* Card limits

---

## Card Transactions

Stores transactions performed using cards.

Examples:

* Merchant
* Transaction amount
* Transaction timestamp
* Transaction status
* Transaction channel
* Card activity

---

## Loans

Represents customer borrowing and loan accounts.

Examples:

* Loan type
* Principal amount
* Interest rate
* Loan tenure
* Loan status
* Start date
* Outstanding balance

---

## EMI & Repayments

Tracks scheduled and completed loan repayments.

Examples:

* EMI amount
* Due date
* Payment date
* Payment status
* Outstanding amount
* Late payments
* Default patterns

---

## Payments

Represents financial payments associated with transactions and loans.

Examples:

* Payment method
* Payment status
* Payment amount
* Payment timestamp
* Reference information

---

## Settlements

Tracks completed financial settlements.

Examples:

* Settlement amount
* Settlement date
* Settlement status
* Related transaction
* Settlement reference

---

## Fraud Events

Stores suspicious financial activity identified within the database.

Examples:

* Suspicious transactions
* Fraud categories
* Detection timestamps
* Fraud severity
* Investigation status

---

## Risk Analysis

Used to identify potentially risky customers, accounts, and transactions.

Examples:

* High transaction frequency
* Unusual transaction values
* Repeated failed transactions
* Loan repayment problems
* Suspicious transaction patterns
* High-risk accounts

---

# SQL Skills Demonstrated

This project is intentionally designed to demonstrate more than basic `SELECT`, `INSERT`, `UPDATE`, and `DELETE` statements.

## Basic SQL

* SELECT
* WHERE
* ORDER BY
* GROUP BY
* HAVING
* DISTINCT
* LIMIT
* CASE expressions
* Aggregate functions

---

## Aggregate Functions

Examples include:

```sql
COUNT()
SUM()
AVG()
MIN()
MAX()
```

Used for:

* Transaction totals
* Customer activity
* Account balances
* Loan statistics
* Payment analysis
* Branch performance

---

# JOINs

The project uses multi-table joins to combine related banking information.

Examples:

* Customers + Accounts
* Accounts + Transactions
* Customers + Loans
* Loans + EMI
* Cards + Card Transactions
* Transactions + Fraud Events
* Transactions + Settlements
* Customers + Accounts + Transactions

SQL techniques include:

```text
INNER JOIN
LEFT JOIN
RIGHT JOIN
CROSS JOIN
SELF JOIN
```

---

# Subqueries

Subqueries are used to solve analytical problems where one query depends on the result of another.

Examples:

* Customers with above-average balances
* Accounts with unusually high transaction volumes
* Loans above average principal value
* Customers with transaction activity above branch averages

---

# Correlated Subqueries

Correlated queries are used when the inner query depends on the current row of the outer query.

Examples:

* Comparing a customer's activity against their own historical activity
* Identifying customers whose transaction values exceed their personal averages
* Finding accounts with unusually high activity relative to similar accounts

---

# Common Table Expressions

CTEs are used to break complex analytical problems into understandable steps.

Examples:

```text
Transaction Aggregation
        ↓
Customer Metrics
        ↓
Risk Classification
        ↓
Final Analysis
```

The project also includes recursive CTE concepts where hierarchical or sequential analysis is appropriate.

---

# Window Functions

Window functions are used extensively for advanced financial analysis.

The project demonstrates:

```sql
ROW_NUMBER()
RANK()
DENSE_RANK()
LAG()
LEAD()
NTILE()
SUM() OVER()
AVG() OVER()
```

Applications include:

* Ranking customers by transaction value
* Ranking branches by financial activity
* Running transaction totals
* Month-over-month comparisons
* Customer transaction history
* Rolling averages
* Customer segmentation
* Transaction sequence analysis

---

# Financial Analytics

The project analyzes financial activity from multiple perspectives.

Examples:

* Total transaction value
* Transaction volume
* Average transaction amount
* Monthly transaction trends
* Account activity
* Customer financial activity
* Branch transaction performance
* Payment success rates
* Settlement performance
* Loan repayment behavior

---

# Customer Analytics

Customer-level analysis includes:

* Customer transaction frequency
* Total transaction value
* Average transaction size
* Account balances
* Loan exposure
* Card usage
* Payment behavior
* Customer segmentation
* High-value customers
* Inactive customers

---

# Account Analytics

Account-level analysis includes:

* Current balances
* Transaction activity
* Deposits
* Withdrawals
* Transfers
* Account utilization
* High-value accounts
* Dormant accounts
* Account activity trends

---

# Card Analytics

Card analysis includes:

* Card usage frequency
* Transaction volume
* Transaction value
* Merchant activity
* Failed card transactions
* High-value card transactions
* Suspicious card activity

---

# Loan Analytics

Loan analysis includes:

* Total loan value
* Outstanding principal
* EMI schedules
* Repayment behavior
* Late payments
* Default analysis
* Loan performance
* Customer loan exposure
* Loan risk classification

---

# Payment Analytics

Payment analysis includes:

* Successful payments
* Failed payments
* Payment volumes
* Payment values
* Payment methods
* Payment trends
* Settlement status

---

# Fraud Analysis

The fraud analysis module focuses on identifying suspicious financial activity using SQL.

Examples include:

* Unusually large transactions
* High transaction frequency
* Repeated failed transactions
* Unusual account activity
* Suspicious card activity
* Abnormal transaction patterns
* Customers with multiple risk indicators

The goal is not to build a machine-learning fraud model, but to demonstrate how **SQL can identify potentially suspicious patterns from relational transaction data.**

---

# Risk Analysis

The risk module combines different financial indicators.

Potential risk factors include:

```text
High Transaction Value
        +
Unusual Transaction Frequency
        +
Failed Transactions
        +
Late Loan Payments
        +
High Outstanding Loan Balance
        ↓
Potential Financial Risk
```

This demonstrates how SQL can combine multiple business conditions into analytical classifications.

---

# Database Programming

The project also demonstrates MySQL database programming.

## Views

Views are created for reusable analytical datasets.

Examples:

* Customer transaction summary
* Account activity summary
* Loan performance summary
* Customer risk summary
* Financial transaction summary

---

## Stored Procedures

Stored procedures demonstrate reusable database operations.

Examples:

* Transaction processing
* Customer financial summaries
* Account activity analysis
* Loan repayment analysis
* Financial reporting

---

## Stored Functions

Functions are used for reusable calculations.

Examples:

* Financial calculations
* Risk scoring logic
* Transaction classifications
* Customer metrics

---

## Triggers

Triggers demonstrate database-level business rules.

Examples:

* Maintaining account balances
* Recording transaction changes
* Maintaining audit information
* Validating financial operations
* Automatically recording important events

---

# Transactions

Financial systems require transactional consistency.

The project demonstrates MySQL transaction concepts such as:

```sql
START TRANSACTION;

-- Financial operation

COMMIT;
```

and:

```sql
ROLLBACK;
```

Transactions are used to demonstrate how multiple related database operations can be treated as a single logical unit.

---

# Constraints & Data Integrity

The database uses constraints to maintain reliable relational data.

Examples include:

* PRIMARY KEY
* FOREIGN KEY
* UNIQUE
* NOT NULL
* CHECK
* DEFAULT

These constraints help prevent invalid or inconsistent financial records.

---

# Indexing

Indexes are created for frequently queried columns.

Examples include indexes related to:

* Customer IDs
* Account IDs
* Transaction IDs
* Transaction dates
* Loan IDs
* Card IDs
* Payment status
* Transaction status

The purpose is to demonstrate how database indexing can improve query performance.

---

# Query Optimization

The final module focuses on SQL performance.

The project demonstrates:

* EXPLAIN
* Index utilization
* Query execution plans
* Identifying inefficient queries
* Reducing unnecessary scans
* Improving filtering
* Optimizing joins
* Comparing query approaches

The goal is to understand not only **how to write a query**, but also **how MySQL executes that query.**

---

# Business Questions

The database is designed to answer realistic questions such as:

### Customer

* Who are the highest-value customers?
* Which customers have the highest transaction activity?
* Which customers are becoming inactive?
* Which customers have multiple financial risk indicators?

### Accounts

* Which accounts have the highest balances?
* Which accounts have unusually high transaction activity?
* Which accounts are dormant?
* Which account types generate the most activity?

### Transactions

* What is the total transaction volume?
* What is the average transaction value?
* Which transaction types are most common?
* Which channels process the most transactions?
* How does transaction activity change over time?

### Branches

* Which branches process the highest transaction value?
* Which branches have the highest customer activity?
* Which branches show unusual transaction patterns?

### Cards

* Which cards have the highest transaction activity?
* Which merchants process the highest card volume?
* Which cards have unusually high-value transactions?

### Loans

* Which customers have the largest outstanding loans?
* Which loans have repayment problems?
* Which customers have the highest loan exposure?
* Which loans are approaching default?

### Fraud

* Which transactions appear suspicious?
* Which accounts show unusual transaction patterns?
* Which customers have repeated suspicious activity?
* What types of transactions are most frequently flagged?

### Financial Performance

* What is the monthly transaction value?
* What is the total financial activity by customer?
* Which branches generate the highest transaction volume?
* How does financial activity change over time?

---

# Project Structure

```text
Banking-Financial-Transaction-Management-MySQL/
│
├── README.md
├── LICENSE
│
├── 01_database_schema.sql
├── 02_tables.sql
├── 03_constraints.sql
├── 04_reference_data.sql
├── 05_customer_data.sql
├── 06_account_data.sql
├── 07_transaction_data.sql
│
├── 08_basic_queries.sql
├── 09_joins.sql
├── 10_subqueries.sql
├── 11_ctes.sql
├── 12_window_functions.sql
│
├── 13_transaction_analytics.sql
├── 14_customer_analytics.sql
├── 15_account_analytics.sql
├── 16_card_analytics.sql
├── 17_loan_analytics.sql
├── 18_payment_analytics.sql
├── 19_fraud_analysis.sql
├── 20_risk_analysis.sql
├── 21_financial_analytics.sql
│
├── 22_views.sql
├── 23_stored_procedures.sql
├── 24_functions.sql
├── 25_triggers.sql
├── 26_transactions.sql
├── 27_indexes.sql
└── 28_query_optimization.sql
```

---

# Execution Order

The project is organized into a logical execution sequence.

```text
Database Schema
      ↓
Tables
      ↓
Constraints
      ↓
Reference Data
      ↓
Customer Data
      ↓
Account Data
      ↓
Transaction Data
      ↓
Basic SQL
      ↓
Joins
      ↓
Subqueries
      ↓
CTEs
      ↓
Window Functions
      ↓
Business Analytics
      ↓
Views
      ↓
Procedures
      ↓
Functions
      ↓
Triggers
      ↓
Transactions
      ↓
Indexes
      ↓
Query Optimization
```

The project targets **MySQL 8.0+**.

---

# Technology

**Database:** MySQL 8.0+
**Language:** SQL
**Version Control:** Git / GitHub

This project intentionally focuses on **MySQL and SQL only**.

There is no Python application, JavaScript frontend, Flask backend, REST API, dashboard, or external application layer.

The purpose is to demonstrate database and SQL capabilities directly.

---

# What This Project Demonstrates

This capstone demonstrates my ability to work with SQL across the full database development process:

```text
Database Design
      ↓
Relational Modeling
      ↓
Data Integrity
      ↓
Data Loading
      ↓
SQL Querying
      ↓
Advanced Analytics
      ↓
Database Programming
      ↓
Transaction Management
      ↓
Indexing
      ↓
Query Optimization
```

The project is intended to show practical experience with **MySQL, relational database design, advanced SQL, analytical thinking, financial data modeling, and database performance.**

---

# Author

**Mahendra Kondaveeti**

B.Tech Computer Science & Engineering

GitHub: https://github.com/mahitech580

---

# License

This project is licensed under the **MIT License**.

See the `LICENSE` file for details.
