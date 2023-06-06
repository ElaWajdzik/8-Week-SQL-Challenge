--------------------------
--D. Pricing and Ratings--
--------------------------

--Author: Ela Wajdzik
--Date: 6.06.2023
--Tool used: Visual Studio Code & xampp

USE pizza_runner;

/*1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for 
changes - how much money has Pizza Runner made so far if there are no delivery fees?*/

--Meatlovers - 1 - $12
--Vegetarian - 2 - $10

SELECT 
    SUM(CASE 
        WHEN pizza_id = 1 THEN 12
        WHEN pizza_id = 2 THEN 10
        ELSE 0
    END) AS total_price
FROM customer_orders_temp;

/*2. What if there was an additional $1 charge for any pizza extras?
* Add cheese is $1 extra*/

-- +$1 for every extras
--? cheese is $2

WITH pizza_extras_price AS(
SELECT 
    id,
    pizza_id,
    CASE 
        WHEN extras != '' THEN LENGTH(extras)-LENGTH(REPLACE(extras,',',''))+1
        ELSE 0
    END AS price_of_extras
FROM customer_orders_temp),
pizza_price AS(
SELECT 
    pizza_id,
    CASE 
        WHEN pizza_id = 1 THEN 12
        WHEN pizza_id = 2 THEN 10
        ELSE 0
    END AS price
FROM customer_orders_temp
GROUP BY pizza_id
)

SELECT 
    SUM(price + price_of_extras) AS total_price
FROM customer_orders_temp AS co
JOIN pizza_price
ON co.pizza_id = pizza_price.pizza_id
LEFT JOIN pizza_extras_price
ON co.id = pizza_extras_price.id;

/*3. The Pizza Runner team now wants to add an additional ratings system that allows customers to 
rate their runner, how would you design an additional table for this new dataset - generate a schema 
for this new table and insert your own data for ratings for each successful customer order between 1 to 5.*/

--rating from 1 to 5
--order_id

DROP TABLE IF EXISTS runner_rating;
CREATE TABLE runner_rating (
  order_id int,
  rating int
);
INSERT INTO runner_rating
  (order_id, rating)
VALUES
  (1, 4),
  (2, 5),
  (3, 3),
  (4, 5),
  (5, 4),
  (6, NULL),
  (7, 5),
  (8, 5),
  (9, NULL),
  (10, 4);

/*4. Using your newly generated table - can you join all of the information together to form a table which 
has the following information for successful deliveries?
* customer_id
* order_id
* runner_id
* rating
* order_time
* pickup_time
* Time between order and pickup
* Delivery duration
* Average speed
* Total number of pizzas*/



* Time between order and pickup


;

WITH customer AS(
SELECT 
    order_id,
    customer_id,
    COUNT(pizza_id) AS number_of_pizza,
    order_time
FROM customer_orders_temp
GROUP BY order_id)

SELECT  
    c.customer_id,
    ro.order_id,
    ro.runner_id,
    ro.duration,
    c.order_time,
    ro.pickup_time,
    ROUND(ro.distance/ro.duration*60,0) AS avg_speed,
    TIMESTAMPDIFF(MINUTE, c.order_time, ro.pickup_time) AS minutes_difference,
    --MINUTE(ro.pickup_time - c.order_time) AS time,
    c.number_of_pizza,
    rr.rating
FROM runner_orders_temp AS ro
JOIN customer AS c
ON ro.order_id = c.order_id
JOIN runner_rating AS rr
ON ro.order_id = rr.order_id;

SELECT
    runner_id,
    customer_orders_temp.order_id,
    TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS minutes_difference
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE pickup_time IS NOT NULL
GROUP BY order_id;


/*5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner 
is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?*/