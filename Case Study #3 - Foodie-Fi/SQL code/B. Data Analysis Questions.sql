------------------------------
--B. Data Analysis Questions--
------------------------------

--Author: Ela Wajdzik
--Date: 14.06.2023 (update 20.06.2023)
--Tool used: Visual Studio Code & xampp

USE foodie_fi;
SELECT * FROM subscriptions
WHERE customer_id<9;

-- 1. How many customers has Foodie-Fi ever had?

SELECT 
    COUNT(DISTINCT customer_id) AS number_of_customers
FROM subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT 
    MONTH(start_date) AS month_start,
    COUNT(customer_id) AS number_of_customers
FROM subscriptions
WHERE plan_id=0
GROUP BY month_start;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT 
    YEAR(start_date) AS year_start,
    plan_name,
    COUNT(customer_id) AS number_of_customers
FROM subscriptions AS sub
JOIN plans
    ON plans.plan_id = sub.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY year_start, plan_name;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
    COUNT(DISTINCT customer_id) AS number_of_churned,
    ROUND(COUNT(DISTINCT customer_id)/(
        SELECT
            COUNT(DISTINCT customer_id)
        FROM subscriptions
    )*100,1) AS pct_of_churned
FROM subscriptions
WHERE plan_id=4;


-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH customers_plan AS (
SELECT 
    customer_id,
    GROUP_CONCAT(plan_id ORDER BY start_date) AS plan_path
FROM subscriptions
GROUP BY customer_id)

SELECT 
    COUNT(customer_id) AS number_of_customers_churn_after_trial,
    ROUND(COUNT(customer_id)/(
        SELECT
            COUNT(DISTINCT customer_id)
        FROM subscriptions
    )*100,0) AS pct_of_customers_churn_after_trial
FROM customers_plan
WHERE plan_path LIKE '%0,4%'


-- 6. What is the number and percentage of customer plans after their initial free trial?

WITH plan_after_trial AS(
SELECT
    *,
    MIN(start_date) AS start_plan_after_trial
FROM subscriptions
WHERE plan_id!=0
GROUP BY customer_id
)

SELECT 
    plan_name,
    COUNT(customer_id) AS number_of_customers,
    ROUND(COUNT(customer_id)/10,1) AS pct_of_customers
FROM plan_after_trial 
JOIN plans
    ON plan_after_trial.plan_id = plans.plan_id
GROUP BY plan_name
ORDER BY COUNT(customer_id) DESC;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH plan_before_2021 AS (
SELECT 
    customer_id,
    MAX(start_date) AS start_last_plan_before_2021
FROM subscriptions
WHERE YEAR(start_date) < 2021
GROUP BY customer_id)


SELECT
    plan_name,
    COUNT(pb21.customer_id) AS number_of_customers,
    ROUND(COUNT(pb21.customer_id)/10,1) AS pct_of_customers
FROM plan_before_2021 AS pb21
JOIN subscriptions AS sub
    ON sub.customer_id = pb21.customer_id AND sub.start_date = pb21.start_last_plan_before_2021
JOIN plans
    ON sub.plan_id = plans.plan_id
GROUP BY plan_name
ORDER BY COUNT(pb21.customer_id) DESC; 

-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT
    COUNT(customer_id) AS number_of_customers
FROM subscriptions
WHERE plan_id = 3 AND YEAR(start_date) = 2020;

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH customer_in_plan_3 AS (
SELECT
    customer_id,
    start_date AS upgrade_to_3
FROM subscriptions
WHERE plan_id = 3),
customers_start_date AS(
SELECT 
    customer_id,
    MIN(start_date) AS start_date
FROM subscriptions
GROUP BY customer_id)

SELECT 
    ROUND(AVG(DATEDIFF(c3.upgrade_to_3,csd.start_date)),0) AS avg_number_of_days_to_upgrade_to_3
