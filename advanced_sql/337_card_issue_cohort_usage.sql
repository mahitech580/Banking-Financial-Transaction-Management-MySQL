-- Business question: How does successful card usage evolve across card-issuance cohorts?
SELECT DATE_FORMAT(cd.issued_at,'%Y-%m') card_issue_cohort,
       DATE_FORMAT(ct.transaction_time,'%Y-%m') purchase_month,
       cd.card_type,COUNT(DISTINCT cd.card_id) cards_used,
       COUNT(ct.card_transaction_id) purchase_attempts,
       SUM(ct.status='SUCCESS') successful_purchases,
       ROUND(SUM(CASE WHEN ct.status='SUCCESS' THEN ct.amount ELSE 0 END),2) successful_purchase_value
FROM cards cd JOIN card_transactions ct ON ct.card_id=cd.card_id
GROUP BY DATE_FORMAT(cd.issued_at,'%Y-%m'),DATE_FORMAT(ct.transaction_time,'%Y-%m'),cd.card_type
HAVING purchase_month>=card_issue_cohort
ORDER BY card_issue_cohort,purchase_month,cd.card_type;