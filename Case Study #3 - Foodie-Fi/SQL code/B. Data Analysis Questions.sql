------------------------------
--B. Data Analysis Questions--
------------------------------

--Author: Ela Wajdzik
--Date: 14.06.2023
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
    )*100,1) AS pct_of_charned
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
WHERE plan_path LIKE '%0,4%';


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


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?