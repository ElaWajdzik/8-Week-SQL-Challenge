--------------------
--A. Pizza Metrics--
--------------------

--Author: Ela Wajdzik
--Date: 15.05.2023 (update 16.05.2023)
--Tool used: Visual Studio Code & xampp


USE pizza_runner;

--1.How many pizzas were ordered?

SELECT 
    COUNT(pizza_id) AS number_of_orders
FROM customer_orders_temp;

--2.How many unique customer orders were made?

SELECT 
    COUNT(DISTINCT order_id) AS number_of_customers
FROM customer_orders_temp;

--3.How many successful orders were delivered by each runner?

SELECT
    runner_id,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

--4.How many of each type of pizza was delivered?

SELECT
    pizza_name,
    COUNT(customer_orders_temp.pizza_id) AS number_of_delivered_orders
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
JOIN pizza_names
    ON customer_orders_temp.pizza_id = pizza_names.pizza_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_orders_temp.pizza_id;

--5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
    customer_id,
    pizza_names.pizza_name,
    COUNT(pizza_names.pizza_name) AS number_of_orders
FROM customer_orders_temp
JOIN pizza_names
    ON customer_orders_temp.pizza_id = pizza_names.pizza_id
GROUP BY customer_id, pizza_name;

--6.What was the maximum number of pizzas delivered in a single order?

SELECT
    customer_orders_temp.order_id,
    COUNT(customer_orders_temp.order_id) AS max_number_of_pizza_in_order
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_orders_temp.order_id
ORDER BY max_number_of_pizza_in_order DESC LIMIT 1;

--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
    customer_id,
    SUM(IF(TRIM(CONCAT(extras,exclusions))='',0,1)) AS pizza_with_change,
    SUM(IF(TRIM(CONCAT(extras,exclusions))='',1,0)) AS pizza_without_change
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.pickup_time IS NOT NULL
GROUP BY customer_orders_temp.customer_id;

--8.How many pizzas were delivered that had both exclusions and extras?

SELECT
    SUM(IF(TRIM(extras)!='' AND TRIM(exclusions)!='',1,0)) AS pizza_with_extras_and_exclusions
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.pickup_time IS NOT NULL;

--9.What was the total volume of pizzas ordered for each hour of the day?

SELECT
    HOUR(order_time) AS order_hour,
    COUNT(pizza_id)
FROM customer_orders_temp
GROUP BY order_hour;

--10.What was the volume of orders for each day of the week?

SELECT
    DAYOFWEEK(order_time) AS order_day_of_week,
    COUNT(pizza_id)
FROM customer_orders_temp
GROUP BY order_day_of_week;

--DAYOFWEEK() returns a number from 1 to 7, starts from Sunday (1=Sunday)