FROM customer_in_plan_3 AS c3
JOIN customers_start_date AS csd
    ON c3.customer_id = csd.customer_id;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH customer_in_plan_3 AS (
SELECT
    customer_id,
    start_date AS upgrade_to_3
FROM subscriptions
WHERE plan_id = 3),
customers_start_date AS(
SELECT 
    customer_id,
    MIN(start_date) AS start_date
FROM subscriptions
GROUP BY customer_id),
customers_in_category AS (
SELECT 
    c3.customer_id,
    TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0) AS category_id,
    CASE 
        WHEN TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0)*30 != 0 THEN TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0)*30+1
        ELSE TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0)*30 
    END AS start_category,
    TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0)*30+30 AS end_category
FROM customer_in_plan_3 AS c3
JOIN customers_start_date AS csd
    ON c3.customer_id = csd.customer_id
GROUP BY c3.customer_id)

SELECT
    CONCAT(start_category,'-',end_category,' days') AS bucket,
    COUNT(customer_id) AS number_of_customers
FROM customers_in_category
GROUP BY category_id
ORDER BY category_id;


-- try how to work the function TRUNCATE()
-- SELECT TRUNCATE(((10-1)/3),0)

-- the function WIDTH_BUCKET() will be perfect to solve this problem, but it doesn't work in MySQL
-- WIDTH_BUCKET( expression, min, max, buckets)

-- try how the function NTILE() works, and if they can replace the function WIDTH_BUCKET()
-- NTILE(3) over (ORDER BY customer_id)

-- the first way of solving with the function CASE() to set up category. I don't think that is the best option.
/*
WITH customer_in_plan_3 AS (
SELECT
    customer_id,
    start_date AS upgrade_to_3
FROM subscriptions
WHERE plan_id = 3),
customers_start_date AS(
SELECT 
    customer_id,
    MIN(start_date) AS start_date
FROM subscriptions
GROUP BY customer_id),
customers_in_category AS (
SELECT 
    c3.customer_id,
    CASE 
        WHEN DATEDIFF(c3.upgrade_to_3,csd.start_date) < 31 THEN '0-30'
        WHEN DATEDIFF(c3.upgrade_to_3,csd.start_date) < 61 THEN '31-60'
        WHEN DATEDIFF(c3.upgrade_to_3,csd.start_date) < 91 THEN '61-90'
        WHEN DATEDIFF(c3.upgrade_to_3,csd.start_date) < 121 THEN '91-120'
        WHEN DATEDIFF(c3.upgrade_to_3,csd.start_date) < 151 THEN '121-150'
        WHEN DATEDIFF(c3.upgrade_to_3,csd.start_date) < 181 THEN '151-180'
        ELSE 'more than 180'
    END AS category_number_of_days
FROM customer_in_plan_3 AS c3
JOIN customers_start_date AS csd
    ON c3.customer_id = csd.customer_id
GROUP BY c3.customer_id)

SELECT
    category_number_of_days,
    COUNT(customer_id)
FROM customers_in_category
GROUP BY category_number_of_days;
*/

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH customers_plan AS (
SELECT
    customer_id,
    GROUP_CONCAT(plan_id ORDER BY start_date) AS plan_path
FROM subscriptions
WHERE YEAR(start_date) <2021
GROUP BY customer_id)

SELECT *
FROM customers_plan
WHERE plan_path LIKE '%2%1%';



-----------------------
--A. Customer Journey--
-----------------------

/*
Based off the 8 sample customers provided in the sample from the subscriptions table, 
write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join 
to make your explanations a bit easier!
*/
-- I chose randomly 8 curtomers_id (2,13,21,432,431,600, 890 and 901)

SELECT
    subscriptions.customer_id,
    subscriptions.plan_id,
    plans.plan_name,
    subscriptions.start_date
FROM subscriptions
JOIN plans
    ON subscriptions.plan_id = plans.plan_id
WHERE customer_id IN ('2','13','21','432','431','660','890','901');

