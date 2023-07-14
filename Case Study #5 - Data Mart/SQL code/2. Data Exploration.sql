-----------------------
--2. Data Exploration--
-----------------------

--Author: Ela Wajdzik
--Date: 13.07.2023 (update 14.07.2023)
--Tool used: Visual Studio Code & xampp


USE data_mark;

-- 1. What day of the week is used for each week_date value?

-- The WEEKDAY() function returns the weekday number for a given date. 
-- 0 = Monday, 1 = Tuesday, 2 = Wednesday, 3 = Thursday, 4 = Friday, 5 = Saturday, 6 = Sunday.

SELECT
    WEEKDAY(week_date) AS week_day,
    COUNT(*) AS number_of_data
FROM clean_weekly_sales
GROUP BY WEEKDAY(week_date);


-- 2. What range of week numbers are missing from the dataset?

-- From 1 to 11 and from 37 to 52/53, it is 28 weeks

SELECT
    week_number,
    COUNT(*) AS number_of_data
FROM clean_weekly_sales
GROUP BY week_number;


-- 3. How many total transactions were there for each year in the dataset?

SELECT
    calendar_year,
    SUM(transactions) AS number_of_transactions
FROM clean_weekly_sales
GROUP BY calendar_year;

-- 4. What is the total sales for each region for each month?

SELECT
    region,
    month_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

-- 5. What is the total count of transactions for each platform

SELECT
    platform,
    SUM(transactions) AS number_of_transactions
FROM clean_weekly_sales
GROUP BY platform;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?

-- pivot

WITH total_table AS (
    SELECT 
        platform,
        month_number,
        SUM(sales) AS platform_month_total_sales,
        ROUND((SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY month_number) )*100,2) AS proc_of_sales
    FROM clean_weekly_sales
    GROUP BY platform, month_number
),
pivot_total_table AS (
SELECT
    month_number,
    MAX(CASE WHEN platform = "Retail" THEN proc_of_sales END) AS retail_proc,
    MAX(CASE WHEN platform = "Shopify" THEN proc_of_sales END) AS shopify_proc
FROM total_table 
GROUP BY month_number
)

SELECT 
    month_number,
    retail_proc,
    shopify_proc
FROM pivot_total_table;


-- 7. What is the percentage of sales by demographic for each year in the dataset?

WITH total_table AS (
    SELECT 
        calendar_year,
        demographic,
        SUM(sales) AS demographic_total_sales,
        ROUND((SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY calendar_year) )*100,2) AS proc_of_sale
    FROM clean_weekly_sales
    GROUP BY calendar_year, demographic
),
pivot_total_table AS (
    SELECT 
        calendar_year,
        MAX(CASE WHEN demographic = 'Couples' THEN proc_of_sale END) AS couples_proc_of_sales,
        MAX(CASE WHEN demographic = 'Families' THEN proc_of_sale END) AS families_proc_of_sales,
        MAX(CASE WHEN demographic = 'unknown' THEN proc_of_sale END) AS unknown_proc_of_sales
    FROM total_table
    GROUP BY calendar_year
)

SELECT
    calendar_year,
    couples_proc_of_sales,
    families_proc_of_sales,
    unknown_proc_of_sales
FROM pivot_total_table;


-- 8. Which age_band and demographic values contribute the most to Retail sales?

SELECT 
    age_band,
    demographic,
    platform,
    SUM(sales) AS total_sales,
    ROUND((SUM(sales) / SUM(SUM(sales)) OVER ())*100,2) AS proc_of_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic, platform
ORDER BY total_sales DESC;

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

-- In general, the average of averages is not the average. To calculate the average aggregate data, we need to divide the sum of sales by the number of transactions.

SELECT
    calendar_year,
    platform,
    SUM(sales),
    SUM(transactions),
    ROUND(SUM(sales)/SUM(transactions),0) AS avg_total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year, platform;




