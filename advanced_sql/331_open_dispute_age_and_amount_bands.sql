-- Business question: How much disputed value remains open, segmented by case age and dispute amount?
SELECT CASE WHEN TIMESTAMPDIFF(DAY,d.opened_at,CURRENT_TIMESTAMP)<7 THEN 'UNDER_7_DAYS'
            WHEN TIMESTAMPDIFF(DAY,d.opened_at,CURRENT_TIMESTAMP)<30 THEN '7_TO_29_DAYS'
            WHEN TIMESTAMPDIFF(DAY,d.opened_at,CURRENT_TIMESTAMP)<90 THEN '30_TO_89_DAYS'
            ELSE '90_DAYS_OR_MORE' END case_age_band,
       CASE WHEN d.disputed_amount<1000 THEN 'UNDER_1000'
            WHEN d.disputed_amount<10000 THEN '1000_TO_9999'
            WHEN d.disputed_amount<100000 THEN '10000_TO_99999'
            ELSE '100000_OR_MORE' END amount_band,
       COUNT(*) open_cases,COUNT(DISTINCT d.transaction_id) disputed_transactions,
       ROUND(SUM(d.disputed_amount),2) gross_open_disputed_amount,
       ROUND(AVG(d.disputed_amount),2) average_disputed_amount,
       MIN(d.opened_at) oldest_opened_at
FROM disputes d
WHERE d.status='OPEN'
GROUP BY case_age_band,amount_band
ORDER BY FIELD(case_age_band,'90_DAYS_OR_MORE','30_TO_89_DAYS','7_TO_29_DAYS','UNDER_7_DAYS'),gross_open_disputed_amount DESC;