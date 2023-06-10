-------------------------------------
--B. Runner and Customer Experience--
-------------------------------------

--Author: Ela Wajdzik
--Date: 17.05.2023 (update 19.05.2023)
--Tool used: Visual Studio Code & xampp


USE pizza_runner;

--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

--week started on Sunday (3.01.2021) (mode 0 -> start week on Sunday, value range 0-53, first week is with a first Sunday in this year)
SELECT
    WEEK(registration_date) AS week_of_a_year,
    COUNT(DISTINCT runner_id) AS number_of_runners_signe_up
FROM runners
GROUP BY week_of_a_year;

--week started on 1.01.2021 (on Friday)
WITH runners_temp AS (
    SELECT
       *,
       DATE(registration_date - (registration_date - DATE('2021-01-01')) %7) AS day_of_start_week
    FROM runners)
    
SELECT
    day_of_start_week,
    COUNT(runner_id) AS number_of_runners_signe_up
FROM runners_temp
GROUP BY day_of_start_week;

--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH order_time_diff AS (
SELECT
    runner_id,
    customer_orders_temp.order_id,
    TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS minutes_difference
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_orders_temp.order_id
)

SELECT
    runner_id,
    ROUND(AVG(minutes_difference),0) AS avg_minutes_to_pickup
FROM order_time_diff
GROUP BY runner_id;

--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH pizza_orders_with_time_temp AS (
SELECT
    customer_orders_temp.order_id,
    COUNT(pizza_id) AS number_of_pizza,
    TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS minutes_difference
FROM customer_orders_temp
JOIN runner_orders_temp
    ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_orders_temp.order_id
)

SELECT
    number_of_pizza,
    ROUND(AVG(minutes_difference),1) AS avg_time_prepare,
    MIN(minutes_difference) AS min_time_prepare,
    MAX(minutes_difference) AS max_time_prepare
FROM pizza_orders_with_time_temp
GROUP BY number_of_pizza;


--4.What was the average distance travelled for each customer?

SELECT
    customer_id,
    ROUND(AVG(distance),1) As avg_distance
FROM runner_orders_temp
JOIN customer_orders_temp
    ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE distance IS NOT NULL
GROUP BY customer_id;

--5.What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    MAX(duration) - MIN(duration) AS max_diff_time_delivery
FROM runner_orders_temp;

--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
    runner_id,
    order_id,
    distance,
    duration,
    ROUND(distance/(duration/60),0) AS avg_speed
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL;

--7.What is the successful delivery percentage for each runner?

WITH runner_successful_order_temp AS(
SELECT 
    runner_id,
    COUNT(order_id) AS number_of_successful_delivery
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL
GROUP BY runner_id
)

SELECT 
    runner_orders_temp.runner_id,
    COUNT(order_id) AS number_of_delivery,
    number_of_successful_delivery,
    ROUND(number_of_successful_delivery/COUNT(order_id) *100,0) AS perc_of_successful
FROM runner_orders_temp
JOIN runner_successful_order_temp
    ON runner_orders_temp.runner_id = runner_successful_order_temp.runner_id
GROUP BY runner_orders_temp.runner_id;