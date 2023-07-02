---------------------------------
--A. Customer Nodes Exploration--
---------------------------------

--Author: Ela Wajdzik
--Date: 2.07.2023
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



-- 4. What is the closing balance for each customer at the end of the month?
-- 5. What is the percentage of customers who increase their closing balance by more than 5%?