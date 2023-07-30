---------------------
--4. Bonus Question--
---------------------

--Author: Ela Wajdzik
--Date: 24.07.2023 (update 28.07.2023)
--Tool used: Visual Studio Code & xampp

USE data_mark;
/*
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

region
platform
age_band
demographic
customer_type

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?
*/

SELECT 
    region,
    platform,
    age_band,
    demographic,
    customer_type,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE calendar_year = '2020'
GROUP BY split_data, region, platform, age_band, demographic, customer_type;


--region

WITH region_sales AS (
SELECT 
    region,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE calendar_year = '2020'
GROUP BY split_data, region
),
pivot_region_sales AS (
    SELECT
        region,
        MAX(CASE WHEN split_data='after' THEN total_sales END) AS after_sales,
        MAX(CASE WHEN split_data='before' THEN total_sales END) AS before_sales
    FROM region_sales
    GROUP BY region
)

SELECT 
    *,
    ROUND(((after_sales - before_sales)/before_sales)*100,2) AS proc_change
FROM pivot_region_sales;


--platform

WITH platform_sales AS (
SELECT 
    platform,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE calendar_year = '2020'
GROUP BY split_data, platform
),
pivot_platform_sales AS (
    SELECT
        platform,
        MAX(CASE WHEN split_data='after' THEN total_sales END) AS after_sales,
        MAX(CASE WHEN split_data='before' THEN total_sales END) AS before_sales
    FROM platform_sales
    GROUP BY platform
)

SELECT 
    *,
    ROUND(((after_sales - before_sales)/before_sales)*100,2) AS proc_change
FROM pivot_platform_sales;


--age_band

WITH age_band_sales AS (
SELECT 
    age_band,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE calendar_year = '2020'
GROUP BY split_data, age_band
),
pivot_age_band_sales AS (
    SELECT
        age_band,
        MAX(CASE WHEN split_data='after' THEN total_sales END) AS after_sales,
        MAX(CASE WHEN split_data='before' THEN total_sales END) AS before_sales
    FROM age_band_sales
    GROUP BY age_band
)

SELECT 
    *,
    ROUND(((after_sales - before_sales)/before_sales)*100,2) AS proc_change
FROM pivot_age_band_sales;

--demographic

WITH demographic_sales AS (
SELECT 
    demographic,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE calendar_year = '2020'
GROUP BY split_data, demographic
),
pivot_demographic_sales AS (
    SELECT
        demographic,
        MAX(CASE WHEN split_data='after' THEN total_sales END) AS after_sales,
        MAX(CASE WHEN split_data='before' THEN total_sales END) AS before_sales
    FROM demographic_sales
    GROUP BY demographic
)

SELECT 
    *,
    ROUND(((after_sales - before_sales)/before_sales)*100,2) AS proc_change
FROM pivot_demographic_sales;


--customer_type

WITH customer_type_sales AS (
SELECT 
    customer_type,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE calendar_year = '2020'
GROUP BY split_data, customer_type
),
pivot_customer_type_sales AS (
    SELECT
        customer_type,
        MAX(CASE WHEN split_data='after' THEN total_sales END) AS after_sales,
        MAX(CASE WHEN split_data='before' THEN total_sales END) AS before_sales
    FROM customer_type_sales
    GROUP BY customer_type
)

SELECT 
    *,
    ROUND(((after_sales - before_sales)/before_sales)*100,2) AS proc_change
FROM pivot_customer_type_sales;