-- Business question: What is each branch's customer mix by age band and stored risk label?
SELECT b.branch_id, b.branch_name, c.risk_level,
       CASE WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, CURRENT_DATE) < 25 THEN 'UNDER_25'
            WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, CURRENT_DATE) < 40 THEN '25_TO_39'
            WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, CURRENT_DATE) < 60 THEN '40_TO_59'
            ELSE '60_PLUS' END AS age_band,
       COUNT(*) AS customer_count
FROM customers AS c
LEFT JOIN branches AS b ON b.branch_id = c.branch_id
GROUP BY b.branch_id, b.branch_name, c.risk_level, age_band
ORDER BY b.branch_name, c.risk_level, age_band;
