-- Business question: Measure elapsed resolution time for disputes with a terminal outcome.
SELECT reason, status, COUNT(*) AS dispute_count,
       ROUND(AVG(TIMESTAMPDIFF(HOUR, opened_at, CURRENT_TIMESTAMP)), 1) AS average_age_hours,
       MIN(opened_at) AS oldest_opened_at,
       MAX(opened_at) AS most_recent_opened_at,
       SUM(disputed_amount) AS disputed_value
FROM disputes
WHERE status <> 'OPEN'
GROUP BY reason, status
ORDER BY average_age_hours DESC, disputed_value DESC;
