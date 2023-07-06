---------------------------------
--A. Customer Nodes Exploration--
---------------------------------

--Author: Ela Wajdzik
--Date: 2.07.2023 (update 6.07.2023)
--Tool used: Visual Studio Code & xampp


USE data_bank;

-- 1. What is the unique count and total amount for each transaction type?

SELECT 
    txn_type,
    COUNT(txn_amount) AS number_of_transactions,
    SUM(txn_amount) AS sum_of_amount
FROM customer_transactions
GROUP BY txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?

SELECT
    ROUND(COUNT(txn_amount)/COUNT(DISTINCT customer_id),1) AS avg_number_of_deposite,
    ROUND(AVG(txn_amount),0) AS avg_amount_of_deposite
FROM customer_transactions
WHERE txn_type = 'deposit';


-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH pivot_transactions AS (
    SELECT
        customer_id,
        MONTH(txn_date) AS date_month,
        SUM(
            CASE 
                WHEN txn_type = 'deposit' THEN 1 
                ELSE 0
            END) AS number_of_deposits,
        SUM(
            CASE 
                WHEN txn_type = 'purchase' THEN 1 
                ELSE 0
            END) AS number_of_purchases,   
        SUM(
            CASE 
                WHEN txn_type = 'withdrawal' THEN 1 
                ELSE 0
            END) AS number_of_withdrawals
    FROM customer_transactions
    GROUP BY customer_id, date_month
)


SELECT
    date_month,
    COUNT(customer_id) AS number_of_customers
FROM  pivot_transactions
WHERE 
    number_of_deposits > 1 AND 
    (number_of_purchases >= 1 OR number_of_withdrawals >= 1)
GROUP BY date_month;


-- 4. What is the closing balance for each customer at the end of the month?


DROP TABLE IF EXISTS t4;

CREATE TABLE t4 (
    month_date int,
    txn_type varchar(10),
    txn_amount int
);

INSERT INTO t4
  (month_date, txn_type, txn_amount)
VALUES
  ('1', 'balance', '0'),
  ('2', 'balance', '0'),
  ('3', 'balance', '0'),
  ('4',  'balance', '0');


WITH customer_transaction_with_balance AS (
    SELECT DISTINCT 
        ct.customer_id, 
        t4.month_date, 
        t4.txn_type, 
        t4.txn_amount
    FROM customer_transactions AS ct, t4
    UNION
    SELECT 
        customer_id, 
        MONTH(txn_date) AS month_date, 
        txn_type, 
        txn_amount
    FROM customer_transactions
),
month_aggregation_data AS (
    SELECT
        customer_id,
        month_date,
        SUM(
            CASE 
                WHEN txn_type='deposit' THEN txn_amount 
                ELSE txn_amount * -1
            END) AS month_change
    FROM customer_transaction_with_balance
    GROUP BY customer_id, month_date
)

SELECT 
    *,
    SUM(month_change) OVER (PARTITION BY customer_id ORDER BY month_date) AS end_month_balance
FROM month_aggregation_data
WHERE customer_id IN (1,2,3,4,5); -- this filetr is only to limit the result


-- solution without a month when the customer didn't do any transactions
/*
WITH month_aggregation_data AS (
SELECT
    customer_id,
    MONTH(txn_date) AS month_date,
    SUM(
        CASE 
            WHEN txn_type='deposit' THEN txn_amount 
            ELSE txn_amount * -1
        END) AS month_change
FROM customer_transactions
GROUP BY customer_id, month_date
)

SELECT 
    *,
    SUM(month_change) OVER (PARTITION BY customer_id ORDER BY month_date)
FROM month_aggregation_data
WHERE customer_id IN (1,2,3,4,5);
*/

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?

-- This question is not clear for me. I interpret it that way because, IMO I think it makes sense.
-- I compered the closing balances from January 2020 to April 2020, and checked if the balance increased by more than 5%
WITH jan_balance AS (
SELECT 
    customer_id,
    SUM(
        CASE 
            WHEN txn_type = 'deposit' THEN txn_amount 
            ELSE txn_amount * -1
        END
    ) AS jan_end_month_balance
FROM customer_transactions
WHERE MONTH(txn_date)=1
GROUP BY customer_id
),
apr_balance AS (
SELECT 
    customer_id,
    SUM(
        CASE 
            WHEN txn_type = 'deposit' THEN txn_amount 
            ELSE txn_amount * -1
        END
    ) AS apr_end_month_balance
FROM customer_transactions
GROUP BY customer_id
),
customer_percent_of_change AS (
SELECT
    j.customer_id,
    j.jan_end_month_balance,
    a.apr_end_month_balance,
    a.apr_end_month_balance/j.jan_end_month_balance - 1 AS percent_of_change
FROM jan_balance AS j, apr_balance AS a
WHERE j.customer_id = a.customer_id
),
customer_total AS (
SELECT COUNT(DISTINCT customer_id) AS num_all_customers
FROM customer_transactions
)

SELECT
    COUNT(*) AS number_of_customer_increase_up_to_5_proc,
    ROUND((COUNT(*)/ct.num_all_customers) *100,1) AS proc_of_all_customers
FROM customer_percent_of_change As cp, customer_total AS ct
WHERE percent_of_change > '0.05';

------

-- Second way I interpreted this problem
-- I compared the value of the first deposit to the ending balance in April 2020, and checked if the balance increased by more than 5% over the value of the first deposit.

WITH first_deposit AS (
SELECT 
    customer_id,
    MIN(txn_date) AS deposit_date,
    txn_amount AS deposit_amount
FROM customer_transactions
WHERE txn_type = 'deposit'
GROUP BY customer_id
),
apr_balance AS (
SELECT 
    customer_id,
    SUM(
        CASE 
            WHEN txn_type = 'deposit' THEN txn_amount 
            ELSE txn_amount * -1
        END
    ) AS apr_end_month_balance
FROM customer_transactions
GROUP BY customer_id
),
customer_percent_of_change AS (
SELECT
    fd.customer_id,
    fd.deposit_amount,
    a.apr_end_month_balance,
    a.apr_end_month_balance/fd.deposit_amount - 1 AS percent_of_change
FROM first_deposit AS fd, apr_balance AS a
WHERE fd.customer_id = a.customer_id
),
customer_total AS (
SELECT COUNT(DISTINCT customer_id) AS num_all_customers
FROM customer_transactions
)

SELECT
    COUNT(*) AS number_of_customer_increase_up_to_5_proc,
    ROUND((COUNT(*)/ct.num_all_customers) *100,1) AS proc_of_all_customers
FROM customer_percent_of_change As cp, customer_total AS ct
WHERE percent_of_change > '0.05';
