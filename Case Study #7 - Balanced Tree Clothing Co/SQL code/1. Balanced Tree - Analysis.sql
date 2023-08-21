------------
--Analysis--
------------

--Author: Ela Wajdzik
--Date: 15.08.2023 (update 20.08.2023)
--Tool used: Visual Studio Code & xampp


USE balanced_tree;

/*
High Level Sales Analysis
*/

-- 1. What was the total quantity sold for all products?

SELECT
    SUM(qty) AS total_quantity
FROM sales;

-- the quantity sold for each product
SELECT
    pd.product_name,
    SUM(s.qty) AS total_quantity
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_quantity DESC;

-- 2. What is the total generated revenue for all products before discounts?

SELECT
    SUM(qty*price) AS revenue
FROM sales;

-- revenue for each product
SELECT
    pd.product_name,
    SUM(s.qty*s.price) AS revenue
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY revenue DESC;

-- 3. What was the total discount amount for all products?

-- 
SELECT
    pd.product_name,
    ROUND(SUM(s.qty*s.price*s.discount/100),2) AS total_discount
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_discount DESC;

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


WITH txn_sales AS (
SELECT
    txn_id,
    SUM(qty*price) AS revenue
FROM sales
GROUP BY txn_id
),
percentiles AS (
    SELECT
        revenue,
        PERCENT_RANK() OVER (ORDER BY revenue) AS percent_rank
    FROM txn_sales
),
25th_percentile AS (
SELECT
    MIN(revenue) AS 25th_perc
FROM percentiles
WHERE percent_rank >= 0.25
),
50th_percentile AS (
SELECT
    MIN(revenue) AS 50th_perc
FROM percentiles
WHERE percent_rank >= 0.5
),
75th_percentile AS (
SELECT
    MIN(revenue) AS 75th_perc
FROM percentiles
WHERE percent_rank >= 0.75
)

SELECT 
    *
FROM 25th_percentile, 50th_percentile, 75th_percentile;

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
*/

-- 1. What are the top 3 products by total revenue before discount?

SELECT
    pd.product_name,
    SUM(s.qty*s.price) AS revenue
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY revenue DESC LIMIT 3;

-- 2. What is the total quantity, revenue and discount for each segment?

SELECT
    pd.segment_name,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty * s.price * s.discount /100),2) AS total_discount
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.segment_name;

-- 3. What is the top selling product for each segment?

WITH product_sales AS (
SELECT
    pd.segment_name,
    pd.product_name,
    DENSE_RANK() OVER (PARTITION BY pd.segment_name ORDER BY SUM(s.qty) DESC) AS selling_ranking,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty * s.price * s.discount /100),2) AS total_discount
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.segment_name, pd.product_name
)
SELECT
    product_name,
    segment_name,
    total_quantity,
    revenue,
    total_discount
FROM product_sales
WHERE selling_ranking = 1;

-- 4. What is the total quantity, revenue and discount for each category?

SELECT
    pd.category_name,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty * s.price * s.discount /100),2) AS total_discount
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.category_name;

-- 5. What is the top selling product for each category?

WITH product_sales AS (
SELECT
    pd.category_name,
    pd.product_name,
    DENSE_RANK() OVER (PARTITION BY pd.category_name ORDER BY SUM(s.qty) DESC) AS selling_ranking,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty * s.price * s.discount /100),2) AS total_discount
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.category_name, pd.product_name
)
SELECT
    product_name,
    category_name,
    total_quantity,
    revenue,
    total_discount
FROM product_sales
WHERE selling_ranking = 1;

-- 6. What is the percentage split of revenue by product for each segment?

SELECT
    pd.segment_name,
    pd.product_name,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty *s.price)/(SUM(SUM(s.qty *s.price)) OVER (PARTITION BY pd.segment_name)) *100, 1) AS percentage_of_revenue_in_segment
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.segment_name, pd.product_name;

