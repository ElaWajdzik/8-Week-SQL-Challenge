--------------------
--A. Pizza Metrics--
--------------------

--Author: Ela Wajdzik
--Date: 18.09.2024 (update 20.09.2024)
--Tool used: Microsoft SQL Server


--USE pizza_runner;

-- 1. How many pizzas were ordered?

SELECT COUNT(*) AS number_of_ordered_pizzas
FROM customer_orders;

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS number_of_orders
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT 
	runner_id,
	COUNT(*) AS number_of_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

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

------------------------------
--C. Ingredient Optimisation--
------------------------------

-- 1. What are the standard ingredients for each pizza?

SELECT
	pn.pizza_name,
	STRING_AGG (pt.topping_name, ', ') AS ingredients
FROM pizza_recipes pr
INNER JOIN pizza_names pn
ON pn.pizza_id = pr.pizza_id
INNER JOIN pizza_toppings pt
ON pt.topping_id = pr.topping_id
GROUP BY pn.pizza_name;

-- 2. What was the most commonly added extra?

SELECT 
	pt.topping_name,
	COUNT(*) AS number_of_added_toppings
FROM change_orders co
INNER JOIN change_type ct
ON co.change_type_id = ct.change_type_id
INNER JOIN pizza_toppings pt
ON pt.topping_id = co.topping_id

WHERE ct.change_name = 'extra'
GROUP BY pt.topping_name
ORDER BY COUNT(*) DESC;

-- 3. What was the most common exclusion?

SELECT 
	pt.topping_name,
	COUNT(*) AS number_of_added_toppings
FROM change_orders co
INNER JOIN change_type ct
ON co.change_type_id = ct.change_type_id
INNER JOIN pizza_toppings pt
ON pt.topping_id = co.topping_id

WHERE ct.change_name = 'exclusion'
GROUP BY pt.topping_name
ORDER BY COUNT(*) DESC;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--			Meatlovers
--			Meatlovers - Exclude Beef
--			Meatlovers - Extra Bacon
--			Meatlovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH pizza_exclusions AS (
	SELECT 
		co.customer_order_id,
		'Exclude ' + STRING_AGG(pt.topping_name, ', ') AS list_of_exclusions
	FROM change_orders co
	INNER JOIN pizza_toppings pt
	ON co.topping_id = pt.topping_id
	wHERE co.change_type_id = 1 --1 is exclusion
	GROUP BY co.customer_order_id),

pizza_extras AS (
	SELECT 
		co.customer_order_id,
		'Extra ' + STRING_AGG(pt.topping_name, ', ') AS list_of_extras
	FROM change_orders co
	INNER JOIN pizza_toppings pt
	ON co.topping_id = pt.topping_id
	wHERE co.change_type_id = 2 --2 is extras
	GROUP BY co.customer_order_id)

SELECT
	co.customer_order_id,
	CONCAT(pn.pizza_name, ' - ' + exc.list_of_exclusions, ' - ' + ext.list_of_extras)
FROM customer_orders co
INNER JOIN pizza_names pn
ON pn.pizza_id = co.pizza_id
LEFT JOIN pizza_exclusions exc
ON co.customer_order_id = exc.customer_order_id
LEFT JOIN pizza_extras ext
ON co.customer_order_id = ext.customer_order_id;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--			For example: "Meatlovers: 2xBacon, Beef, ... , Salami"

WITH all_ingredient AS (
	SELECT 
		co.customer_order_id,
		co.pizza_id,
		pr.topping_id,
		1 AS number
	FROM customer_orders co
	INNER JOIN pizza_recipes pr
	ON co.pizza_id = pr.pizza_id

	UNION ALL

	SELECT 
		cho.customer_order_id,
		co.pizza_id,
		cho.topping_id,
		CASE cho.change_type_id WHEN 1 THEN -1 ELSE 1 END AS number
	FROM change_orders cho
	LEFT JOIN customer_orders co
	ON co.customer_order_id = cho.customer_order_id),

all_count_ingredient AS (
	SELECT 
		ai.customer_order_id,
		pn.pizza_name,
		pt.topping_name,
		SUM(ai.number) AS number
	FROM all_ingredient ai
	INNER JOIN pizza_names pn
	ON ai.pizza_id = pn.pizza_id
	INNER JOIN pizza_toppings pt
	ON ai.topping_id = pt.topping_id
	GROUP BY ai.customer_order_id, pn.pizza_name, pt.topping_name
	HAVING SUM(ai.number) > 0)
	
SELECT 
	customer_order_id,
	pizza_name,
	STRING_AGG(CASE number 
					WHEN 1 THEN topping_name
					ELSE CAST(number AS VARCHAR(3)) + 'x' + topping_name
				END, ', ') 
			WITHIN GROUP (ORDER BY topping_name ASC) AS list_of_ingredient
FROM all_count_ingredient
GROUP BY customer_order_id, pizza_name;


