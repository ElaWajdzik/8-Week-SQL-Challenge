-----------------------
--2. Data Exploration--
-----------------------

--Author: Ela Wajdzik
--Date: 13.07.2023
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
-- From 1 to 11 and from 37 to 52/53

SELECT
    week_number,
    COUNT(*)
FROM clean_weekly_sales
GROUP BY week_number;


-- 3. How many total transactions were there for each year in the dataset?

SELECT
    calendar_year,
    COUNT(*)
FROM clean_weekly_sales
GROUP BY calendar_year;

-- 4. What is the total sales for each region for each month?

SELECT
    region,
    month_number,
    SUM(sales)
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

-- 5. What is the total count of transactions for each platform

SELECT
    platform,
    COUNT(*)
FROM clean_weekly_sales
GROUP BY platform;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
-- 7. What is the percentage of sales by demographic for each year in the dataset?
-- 8. Which age_band and demographic values contribute the most to Retail sales?
-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?