-- 7. What is the percentage split of revenue by segment for each category?

SELECT
    pd.category_name,
    pd.segment_name,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty *s.price)/(SUM(SUM(s.qty *s.price)) OVER (PARTITION BY pd.category_name)) *100, 1) AS percentage_of_revenue_in_segment
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.category_name, pd.segment_name;

-- 8. What is the percentage split of total revenue by category?

SELECT
    pd.category_name,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty *s.price)/(SUM(SUM(s.qty *s.price)) OVER ()) *100, 1) AS percentage_of_revenue_in_segment
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.category_name;

-- 9. What is the total transaction “penetration” for each product? 
--(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)


SELECT
    s.prod_id,
    pd.product_name,
    ROUND(COUNT(*)/(
        SELECT 
            COUNT(DISTINCT txn_id)
        FROM sales) *100,2) AS penetration
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY s.prod_id;

-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

-- NOTE
-- jest 220 możliwych trójek (kombinacja 3 elementów z 12)
-- 12!/(3!*(12-3)!) = 220







WITH prod_sales AS (
SELECT
    txn_id,
    SUM(CASE WHEN prod_id = 'c4a632' THEN 1 ELSE 0 END) AS prod_c4a632,
    SUM(CASE WHEN prod_id = 'e83aa3' THEN 1 ELSE 0 END) AS prod_e83aa3,
    SUM(CASE WHEN prod_id = 'e31d39' THEN 1 ELSE 0 END) AS prod_e31d39,
    SUM(CASE WHEN prod_id = 'd5e9a6' THEN 1 ELSE 0 END) AS prod_d5e9a6,
    SUM(CASE WHEN prod_id = '72f5d4' THEN 1 ELSE 0 END) AS prod_72f5d4,
    SUM(CASE WHEN prod_id = '9ec847' THEN 1 ELSE 0 END) AS prod_9ec847,
    SUM(CASE WHEN prod_id = '5d267b' THEN 1 ELSE 0 END) AS prod_5d267b,
    SUM(CASE WHEN prod_id = 'c8d436' THEN 1 ELSE 0 END) AS prod_c8d436,
    SUM(CASE WHEN prod_id = '2a2353' THEN 1 ELSE 0 END) AS prod_2a2353,
    SUM(CASE WHEN prod_id = 'f084eb' THEN 1 ELSE 0 END) AS prod_f084eb,
    SUM(CASE WHEN prod_id = 'b9a74d' THEN 1 ELSE 0 END) AS prod_b9a74d,
    SUM(CASE WHEN prod_id = '2feb6b' THEN 1 ELSE 0 END) AS prod_2feb6b
FROM sales
GROUP BY txn_id
),
set_of_products AS (
SELECT
    txn_id,
    CONCAT_WS(',',prod_c4a632, prod_e83aa3, prod_e31d39, prod_d5e9a6, prod_72f5d4, prod_9ec847, prod_5d267b, prod_c8d436, prod_2a2353, prod_f084eb, prod_b9a74d, prod_2feb6b) AS set_products
FROM prod_sales
)
SELECT
    *
FROM set_of_products;


WITH products_list_sales AS (
SELECT
    txn_id,
    GROUP_CONCAT(prod_id ORDER BY prod_id ASC) AS products_list
FROM sales
GROUP BY txn_id
)
SELECT 
    products_list,
    COUNT(txn_id) AS number_of_txn,
    (LENGTH(products_list) - LENGTH(REPLACE(products_list,',','')) +1) AS number_of_prod
FROM products_list_sales
GROUP BY products_list
ORDER BY number_of_txn DESC;



-----

WITH products_list_sales AS (
SELECT
    txn_id,
    GROUP_CONCAT(prod_id ORDER BY prod_id ASC) AS products_list
FROM sales
GROUP BY txn_id
)
SELECT 
    txn_id,
    products_list
FROM products_list_sales;

-- I added additional id
SELECT
    id,
    product_id
FROm product_details;

