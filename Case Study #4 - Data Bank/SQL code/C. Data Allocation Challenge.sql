--------------------------------
--C. Data Allocation Challenge--
--------------------------------

--Author: Ela Wajdzik
--Date: 7.07.2023 
--Tool used: Visual Studio Code & xampp


USE data_bank;

/*
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

Option 1: data is allocated based off the amount of money at the end of the previous month
Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
Option 3: data is updated real-time

For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

- running customer balance column that includes the impact each transaction
- customer balance at the end of each month
- minimum, average and maximum values of the running balance for each customer

Using all of the data available - how much data would have been required for each option on a monthly basis?
*/

-- option 1: data is allocated based off the amount of money at the end of the previous month
-- running customer balance column that includes the impact each transaction

SELECT 
    *,
    SUM(
        CASE 
            WHEN txn_type = 'deposit' THEN txn_amount 
            ELSE -txn_amount
        END
    ) OVER (
        PARTITION BY customer_id 
        ORDER BY txn_date
    ) AS running_balance
FROM customer_transactions
WHERE customer_id IN (1,2,3,4,5,6);

-- option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
-- customer balance at the end of each month
-- this problem is exacly like question 4 in section B


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
    customer_id,
    month_date,
    SUM(month_change) OVER (PARTITION BY customer_id ORDER BY month_date) AS end_month_balance
FROM month_aggregation_data
WHERE customer_id IN (1,2,3,4,5); -- this filetr is only to limit the result

-- option 3: data is updated real-time
-- minimum, average and maximum values of the running balance for each customer

WITH customer_transactions_with_running_balance AS(
SELECT 
    *,
    SUM(
        CASE 
            WHEN txn_type = 'deposit' THEN txn_amount 
            ELSE -txn_amount
        END
    ) OVER (
        PARTITION BY customer_id 
        ORDER BY txn_date
    ) AS running_balance
FROM customer_transactions
)

SELECT 
    customer_id,
    MIN(running_balance) AS min_running_balance,
    ROUND(AVG(running_balance),0) AS avg_running_balance,
    MAX(running_balance) AS max_running_balance
FROM customer_transactions_with_running_balance 
WHERE customer_id IN (1,2,3,4,5,6)
GROUP BY customer_id;