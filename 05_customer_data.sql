-- Synthetic customer records. All identities and contact details are fictional placeholders.
USE banking_financial_management;

INSERT INTO customers
  (customer_number, first_name, last_name, email, phone, date_of_birth, customer_since, risk_level, branch_id)
VALUES
  ('C10001','Arjun','Rao','arjun.rao@example.com','9000000001','1997-03-12','2022-01-10','LOW',1),
  ('C10002','Priya','Sharma','priya.sharma@example.com','9000000002','1995-08-20','2021-06-15','LOW',1),
  ('C10003','Rahul','Verma','rahul.verma@example.com','9000000003','1992-11-02','2020-03-22','MEDIUM',2),
  ('C10004','Ananya','Iyer','ananya.iyer@example.com','9000000004','1998-01-28','2023-04-09','LOW',3),
  ('C10005','Vikram','Patel','vikram.patel@example.com','9000000005','1989-07-14','2019-09-01','HIGH',1),
  ('C10006','Neha','Reddy','neha.reddy@example.com','9000000006','1996-05-17','2024-02-11','LOW',1),
  ('C10007','Karan','Mehta','karan.mehta@example.com','9000000007','1991-12-30','2020-11-19','MEDIUM',2),
  ('C10008','Sneha','Nair','sneha.nair@example.com','9000000008','1999-09-08','2024-05-05','LOW',3),
  ('C10009','Aditya','Singh','aditya.singh@example.com','9000000009','1994-04-21','2022-08-18','MEDIUM',1),
  ('C10010','Meera','Das','meera.das@example.com','9000000010','1997-10-11','2023-01-07','LOW',2);


-- Customer risk segmentation
SELECT risk_level, COUNT(*) AS customer_count,
       ROUND(100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM customers), 0), 2) AS portfolio_pct
FROM customers
GROUP BY risk_level
ORDER BY FIELD(risk_level, 'HIGH', 'MEDIUM', 'LOW');


-- Customer tenure analysis
SELECT CASE
         WHEN TIMESTAMPDIFF(YEAR, customer_since, CURRENT_DATE) >= 5 THEN '5+ years'
         WHEN TIMESTAMPDIFF(YEAR, customer_since, CURRENT_DATE) >= 2 THEN '2-4 years'
         ELSE 'Under 2 years'
       END AS tenure_band,
       COUNT(*) AS customer_count
FROM customers
GROUP BY tenure_band
ORDER BY customer_count DESC;


-- Customer branch coverage
SELECT b.branch_name, b.city, COUNT(c.customer_id) AS customer_count,
       SUM(c.risk_level = 'HIGH') AS high_risk_customers
FROM branches AS b
LEFT JOIN customers AS c ON c.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY customer_count DESC, b.branch_name;
