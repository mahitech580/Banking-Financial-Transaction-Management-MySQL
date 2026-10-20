-- Business question: Compare monthly card transaction activity across card-issue cohorts.
SELECT DATE_FORMAT(cd.issued_at, '%Y-%m') AS issue_cohort,
       DATE_FORMAT(ct.transaction_time, '%Y-%m') AS activity_month,
       cd.card_type, ct.channel, ct.status,
       COUNT(*) AS card_transaction_count,
       SUM(ct.amount) AS attempted_value,
       SUM(CASE WHEN ct.status = 'SUCCESS' THEN ct.amount ELSE 0 END) AS successful_value
FROM cards AS cd
JOIN card_transactions AS ct ON ct.card_id = cd.card_id
GROUP BY DATE_FORMAT(cd.issued_at, '%Y-%m'),
         DATE_FORMAT(ct.transaction_time, '%Y-%m'),
         cd.card_type, ct.channel, ct.status
ORDER BY activity_month DESC, issue_cohort DESC, successful_value DESC;
