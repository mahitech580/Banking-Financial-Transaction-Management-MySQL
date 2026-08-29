USE banking_financial_management;
EXPLAIN SELECT t.transaction_id,t.amount,t.transaction_time FROM transactions t WHERE t.account_id=1 AND t.status='SUCCESS' ORDER BY t.transaction_time DESC;
EXPLAIN SELECT a.account_type,COUNT(*) FROM accounts a GROUP BY a.account_type;
