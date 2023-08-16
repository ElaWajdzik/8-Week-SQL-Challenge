------------
--Analysis--
------------

--Author: Ela Wajdzik
--Date: 15.08.2023
--Tool used: Visual Studio Code & xampp


USE balanced_tree;

/*
High Level Sales Analysis
*/

-- 1. What was the total quantity sold for all products?

SELECT
    SUM(qty) AS total_quantity
FROM sales;

-- 2. What is the total generated revenue for all products before discounts?

SELECT
    SUM(qty*price) AS revenue_without_discounts
FROM sales;

-- 3. What was the total discount amount for all products?

SELECT
    SUM(discount) AS total_discount
FROM sales;

/*
Transaction Analysis
*/

-- 1. How many unique transactions were there?

SELECT
    COUNT(DISTINCT txn_id) AS number_of_transactions
FROM sales;

-- 2. What is the average unique products purchased in each transaction?

SELECT
    ROUND(AVG(number_of_different_products),0) AS average_unique_products
FROM (
    SELECT
        txn_id,
        COUNT(DISTINCT prod_id) AS number_of_different_products
    FROM sales
    GROUP BY txn_id) AS txn_sales;

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?



-- 4. What is the average discount value per transaction?

SELECT
    ROUND(AVG(discount),1) AS avg_discount
FROM (
    SELECT
        txn_id,
        SUM(qty*price*discount/100) AS discount
    FROM sales
    GROUP BY txn_id) AS txn_sales;

-- 5. What is the percentage split of all transactions for members vs non-members?

WITH txn_sales AS (
    SELECT
        member,
        COUNT(DISTINCT txn_id) AS number_of_transactions
    FROM sales
    GROUP BY member
)

SELECT 
    CASE 
        WHEN member = 1 THEN 'members'
        ELSE 'non-members'
    END AS member,
    number_of_transactions,
    ROUND(number_of_transactions/
    (
        SELECT SUM(number_of_transactions)
        FROM txn_sales
    )*100,1) AS proc_of_transactions
FROM txn_sales;


-- 6. What is the average revenue for member transactions and non-member transactions?

WITH txn_revenue AS (
    SELECT
        txn_id,
        member,
        SUM(qty*price) AS revenue
    FROM sales
    GROUP BY txn_id, member
)

SELECT 
    CASE 
        WHEN member = 1 THEN 'members'
        ELSE 'non-members'
    END AS member,
    ROUND(AVG(revenue),2) AS avg_revenue
FROM txn_revenue
GROUP BY member;

/*
Product Analysis
What are the top 3 products by total revenue before discount?
What is the total quantity, revenue and discount for each segment?
What is the top selling product for each segment?
What is the total quantity, revenue and discount for each category?
What is the top selling product for each category?
What is the percentage split of revenue by product for each segment?
What is the percentage split of revenue by segment for each category?
What is the percentage split of total revenue by category?
What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
*/
