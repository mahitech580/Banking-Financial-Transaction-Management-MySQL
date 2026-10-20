-- Business question: Compare card status outcomes across card-issue cohorts.
SELECT DATE_FORMAT(issued_at, '%Y-%m') AS issue_cohort,
       card_type, status,
       COUNT(*) AS cards_issued,
       SUM(credit_limit) AS aggregate_recorded_credit_limit,
       MIN(issued_at) AS earliest_issue_date,
       MAX(issued_at) AS latest_issue_date
FROM cards
GROUP BY DATE_FORMAT(issued_at, '%Y-%m'), card_type, status
ORDER BY issue_cohort DESC, card_type, status;
