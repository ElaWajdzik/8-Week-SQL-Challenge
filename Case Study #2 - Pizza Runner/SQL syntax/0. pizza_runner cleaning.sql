-------------------------------
--CASE STUDY #2: Pizza Runner--
-------------------------------

--Author: Ela Wajdzik
--Date: 15.05.2023
--Tool used: Visual Studio Code & xampp


--create input 
CREATE DATABASE pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id int,
  registration_date date
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id int,
  customer_id int,
  pizza_id int,
  exclusions varchar(4),
  extras varchar(4),
  order_time timestamp
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

--I added column id because I need to have a unique identifier for each pizza in each order
--I use it in the section about ingredients (syntax SQL 'C. Ingredient Optimisation')
ALTER TABLE customer_orders
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id int,
  runner_id int,
  pickup_time varchar(19),
  distance varchar(7),
  duration varchar(10),
  cancellation varchar(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id int,
  pizza_name text
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id int,
  toppings text
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id int,
  topping_name text
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

--the end of input


--clean table customer_orders
--replace 'null' and NULL in exclusions and extras
--I don't want to change the origin input, that why I created a temporary table with changes. In the next part, I will use the table customer_orders_temp instead of customer_orders.

DROP TABLE IF EXISTS customer_orders_temp;
CREATE TEMPORARY TABLE customer_orders_temp AS(
    SELECT 
        id,
        order_id,
        customer_id,
        pizza_id,
        CASE
            WHEN exclusions LIKE 'null' OR exclusions IS NULL THEN ''
            ELSE exclusions
        END AS exclusions,
        CASE 
            WHEN extras LIKE 'null' OR extras IS NULL THEN ''
            ELSE extras
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
);

--clean table runner_orders
--remove 'null' and NULL from cancellation and pickup_time
--remove text from distance and duration and change the type of data
--I don't want to change the origin input, that why I created a temporary table with changes. In the next part, I will use the table runner_orders_temp instead of runner_orders.

DROP TABLE IF EXISTS runner_orders_temp;

CREATE TEMPORARY TABLE runner_orders_temp AS(
    SELECT
        order_id,
        runner_id,
        CASE 
            WHEN pickup_time LIKE 'null' THEN NULL
            ELSE pickup_time
        END AS pickup_time,
        CASE 
            WHEN distance like 'null' THEN NULL
            WHEN distance like '%km' THEN TRIM('km' FROM distance)
            ELSE distance
        END AS distance,
        CASE 
            WHEN duration like 'null' THEN NULL
            WHEN duration like '%minute' THEN TRIM('minute' FROM duration)
            WHEN duration like '%minutes' THEN TRIM('minutes' FROM duration)
            WHEN duration like '%mins' THEN TRIM('mins' FROM duration)
            ELSE duration
        END AS duration,
        CASE 
            WHEN cancellation LIKE 'null' OR cancellation IS NULL THEN '' 
            ELSE cancellation
        END AS cancellation
    FROM runner_orders
);

ALTER TABLE runner_orders_temp
MODIFY COLUMN pickup_time TIMESTAMP NULL;

ALTER TABLE runner_orders_temp
MODIFY COLUMN distance FLOAT NULL;

ALTER TABLE runner_orders_temp
MODIFY COLUMN duration INT NULL;

SELECT * FROM runner_orders_temp;