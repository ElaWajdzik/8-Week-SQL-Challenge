--------------------
--A. Pizza Metrics--
--------------------

--Author: Ela Wajdzik
--Date: 15.05.2023
--Tool used: Visual Studio Code & xampp


--6.What was the maximum number of pizzas delivered in a single order?
--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--8.How many pizzas were delivered that had both exclusions and extras?
--9.What was the total volume of pizzas ordered for each hour of the day?
--10.What was the volume of orders for each day of the week?


--1.How many pizzas were ordered?

SELECT 
    COUNT(pizza_id) AS number_of_orders
FROM customer_orders_temp;

--2.How many unique customer orders were made?

SELECT 
    COUNT(DISTINCT customer_id) AS number_of_customers
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
    pizza_id,
    COUNT(pizza_id) AS number_of_delivered_orders
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE pickup_time IS NOT NULL
GROUP BY pizza_id;

--5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
    customer_id,
    pizza_names.pizza_name,
    COUNT(pizza_names.pizza_name) AS number_of_orders
FROM customer_orders_temp
JOIN pizza_names
    ON customer_orders_temp.pizza_id = pizza_names.pizza_id
GROUP BY customer_id, pizza_name;

SELECT * FROM pizza_names;