---------------------------------
--C. Challenge Payment Question--
---------------------------------

--Author: Ela Wajdzik
--Date: 23.06.2023
--Tool used: Visual Studio Code & xampp

/*
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer 
in the subscriptions table with the following requirements:

* monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
* upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
* upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
* once a customer churns they will no longer make payments

Example outputs for this table might look like the following:

customer_id	plan_id	plan_name		payment_date	amount	payment_order
1			1		basic monthly	2020-08-08		9.90	1
*/

DROP TABLE IF EXISTS n_month;
CREATE TABLE n_month (
  n int
);

--Table n_month contains the numbers from 1 to 12 (because it is the 12 month in a year)
INSERT INTO n_month
    (n)
VALUES
    (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);




-- plan_id = 0 isn't connected with payments, which is why these records don't exist in the table ``payments``
-- plan_id = 3 is a yearly plan, and a payment is one a year
-- plan_id = 4 it is churn, which is why the start date is the end of payments



WITH plan_1 AS (
SELECT 
    customer_id,
    plan_id,
    DATE(CONCAT('2020','-',n,'-',DAY(start_date))) AS payment_date,

    start_date
FROM subscriptions
JOIN n_month
WHERE 
    DATE(CONCAT('2020','-',n,'-',DAY(start_date))) >= MONTH(start_date) AND
    plan_id = 1
),
plan_2 AS (
SELECT 
    customer_id,
    plan_id,
    DATE(CONCAT('2020','-',n,'-',DAY(start_date))) AS payment_date,

    start_date
FROM subscriptions
JOIN n_month
WHERE 
    n >= MONTH(start_date) AND 
    plan_id = 2
),
plan_3 AS (
SELECT
    customer_id,
    plan_id,
    start_date AS payment_date,

    start_date
FROM subscriptions
WHERE 
    plan_id = 3
)

SELECT *
FROM plan_1
WHERE customer_id IN (19,2)
UNION 
SELECT *
FROM plan_2
WHERE customer_id IN (19,2)
UNION 
SELECT *
FROM plan_3
WHERE customer_id IN (19,2)
ORDER BY customer_id, start_date, payment_date;

WITH change_plan AS (
SELECT 
    customer_id,
    GROUP_CONCAT(plan_id ORDER BY start_date) AS change_plan,
    GROUP_CONCAT(start_date ORDER BY start_date) AS change_date
FROM subscriptions
WHERE customer_id IN (19,21)
GROUP BY customer_id)

SELECT 
    *,
    FIND_IN_SET(plan_id,change_plan)
FROM subscriptions AS sub
JOIN change_plan
    ON change_plan.customer_id = sub.customer_id;

SELECT *
FROM subscriptions
WHERE customer_id IN (1,2,3,19);