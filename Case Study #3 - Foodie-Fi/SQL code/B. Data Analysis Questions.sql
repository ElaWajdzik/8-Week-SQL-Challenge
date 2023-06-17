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
-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- 6. What is the number and percentage of customer plans after their initial free trial?
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- 8. How many customers have upgraded to an annual plan in 2020?
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?