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


-- CREATE TABLE payments AS

WITH change_plan_id AS (

-- table with change_plane (e.g. customer_id=19, change_plan=0,2,3) and change_date (e.g. customer_id=19, change_date=2020-06-22,2020-6-29,2020-08-29)

SELECT 
    customer_id,
    GROUP_CONCAT(plan_id ORDER BY start_date) AS change_plan,
    GROUP_CONCAT(start_date ORDER BY start_date) AS change_date
FROM subscriptions
GROUP BY customer_id),
change_plan_date AS (

-- table with start_plan_date (e.g. customer_id=19, plan_id=2, start_plan_date=2020-06-29) and end_plan_date (e.g. customer_id=19, plan_id=2, start_plan_date=2020-08-29) based on tables change_plan_id and subscription

SELECT 
    sub.customer_id,
    sub.plan_id,
    SUBSTRING(change_date, ((FIND_IN_SET(plan_id,change_plan)-1)*10 + FIND_IN_SET(plan_id,change_plan)), 10) AS start_plan_date,
    SUBSTRING(change_date, ((FIND_IN_SET(plan_id,change_plan))*10 + FIND_IN_SET(plan_id,change_plan))+1, 10) AS end_plan_date
FROM subscriptions AS sub
JOIN change_plan_id
    ON change_plan_id.customer_id = sub.customer_id),
change_plan_payments AS (

-- table with create end_plan_date it is not exactly the same as end_plan_date
-- if end_plan_date doesn't exist, it means that plan is still active, but in the new table payments, we want only data about 2020, which is why in this case I set this value 2020-12-31
-- if end_plan_date is after 2020-12-31, I change it to 2020-12-31 because we want only data about 2020

SELECT
    customer_id,
    plan_id,
    DATE(start_plan_date) AS start_plan_date,
    DATE(CASE 
        WHEN YEAR(DATE(end_plan_date)) >2020 THEN '2020-12-31'
        WHEN end_plan_date != 0 THEN end_plan_date
        ELSE '2020-12-31'
    END) AS end_plan_payments
FROM change_plan_date
WHERE plan_id !=0 ANd plan_id !=4),



plan_1 AS (

-- table create a next month payment for plan_id=1

SELECT 
    customer_id,
    plan_id,
    DATE(CONCAT('2020','-',n,'-',DAY(start_plan_date))) AS payment_date,
    start_plan_date,
    end_plan_payments
FROM change_plan_payments
JOIN n_month
WHERE 
    DATE(CONCAT('2020','-',n,'-',DAY(start_plan_date))) >= start_plan_date AND
    DATE(CONCAT('2020','-',n,'-',DAY(start_plan_date))) < end_plan_payments AND
    plan_id = 1
),

plan_2 AS (

-- table create a next month payment for plan_id=2

SELECT 
    customer_id,
    plan_id,
    DATE(CONCAT('2020','-',n,'-',DAY(start_plan_date))) AS payment_date,
    start_plan_date,
    end_plan_payments
FROM change_plan_payments
JOIN n_month
WHERE 
    DATE(CONCAT('2020','-',n,'-',DAY(start_plan_date))) >= start_plan_date AND
    DATE(CONCAT('2020','-',n,'-',DAY(start_plan_date))) < end_plan_payments AND
    plan_id = 2
),

plan_3 AS (

-- table create a payment for plan_id=3

SELECT
    customer_id,
    plan_id,
    start_plan_date AS payment_date,
    start_plan_date,
    end_plan_payments
FROM change_plan_payments
WHERE 
    plan_id = 3
)
    
SELECT 
    pay_date.customer_id,
    pay_date.plan_id,
    plan_name,
    pay_date.payment_date,
    price AS base_price,
    DENSE_RANK() OVER(
        PARTITION BY customer_id
        ORDER BY payment_date
        ) AS payment_order
FROM (
    
    SELECT *
    FROM plan_1
    WHERE customer_id IN (1,2,13,15,16,18,19)
    
    UNION

    SELECT *
    FROM plan_2
    WHERE customer_id IN (1,2,13,15,16,18,19)
    
    UNION
    
    SELECT *
    FROM plan_3
    WHERE customer_id IN (1,2,13,15,16,18,19)
    
    ORDER BY customer_id, payment_date) AS pay_date

JOIN plans
    ON plans.plan_id = pay_date.plan_id;



/*
SELECT *
FROM subscriptions
WHERE customer_id IN (1,2,3,19);
*/


-------

WITH change_plan_id AS (

SELECT 
    customer_id,
    GROUP_CONCAT(plan_id ORDER BY start_date) AS change_plan,
    GROUP_CONCAT(start_date ORDER BY start_date) AS change_date
FROM subscriptions
GROUP BY customer_id),
change_plan_date AS (

SELECT 
    sub.customer_id,
    sub.plan_id,
    SUBSTRING(change_date, ((FIND_IN_SET(plan_id,change_plan)-1)*10 + FIND_IN_SET(plan_id,change_plan)), 10) AS start_plan_date,
    SUBSTRING(change_date, ((FIND_IN_SET(plan_id,change_plan))*10 + FIND_IN_SET(plan_id,change_plan))+1, 10) AS end_plan_date,
    
   
    CASE 
        -- If three aspects are true, I need to reduce the price of a new plan.
        -- 1. The last day of payments is earlier than the new payment day.
        -- 2. Plan before was a paid plan.
        -- 3. The current plan is a paid plan. 

        WHEN (DAY(SUBSTRING(change_date, ((FIND_IN_SET(plan_id,change_plan)-2)*10 + FIND_IN_SET(plan_id,change_plan))-1, 10)) < DAY(SUBSTRING(change_date, ((FIND_IN_SET(plan_id,change_plan)-1)*10 + FIND_IN_SET(plan_id,change_plan)), 10))) = 1 AND (SUBSTRING(REPLACE(change_plan,',',''), (FIND_IN_SET(plan_id,change_plan)-1),1)) >0 AND plan_id IN (2,3) THEN  SUBSTRING(REPLACE(change_plan,',',''), (FIND_IN_SET(plan_id,change_plan)-1),1)
        ELSE ''
    END AS reduce_payment_plan_id
FROM subscriptions AS sub
JOIN change_plan_id
    ON change_plan_id.customer_id = sub.customer_id),

reduce_price AS (
SELECT 
    customer_id,
    plan_id,
    start_plan_date,
    reduce_payment_plan_id
FROM change_plan_date
WHERE reduce_payment_plan_id >0
),
change_plan_payments AS (


SELECT
    customer_id,
    plan_id,
    DATE(start_plan_date) AS start_plan_date,
    DATE(CASE 
        WHEN YEAR(DATE(end_plan_date)) >2020 THEN '2020-12-31'
        WHEN end_plan_date != 0 THEN end_plan_date
        ELSE '2020-12-31'
    END) AS end_plan_payments
FROM change_plan_date
WHERE plan_id !=0 ANd plan_id !=4)

SELECT *
FROM reduce_price;