------------------------------
--3. Before & After Analysis--
------------------------------

--Author: Ela Wajdzik
--Date: 18.07.2023 (update 24.07.2023)
--Tool used: Visual Studio Code & xampp

/*
This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:
1. What is the total sales for the 4 weeks before and after 2020-06-15? 
What is the growth or reduction rate in actual values and percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
*/

USE data_mark;

-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? 
-- What is the growth or reduction rate in actual values and percentage of sales?

-- 2020-06-15 it is the 24th week of a 2020

WITH clean_total_week_sales AS (
SELECT 
    calendar_year,
    week_number,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year, week_number, split_data
),
4_weeks_sales AS (
    SELECT
        split_data,
        SUM(total_sales) AS total_sales,
        '1' AS rank_
    FROM clean_total_week_sales
    WHERE calendar_year = '2020' AND week_number IN (20, 21, 22, 23, 24, 25, 26, 27)
    GROUP BY split_data
),
pivot_sales AS (
    SELECT
        MAX(CASE WHEN split_data='after' THEN total_sales END) AS after_sales,
        MAX(CASE WHEN split_data='before' THEN total_sales END) AS before_sales
    FROM 4_weeks_sales
    GROUP BY rank_
)

SELECT 
    *,
    after_sales - before_sales AS value_of_change,
    ROUND(((after_sales - before_sales)/before_sales)*100,2) AS proc_of_change
FROM pivot_sales;


-- 2. What about the entire 12 weeks before and after?

-- 2020-06-15 it is the 24th week of a 2020

WITH clean_total_week_sales AS (
SELECT 
    calendar_year,
    week_number,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year, week_number, split_data
),
12_weeks_sales AS (
    SELECT
        split_data,
        SUM(total_sales) AS total_sales,
        '1' AS rank_
    FROM clean_total_week_sales
    WHERE calendar_year = '2020' AND week_number>=12 AND week_number<=35
    GROUP BY split_data
),
pivot_sales AS (
    SELECT
        MAX(CASE WHEN split_data='after' THEN total_sales END) AS after_sales,
        MAX(CASE WHEN split_data='before' THEN total_sales END) AS before_sales
    FROM 12_weeks_sales
    GROUP BY rank_
)

SELECT 
    *,
    after_sales - before_sales AS value_of_change,
    ROUND(((after_sales - before_sales)/before_sales)*100,2) AS proc_of_change
FROM pivot_sales;

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

-- 4 week

WITH clean_total_week_sales AS (
SELECT 
    calendar_year,
    week_number,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number >= 24
GROUP BY calendar_year, week_number, split_data
),
4_weeks_sales_2020 AS (
    SELECT
        SUM(total_sales) AS total_sales_2020
    FROM clean_total_week_sales
    WHERE week_number <28 AND calendar_year='2020'
)

SELECT 
    calendar_year,
    SUM(total_sales) AS total_sales,
    total_sales_2020 - SUM(total_sales) AS change_to_2020, 
    ROUND(((total_sales_2020 - SUM(total_sales))/SUM(total_sales))*100,2) AS proc_of_change_to_2020
FROM clean_total_week_sales, 4_weeks_sales_2020
WHERE week_number <28
GROUP BY calendar_year
ORDER BY calendar_year DESC;

-- 12 weeks

WITH clean_total_week_sales AS (
SELECT 
    calendar_year,
    week_number,
    CASE 
        WHEN week_date >= '2020-06-15' THEN 'after'
        ELSE 'before'
    END AS split_data,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number >= 24
GROUP BY calendar_year, week_number, split_data
),
12_weeks_sales_2020 AS (
    SELECT
        SUM(total_sales) AS total_sales_2020
    FROM clean_total_week_sales
    WHERE week_number <36 AND calendar_year='2020'
)

SELECT 
    calendar_year,
    SUM(total_sales) AS total_sales,
    total_sales_2020 - SUM(total_sales) AS change_to_2020, 
    ROUND(((total_sales_2020 - SUM(total_sales))/SUM(total_sales))*100,2) AS proc_of_change_to_2020
FROM clean_total_week_sales, 12_weeks_sales_2020
WHERE week_number <36
GROUP BY calendar_year
ORDER BY calendar_year DESC;
