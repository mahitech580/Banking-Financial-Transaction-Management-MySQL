-- Business question: How large is the loan portfolio for each loan type?
SELECT loan_type, COUNT(*) AS loan_count,
       SUM(principal) AS total_principal,
       AVG(principal) AS average_principal,
       AVG(interest_rate) AS average_interest_rate,
       AVG(tenure_months) AS average_tenure_months
FROM loans
GROUP BY loan_type
ORDER BY total_principal DESC;