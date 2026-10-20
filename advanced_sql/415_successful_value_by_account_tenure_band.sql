-- Business question: How does successful transaction value vary with account age and account type?
SELECT a.account_type,
       CASE WHEN DATEDIFF(CURRENT_DATE, a.opened_at) < 30 THEN 'UNDER_30_DAYS'
            WHEN DATEDIFF(CURRENT_DATE, a.opened_at) < 180 THEN '30_TO_179_DAYS'
            WHEN DATEDIFF(CURRENT_DATE, a.opened_at) < 365 THEN '180_TO_364_DAYS'
            ELSE '365_DAYS_PLUS' END AS account_tenure_band,
       COUNT(DISTINCT a.account_id) AS accounts,
       COUNT(t.transaction_id) AS successful_transactions,
       COALESCE(SUM(t.amount), 0) AS successful_value
FROM accounts AS a
LEFT JOIN transactions AS t ON t.account_id = a.account_id AND t.status = 'SUCCESS'
GROUP BY a.account_type, account_tenure_band
ORDER BY a.account_type, account_tenure_band;
