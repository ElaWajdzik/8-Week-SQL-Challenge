-------------------------------------
--B. Runner and Customer Experience--
-------------------------------------

--Author: Ela Wajdzik
--Date: 17.05.2023
--Tool used: Visual Studio Code & xampp


USE pizza_runner;


--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
    WEEK(registration_date) AS week_of_a_year,
    COUNT(DISTINCT runner_id)
FROM runners
GROUP BY week_of_a_year;

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
--4.What was the average distance travelled for each customer?
--5.What was the difference between the longest and shortest delivery times for all orders?
--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
--7.What is the successful delivery percentage for each runner?