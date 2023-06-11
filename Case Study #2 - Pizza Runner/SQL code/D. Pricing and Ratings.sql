--------------------------
--D. Pricing and Ratings--
--------------------------

--Author: Ela Wajdzik
--Date: 6.06.2023 (update 7.06.2023)
--Tool used: Visual Studio Code & xampp

USE pizza_runner;

/*1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for 
changes - how much money has Pizza Runner made so far if there are no delivery fees?*/

--Meatlovers - 1 - $12
--Vegetarian - 2 - $10

--The calculation is based on the data in the table customer_orders (which includes every order).
SELECT 
    SUM(CASE 
        WHEN pizza_id = 1 THEN 12
        WHEN pizza_id = 2 THEN 10
        ELSE 0
    END) AS total_price
FROM customer_orders_temp;

--Based on the data in the table runner_order, I know that some orders were cancelled. 

SELECT 
    SUM(CASE 
        WHEN pizza_id = 1 THEN 12
        WHEN pizza_id = 2 THEN 10
        ELSE 0
    END) AS total_price
FROM customer_orders_temp AS co
JOIN runner_orders_temp AS ro
ON co.order_id = ro.order_id
WHERE ro.cancellation = '';

--Pizza Runner can earn $160, but two orders were cancelled. They earned $138.


/*2. What if there was an additional $1 charge for any pizza extras?
* Add cheese is $1 extra*/

-- +$1 for every extras

--I didn't count the orders that were cancelled.

WITH pizza_extras_price AS(
SELECT 
    id,
    pizza_id,
    CASE 
        WHEN extras != '' THEN LENGTH(extras)-LENGTH(REPLACE(extras,',',''))+1
        ELSE 0
    END AS price_of_extras
FROM customer_orders_temp AS co
JOIN runner_orders_temp AS ro
ON co.order_id = ro.order_id
WHERE ro.cancellation = ''),
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

--If extras didn't change the price, the Pizza Runner would have earned $138. But if every extra adds $1 to the price, 
--they will earn $142 (because in the data, there were 4 extras).


/*3. The Pizza Runner team now wants to add an additional ratings system that allows customers to 
rate their runner, how would you design an additional table for this new dataset - generate a schema 
for this new table and insert your own data for ratings for each successful customer order between 1 to 5.*/

/*I will create a table that includes only the data about order_id and rating (int from 1 to 5). If we know the order_id
we will know which runner delivered the food and what the order contains.*/

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
    rr.rating,
    c.order_time,
    ro.pickup_time,
    TIMESTAMPDIFF(MINUTE, c.order_time, ro.pickup_time) AS minutes_between_order_and_pickup,
    ro.duration,
    ROUND(ro.distance/(ro.duration/60),0) AS avg_speed,
    c.number_of_pizza
    
FROM runner_orders_temp AS ro
JOIN customer AS c
ON ro.order_id = c.order_id
JOIN runner_rating AS rr
ON ro.order_id = rr.order_id
WHERE ro.cancellation = '';


/*5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner 
is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?*/

--Meatlovers - 1 - $12
--Vegetarian - 2 - $10
--extras - $0
--runner is paid $0.3 per kilometre

--In this data, this case doesn't exist, but I assumed that if the paid for runner is more than the cost of the order, the Pizza Runner will have a loss.
--e.g. If someone orders one vegetarian pizza (Vegetarian) and the runner needs to travel to the customer more than 34 km.

WITH runner_paid AS(
SELECT 
    order_id,
    cancellation,
    ROUND(distance * 0.3,1) AS paid_for_km
FROM runner_orders_temp),
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
),
pizza_profit AS(
SELECT 
    co.order_id,
    SUM(pp.price)-rp.paid_for_km AS profit
FROM customer_orders_temp AS co
JOIN pizza_price AS pp
ON co.pizza_id = pp.pizza_id
JOIN runner_paid AS rp
ON co.order_id = rp.order_id
WHERE rp.cancellation = ''
GROUP BY co.order_id
)


SELECT 
    SUM(profit) AS total_profit
FROM pizza_profit;

--The Pizza Runner can earn $94,5 if they pay runners $0,3 per kilometer. It means that the runners earn together $43,5.

