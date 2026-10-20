-- Business question: Compare active loan principal by customer tenure band.
SELECT c.risk_level,
       CASE WHEN DATEDIFF(CURRENT_DATE, c.customer_since) < 365 THEN 'UNDER_1_YEAR'
            WHEN DATEDIFF(CURRENT_DATE, c.customer_since) < 1825 THEN '1_TO_4_YEARS'
            ELSE '5_YEARS_PLUS' END AS relationship_band,
       l.loan_type, COUNT(*) AS loan_count,
       SUM(CASE WHEN l.status = 'ACTIVE' THEN l.principal ELSE 0 END) AS active_principal,
       ROUND(AVG(l.interest_rate), 3) AS average_nominal_rate
FROM customers AS c
JOIN loans AS l ON l.customer_id = c.customer_id
GROUP BY c.risk_level, relationship_band, l.loan_type
ORDER BY active_principal DESC;
