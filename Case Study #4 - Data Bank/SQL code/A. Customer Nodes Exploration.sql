---------------------------------
--A. Customer Nodes Exploration--
---------------------------------

--Author: Ela Wajdzik
--Date: 26.06.2023
--Tool used: Visual Studio Code & xampp





USE data_bank;

-- 1. How many unique nodes are there on the Data Bank system?
SELECT 
    COUNT(DISTINCT node_id)
FROM customer_nodes;

-- 2. What is the number of nodes per region?

SELECT
    region_name,
    COUNT(DISTINCT node_id) AS number_of_nodes
FROM customer_nodes
JOIN regions
    ON regions.region_id = customer_nodes.region_id
GROUP BY region_name;

-- 3. How many customers are allocated to each region?

SELECT
    region_name,
    COUNT(DISTINCT customer_id) AS number_of_customers
FROM customer_nodes
JOIN regions
    ON regions.region_id = customer_nodes.region_id
GROUP BY region_name;

-- 4. How many days on average are customers reallocated to a different node?

SELECT 
    ROUND(AVG(DATEDIFF(end_date,start_date)),2) AS avg_number_of_days
FROM customer_nodes
WHERE YEAR(end_date) <2021;

-- step 1 - max end_date
-- step 2 - number of end_date 9999 -500 na 3500 czyli 14%

SELECT 
    MAX(start_date),
    MIN(start_date),
    MAX(end_date),
    MIN(end_date)
FROM customer_nodes
WHERE YEAR(end_date)<2030;

SELECT *
FROM customer_nodes
WHERE YEAR(end_date)>2020;


-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?