-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH all_ingredient AS (
	SELECT 
		co.customer_order_id,
		co.pizza_id,
		pr.topping_id,
		1 AS number
	FROM customer_orders co
	INNER JOIN pizza_recipes pr
	ON co.pizza_id = pr.pizza_id
	INNER JOIN runner_orders ro
	ON co.order_id = ro.order_id
	WHERE ro.cancellation IS NULL

	UNION ALL

	SELECT 
		cho.customer_order_id,
		co.pizza_id,
		cho.topping_id,
		CASE cho.change_type_id WHEN 1 THEN -1 ELSE 1 END AS number
	FROM change_orders cho
	LEFT JOIN customer_orders co
	ON co.customer_order_id = cho.customer_order_id
	INNER JOIN runner_orders ro
	ON co.order_id = ro.order_id
	WHERE ro.cancellation IS NULL)


SELECT 
	--ai.customer_order_id,
	--pn.pizza_name,
	pt.topping_name,
	SUM(ai.number) AS total_quantity
FROM all_ingredient ai
INNER JOIN pizza_names pn
ON ai.pizza_id = pn.pizza_id
INNER JOIN pizza_toppings pt
ON ai.topping_id = pt.topping_id
GROUP BY pt.topping_name
HAVING SUM(ai.number) > 0
ORDER BY SUM(number) DESC;


--------------------------
--D. Pricing and Ratings--
--------------------------

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

--1 meatlovers -> $12
--2 vegetarian -> $10

SELECT 
	SUM(CASE co.pizza_id
			WHEN 1 THEN 12
			WHEN 2 THEN 10
		END) AS total_revenue
FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL;

-- 2. What if there was an additional $1 charge for any pizza extras?
--		* Add cheese is $1 extra

WITH pizza_extras AS (
	SELECT	
		customer_order_id,
		COUNT(*) AS number_of_extras
	FROM change_orders
	WHERE change_type_id = 2 --only extras
	GROUP BY customer_order_id)

SELECT 
	SUM(
		CASE co.pizza_id WHEN 1 THEN 12 WHEN 2 THEN 10 END 
			+
		CASE WHEN pe.number_of_extras IS NULL THEN 0 ELSE pe.number_of_extras END
	) AS total_revenue

FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
LEFT JOIN pizza_extras pe
ON pe.customer_order_id = co.customer_order_id
WHERE ro.cancellation IS NULL;

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you 
-- design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for 
-- each successful customer order between 1 to 5.


DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings (
	order_id INT PRIMARY KEY,
	rating INT,
	CONSTRAINT ruuner_rating_rating_chk CHECK(rating BETWEEN 1 AND 5),
	CONSTRAINT runner_ratings_order_id_fk FOREIGN KEY(order_id) REFERENCES runner_orders(order_id)
)

INSERT INTO runner_ratings(order_id, rating)
VALUES
	(1, 2),
	(2, 3),
	(3, 5),
	(4, 3),
	(5, 5),
	(6, NULL),
	(7, 4),
	(8, 4),
	(9, NULL),
	(10, 5);


-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--		0* customer_id
--		0* order_id
--		0* runner_id
--		* rating
--		0* order_time
--		0* pickup_time
--		0* Time between order and pickup
--		0* Delivery duration
--		0* Average speed
--		0* Total number of pizzas

WITH customer_order_temp AS (
	SELECT 
		order_id,
		customer_id,
		COUNT(*) AS number_of_pizzas,
		MIN(CAST(order_time AS DATETIME2)) AS order_time
	FROM customer_orders
	GROUP BY order_id, customer_id)

SELECT 
	co.customer_id,
	ro.order_id,
	ro.runner_id,
	rr.rating,
	co.order_time,
	ro.pickup_time,
	DATEDIFF(minute, (co.order_time), (ro.pickup_time)) AS prepare_time_min,
	ro.distance_km,
	ro.duration_min,
	CAST(ro.distance_km / (duration_min / 60.0) AS NUMERIC(3,0)) AS avg_speed,
	co.number_of_pizzas
FROM runner_orders ro
LEFT JOIN customer_order_temp co
ON ro.order_id = co.order_id
LEFT JOIN runner_ratings rr
ON ro.order_id = rr.order_id
WHERE ro.cancellation IS NULL;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre 
-- traveled - how much money does Pizza Runner have left over after these deliveries?


--1 meatlovers -> $12
--2 vegetarian -> $10

DECLARE @v_cost NUMERIC(6,2);  
DECLARE @v_revenue NUMERIC(6,2); 

SET @v_cost =
	(SELECT 
		CAST(SUM(distance_km) * 0.30 AS NUMERIC(6,2)) AS delivery_cost
	FROM runner_orders ro
	WHERE ro.cancellation IS NULL);

SET @v_revenue =
	(SELECT 
		SUM(CASE co.pizza_id
				WHEN 1 THEN 12
				WHEN 2 THEN 10
			END) AS total_revenue
	FROM customer_orders co
	INNER JOIN runner_orders ro
	ON ro.order_id = co.order_id
	WHERE ro.cancellation IS NULL)

PRINT @v_revenue - @v_cost


----------------------
--E. Bonus Questions--
----------------------

-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement 
-- to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

/*
SELECT *
FROM pizza_names;
*/

INSERT INTO pizza_names(pizza_id, pizza_name)
VALUES (3, 'Supreme');

/*
SELECT *
FROM pizza_recipes;

SELECT *
FROM pizza_toppings;
*/

INSERT INTO pizza_recipes(pizza_id, topping_id)
SELECT 
	3,
	topping_id
FROM pizza_toppings;

