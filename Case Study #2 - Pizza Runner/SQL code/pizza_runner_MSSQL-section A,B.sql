--------------------
--A. Pizza Metrics--
--------------------

--Author: Ela Wajdzik
--Date: 18.09.2024
--Tool used: Microsoft SQL Server


--USE pizza_runner;

-- 1. How many pizzas were ordered?

SELECT COUNT(*) AS number_of_ordered_pizzas
FROM customer_orders;

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT customer_id) AS number_of_customers
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT COUNT(*) AS number_of_orders
FROM runner_orders
WHERE cancellation IS NULL;

-- 4. How many of each type of pizza was delivered?

SELECT 
	pn.pizza_name,
	COUNT(*) AS number_of_orders
FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
INNER JOIN pizza_names pn
ON pn.pizza_id = co.pizza_id

WHERE ro.cancellation IS NULL
GROUP BY pn.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
	co.customer_id,
	pn.pizza_name,
	COUNT(*) AS number_of_orders
FROM customer_orders co
--INNER JOIN runner_orders ro
--ON ro.order_id = co.order_id
INNER JOIN pizza_names pn
ON pn.pizza_id = co.pizza_id

--WHERE ro.cancellation IS NULL
GROUP BY co.customer_id, pn.pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT 
	TOP(1)
	co.order_id,
	COUNT(*) AS number_of_pizzas_in_order
FROM customer_orders co
INNER JOIN runner_orders ro
ON co.order_id = ro.order_id

WHERE ro.cancellation IS NULL
GROUP BY co.order_id
ORDER BY COUNT(*) DESC;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

WITH pizza_with_changes AS (
	SELECT 
		DISTINCT customer_order_id,
		1 AS had_change
	FROM change_orders)

SELECT 
	co.customer_id,
	CASE had_change WHEN 1 THEN 1 ELSE 0 END AS had_change,
	COUNT(*) AS number_of_pizzas
FROM customer_orders co
INNER JOIN runner_orders ro
ON co.order_id = ro.order_id
LEFT JOIN pizza_with_changes pc
ON pc.customer_order_id = co.customer_order_id

WHERE ro.cancellation IS NULL
GROUP BY co.customer_id,
	CASE had_change WHEN 1 THEN 1 ELSE 0 END;

-- 8. How many pizzas were delivered that had both exclusions and extras?

WITH pizza_with_exclusions_and_extras AS (
	SELECT DISTINCT customer_order_id
	FROM change_orders
	WHERE change_type_id = 1

	INTERSECT

	SELECT DISTINCT customer_order_id
	FROM change_orders
	WHERE change_type_id = 2)

SELECT COUNT(*) AS number_of_pizzas
FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
INNER JOIN pizza_with_exclusions_and_extras p
ON p.customer_order_id = co.customer_order_id

WHERE ro.cancellation IS NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT
	DATEPART(hour, order_time) AS order_hour,
	COUNT(*) AS number_of_pizzas
FROM customer_orders
GROUP BY DATEPART(hour, order_time);

-- 10. What was the volume of orders for each day of the week?

--set Monday is first day of week
SET DATEFIRST 1;

SELECT 
	DATEPART(WEEKDAY, order_time) AS weekday,
	COUNT(DISTINCT order_id) AS number_of_orders
FROM customer_orders
GROUP BY DATEPART(WEEKDAY, order_time);


-------------------------------------
--B. Runner and Customer Experience--
-------------------------------------

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
	CEILING(DATEPART(dayofyear, registration_date) / 7.0) AS number_of_week,
	COUNT(*) AS number_of_runners
FROM runners
GROUP BY CEILING(DATEPART(dayofyear, registration_date) / 7.0);

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT
	runner_id,
	CAST (CEILING(AVG(duration_min)) AS NUMERIC(3,0)) AS avg_duration_min
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT 
	co.order_id,
	COUNT(*) AS number_of_pizzas,
	DATEDIFF(minute, MIN(co.order_time), MIN(ro.pickup_time)) AS prepare_time_min
FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id

WHERE ro.cancellation IS NULL
GROUP BY co.order_id;

-- 4. What was the average distance travelled for each customer?

WITH orders_with_distance AS (
	SELECT 
		co.order_id,
		co.customer_id,
		MIN(ro.distance_km) AS distance_km
	FROM customer_orders co
	INNER JOIN runner_orders ro
	ON co.order_id = ro.order_id

	WHERE ro.cancellation IS NULL
	GROUP BY co.order_id, co.customer_id)

SELECT 
	customer_id,
	CAST (AVG(distance_km) AS NUMERIC(4,1)) AS avg_distance_km
FROM orders_with_distance 
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT 
	MAX(duration_min) - MIN(duration_min) AS difference_delivery_time
FROM runner_orders
WHERE cancellation IS NULL;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
	order_id,
	runner_id,
	CAST (distance_km / (duration_min /60.0) AS NUMERIC(3,0)) AS avg_speed
	--DATEPART(HOUR, pickup_time)
FROM runner_orders
WHERE cancellation IS NULL;

-- 7. What is the successful delivery percentage for each runner?

SELECT 
	runner_id,
	CAST( SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)* 100.0 / COUNT(*) AS NUMERIC(4,0)) AS perc_of_successful_delivery
FROM runner_orders
GROUP BY runner_id;