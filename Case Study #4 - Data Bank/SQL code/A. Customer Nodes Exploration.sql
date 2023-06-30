---------------------------------
--A. Customer Nodes Exploration--
---------------------------------

--Author: Ela Wajdzik
--Date: 26.06.2023 (update 30.06.2023)
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
-- probably customers in a node where end_date is 9999-12-31, it is the current node of these customers

/*
SELECT 
    MAX(start_date),
    MIN(start_date),
    MAX(end_date),
    MIN(end_date)
FROM customer_nodes
WHERE YEAR(end_date)<9999;

SELECT *
FROM customer_nodes
WHERE YEAR(end_date)>2020;
*/

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH customer_nodes_with_percentile AS (
    SELECT 
        *,
        DATEDIFF(end_date,start_date) AS number_of_days,
        ROUND(
            PERCENT_RANK() OVER (
                PARTITION BY region_id
                ORDER BY DATEDIFF(end_date,start_date)
            ) 
        ,2) AS percentile_rank
    FROM customer_nodes
    WHERE YEAR(end_date) < 9999),

80th_percentile AS (
SELECT 
    region_id,
    MIN(number_of_days) AS 80th_perc
FROM customer_nodes_with_percentile
WHERE percentile_rank >= 0.8
GROUP BY region_id),

95th_percentile AS (
SELECT 
    region_id,
    MIN(number_of_days) AS 95th_perc
FROM customer_nodes_with_percentile
WHERE percentile_rank >= 0.95
GROUP BY region_id),

50th_percentile AS (
SELECT 
    region_id,
    MIN(number_of_days) AS 50th_perc
FROM customer_nodes_with_percentile
WHERE percentile_rank >= 0.5
GROUP BY region_id)

SELECT 
    region_name,
    50th_perc,
    80th_perc,
    95th_perc
FROM regions
JOIN 50th_percentile AS 50th
    ON 50th.region_id = regions.region_id
JOIN 80th_percentile AS 80th
    ON 80th.region_id = regions.region_id
JOIN 95th_percentile AS 95th
    ON 95th.region_id = regions.region_id;

