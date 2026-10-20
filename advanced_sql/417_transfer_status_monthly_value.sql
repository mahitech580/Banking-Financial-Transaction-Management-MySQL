-- Business question: How does transfer volume and value trend by month and transfer status?
SELECT DATE_FORMAT(initiated_at, '%Y-%m') AS transfer_month,
       status, COUNT(*) AS transfer_count,
       SUM(transfer_amount) AS total_amount,
       ROUND(AVG(transfer_amount), 2) AS average_amount,
       MIN(initiated_at) AS first_initiated_at,
       MAX(initiated_at) AS last_initiated_at
FROM transfers
GROUP BY DATE_FORMAT(initiated_at, '%Y-%m'), status
ORDER BY transfer_month DESC, status;
