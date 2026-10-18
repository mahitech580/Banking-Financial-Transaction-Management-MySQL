-- Window functions preserve row-level detail while adding rankings and running metrics.
USE banking_financial_management;

-- 1. Rank successful transactions within each account.
SELECT account_id, reference_code, amount, transaction_time,
       ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS account_sequence,
       RANK() OVER (PARTITION BY account_id ORDER BY amount DESC) AS amount_rank,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY amount DESC) AS dense_amount_rank
FROM transactions
WHERE status = 'SUCCESS'
ORDER BY account_id, account_sequence;

-- 2. Running amount per account with an explicit ROWS frame.
SELECT account_id, reference_code, transaction_time, amount,
       SUM(CASE WHEN transaction_type = 'CREDIT' THEN amount
                WHEN transaction_type = 'DEBIT' THEN -amount ELSE 0 END)
         OVER (PARTITION BY account_id
               ORDER BY transaction_time, transaction_id
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_ledger_flow
FROM transactions
WHERE status = 'SUCCESS'
ORDER BY account_id, transaction_time, transaction_id;

-- 3. Previous and next successful transaction for each account.
SELECT account_id, reference_code, transaction_time, amount,
       LAG(amount) OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS previous_amount,
       LEAD(amount) OVER (PARTITION BY account_id ORDER BY transaction_time, transaction_id) AS next_amount
FROM transactions
WHERE status = 'SUCCESS'
ORDER BY account_id, transaction_time;

-- 4. Segment accounts into balance quartiles.
SELECT account_number, current_balance,
       NTILE(4) OVER (ORDER BY current_balance DESC) AS balance_quartile
FROM accounts
ORDER BY balance_quartile, current_balance DESC;

-- 5. Monthly comparison using LAG on aggregated months.
WITH monthly AS (
  SELECT DATE_FORMAT(transaction_time, '%Y-%m') AS month_key,
         SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
  FROM transactions
  GROUP BY DATE_FORMAT(transaction_time, '%Y-%m')
)
SELECT month_key, successful_value,
       LAG(successful_value) OVER (ORDER BY month_key) AS previous_month_value,
       successful_value - LAG(successful_value) OVER (ORDER BY month_key) AS change_from_previous_month
FROM monthly
ORDER BY month_key;


-- Return the latest successful transaction for each account
WITH ranked AS (SELECT t.*,ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY transaction_time DESC,transaction_id DESC) AS rn FROM transactions t WHERE status='SUCCESS') SELECT account_id,reference_code,amount,transaction_time FROM ranked WHERE rn=1 ORDER BY account_id;


-- Three-row moving average, ordered deterministically per account
SELECT account_id,reference_code,transaction_time,amount,ROUND(AVG(amount) OVER(PARTITION BY account_id ORDER BY transaction_time,transaction_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS moving_avg_3_rows FROM transactions WHERE status='SUCCESS' ORDER BY account_id,transaction_time,transaction_id;


-- Rank successful items inside each channel for investigation triage
SELECT channel,reference_code,amount,transaction_time,RANK() OVER(PARTITION BY channel ORDER BY amount DESC) AS channel_amount_rank FROM transactions WHERE status='SUCCESS' ORDER BY channel,channel_amount_rank,reference_code;
