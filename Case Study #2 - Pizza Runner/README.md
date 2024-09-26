I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #2: 🍕 Pizza Runner
<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" alt="Image Danny's Diner - the taste of success" height="400">

## Introduction
Did you know that over **115 million kilograms** of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Available Data
Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

All datasets exist within the ```pizza_runner``` database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

## Relationship Diagram

<img width="430" alt="graf2" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/b8c108d2-0bf9-40af-867a-ae307acbf921">


## Case Study Questions
This case study includes questions about:
- Pizza Metrics
- Runner and Customer Experience
- Ingredient Optimisation
- Pricing and Ratings
- Bonus DML Challenges (DML = Data Manipulation Language)

***

***

## Solution
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code).

**Thank you in advance for reading.** If you have any comments on my work, please let me know. My email address is ela.wajdzik@gmail.com.

Additionally, I am open to new work opportunities. If you are looking for someone with my skills (or know of someone who is), I would be grateful for any information.

***

## Data Cleaning Process 
The complete SQL syntax canbe found in the file [pizza_runner_MSSQL-cleaning](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/edit/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code/pizza_runner_MSSQL-cleaning.sql)

The existing data model has several issues that need to be addressed before performing any analysis. First, I remodeled the database from its old structure to a new one. The new model includes two additional tables: ```change_orders``` and ```change_types```. These tables contain information about ingredient changes and also help clean up data types in the existing tables.

Old Relationship Diagram
![Pizza Runner](https://github.com/user-attachments/assets/d946f0d3-b188-42a6-b0cd-f6f888e1e6d2 "The old relationship diagram")

New Relationship Diagram After Remodeling
![New Relationship Diagram - pizza_runners](https://github.com/user-attachments/assets/cb63fa9f-a670-406d-89d0-f890aad68097 "The new relationship diagram")

### 🔨 ```runner_orders```

1. Standardized the null values in ```pickup_time``` and ```cancellation``` columns.
2. Added two new numeric columns, distance_km and duration_min, and populated them with data from the distance and duration columns, excluding any text.

````sql

--add new columns
ALTER TABLE runner_orders
ADD 	distance_km NUMERIC(4,1),
	duration_min NUMERIC(3,0);

--insert the numeric values into the new column
UPDATE runner_orders
SET distance_km = CAST(
			CASE distance
				WHEN 'null' THEN NULL
				ELSE TRIM('km' FROM distance)
			END 
			AS NUMERIC(4,1));

--insert the numericvalues to the new column
UPDATE runner_orders
SET duration_min = CAST(
			TRIM('minutes' FROM 
				CASE duration WHEN 'null' THEN NULL ELSE duration END) 
			AS NUMERIC(3,0));

--delate the old columns
ALTER TABLE runner_orders
DROP COLUMN duration, distance;
````

After these stepes, the table changes from the old vesrion (left table) to the new version (right table).
![8WC - week2 - runner_orders](https://github.com/user-attachments/assets/3005dc23-2252-4643-94af-38fd09d59b1d "The table runners_orders")

### 🔨 ```pizza_recipes```

1. Created a new table containing ```pizza_id``` and ```topping_id```, as the old table had non-atomical values in the ```toppings``` column.
2. Inserted the data from old ```pizza_recipes``` table into the new one.

````sql
-- rename the old table
EXEC sp_rename 'pizza_recipes', 'pizza_recipes_temp';

-- create the new pizza_recipes table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
	id INT IDENTITY PRIMARY KEY NOT NULL,
	pizza_id INT,
	topping_id INT NOT NULL
);

-- insert data into the new table using the STRING_SPLIT() function
INSERT INTO pizza_recipes(pizza_id, topping_id)
SELECT 
	pizza_id, 
	TRIM(value) AS topping_id
FROM pizza_recipes_temp
	CROSS APPLY STRING_SPLIT(toppings, ',');
````

After these steps, the table changes from the old version (left table) to the new version (right table).
![8WC - week 2 - pizza_recipes](https://github.com/user-attachments/assets/186ddf50-9a80-424b-8b20-ad912e3ef835 "The table runners_orders")

### 🔨 ```customer_orders```

1. Create two new tables: ```change_orders``` which include information about extras and exclusions, and ```change_types``` which defines the unique codes for extras and exclusions.
2. Creat a primary key in the ```customer_orders``` table to establish a relationship with the ```change_orders``` table.
3. Insert the data into the ```change_orders``` table.


````sql
--creat the change_types table and insert data
DROP TABLE IF EXISTS change_types;
CREATE TABLE change_types (
	change_type_id INT PRIMARY KEY,
	change_name VARCHAR(16) NOT NULL
);

INSERT INTO change_types
  (change_type_id, change_name)
VALUES
  (1, 'exclusion'),
  (2, 'extra');

--creat the change_orders table
DROP TABLE IF EXISTS change_orders;
CREATE TABLE change_orders (
  change_id INTEGER IDENTITY PRIMARY KEY,
  customer_order_id INTEGER NOT NULL,
  change_type_id INTEGER,
  topping_id INTEGER,
  CONSTRAINT change_orders_change_type_id_fk FOREIGN KEY (change_type_id) REFERENCES change_type(change_type_id),
  CONSTRAINT change_orders_topping_id_fk FOREIGN KEY (topping_id) REFERENCES pizza_toppings(topping_id),
);

--add the ID column to custumer_orders to build relationship with change_orders
ALTER TABLE customer_orders
ADD customer_order_id INT IDENTITY PRIMARY KEY NOT NULL;

--insert the data into change_orders for extras and exclusions
INSERT INTO change_orders(customer_order_id, topping_id, change_type_id)
SELECT 
	customer_order_id, 
	TRIM(value) AS topping_id,
	2 AS change_type_id
FROM customer_orders
	CROSS APPLY STRING_SPLIT(extras, ',');

INSERT INTO change_orders(customer_order_id, topping_id, change_type_id)
SELECT 
	customer_order_id, 
	TRIM(value) AS topping_id,
	1 AS change_type_id
FROM customer_orders
	CROSS APPLY STRING_SPLIT(exclusions, ',');
````

After these steps, the table changes from the old version (left table) to three new tables (right tables).
![8WC - week 2 - customer_orders](https://github.com/user-attachments/assets/77b8a282-3a77-44dd-8069-f5704227b131 "The table runners_orders")

***

## A. Pizza Metrics

This section contains basic questions and answers about orders.
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code/pizza_runner_MSSQL-all_sections.sql)

***

### 1. How many pizzas were ordered?

````sql
SELECT COUNT(*) AS number_of_ordered_pizzas
FROM customer_orders;
````

#### Result:
| number_of_ordered_pizzas | 
| ------------------------ | 
| 14                       |

Customers ordered 14 pizzas. . This corresponds to the number of rows in the ```customer_orders``` table.

### 2. How many unique customer orders were made?

````sql
SELECT COUNT(DISTINCT order_id) AS number_of_orders
FROM customer_orders;
````

#### Result:
| number_of_orders | 
| ---------------- | 
| 10               | 

Customers made 10 unique orders. This is determined by counting the distinct ```order_id``` values in the ```customer_orders``` table.

### 3. How many successful orders were delivered by each runner?

````sql
SELECT 
	runner_id,
	COUNT(*) AS number_of_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
````

#### Result:
| runner_id | number_of_orders |
| --------- | ---------------- |
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |

Three runners delivered orders, and they completed 8 successful deliveries in total.

### 4. How many of each type of pizza was delivered?

````sql
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
````

#### Steps:
- Join the ```customer_orders``` table with the ```runer_orders``` and ```pizza_names``` tables. The data from the ```customer_orders``` table provides information about the number of pizzas ordered.  To filter only the delivered orders, use the ```runner_orders``` and apply the condition ```WHERE ro.cancellation IS NULL```. To show the pizza names instead of their numeric IDs, join with the ```pizza_names``` table.
- Group the resulting data by pizza type and count the number of each type ordered.

#### Result:
| pizza_name | number_of_orders |
| ---------- | ---------------- |
| Meatlovers | 9                |
| Vegetarian | 3                |

The Meatlovers pizza (9 orders) was more popular than the Vegetarian pizza (3 orders).

### 5. How many Vegetarian and Meatlovers were ordered by each customer?

````sql
SELECT 
	co.customer_id,
	pn.pizza_name,
	COUNT(*) AS number_of_orders
FROM customer_orders co
INNER JOIN pizza_names pn
ON pn.pizza_id = co.pizza_id

GROUP BY co.customer_id, pn.pizza_name;
````

#### Result:
| pizza_name | pizza_name | number_of_orders |
|------------|------------|------------------|
| 101        | Meatlovers | 2                |
| 102        | Meatlovers | 2                |
| 103        | Meatlovers | 3                |
| 104        | Meatlovers | 3                |
| 101        | Vegetarian | 1                |
| 102        | Vegetarian | 1                |
| 103        | Vegetarian | 1                |
| 105        | Vegetarian | 1                |

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
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
````

#### Steps:
- Joined the data from ```customer_orderes``` table with the ```runner_orderes``` table to filter for only delivered orders (using the condition ```WHERE ro.cancellation IS NULL```).
- Group the data by  each order using ```GROUP BY co.order_id```.
- Select the largest order using the ```TOP()``` function, sorting the data by the number of pizzas in descending order. ```TOP(1)``` and ```ORDER BY COUNT(*) DESC```.

#### Result:
| order_id | number_of_pizzaa_in_order |
|----------|---------------------------|
| 4        | 3                         |


### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
WITH pizza_with_changes AS (
	SELECT 
		DISTINCT customer_order_id,
		1 AS had_change
	FROM change_orders)

SELECT 
	co.customer_id,
	CASE had_change WHEN 1 THEN 1 ELSE 0 END AS had_change, -- 1 if the pizza was changed, 0 if the pizza was not changed
	COUNT(*) AS number_of_pizzas
FROM customer_orders co
INNER JOIN runner_orders ro
ON co.order_id = ro.order_id
LEFT JOIN pizza_with_changes pc
ON pc.customer_order_id = co.customer_order_id

WHERE ro.cancellation IS NULL
GROUP BY co.customer_id,
	CASE had_change WHEN 1 THEN 1 ELSE 0 END;
````


#### Steps:
- Create a temporary ```pizza_with_changes``` table, which includes the ```customer_order_id``` values that had any changes. I used a ```CTE``` on the data from the ```change_orders``` table. 
- Select olny the delivery orders with ```WHERE ro.cancellation IS NULL```
- Group the data by ```customer_id``` and use a ```CASE``` clause to differentiate between pizzas that had changes and those that didn't: ```CASE had_change WHEN 1 THEN 1 ELSE 0 END```. The ```had_change``` column flags whether the pizza was changed (1) or not changed (0).


#### Result:
| customer_id | had_change | number_of_pizzas |
|-------------|------------|------------------|
| 101         | 0          | 2                |
| 102         | 0          | 3                |
| 104         | 0          | 1                |
| 103         | 1          | 3                |
| 104         | 1          | 2                |
| 105         | 1          | 1                |


### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
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
````

#### Steps:
- Create a temporary table ```pizza_with_exclusions_and_extras``` containing the ```customer_order_id```values that include both exclusions and extras. To combine the two conditions, use an ```INSERSECT``` clause with the ```CTE```. 
- Select only the delivered orders and count the number of pizzas.

#### Result:
| number_of_pizzas | 
|------------------|
| 1                |


### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT
	DATEPART(hour, order_time) AS order_hour,
	COUNT(*) AS number_of_pizzas
FROM customer_orders
GROUP BY DATEPART(hour, order_time);
````

#### Steps:
- Select the hour from the ```order_time``` column using the ```DATAPART()``` function.
- Group the data by the hour of the order. This calculation includes all orders, not just the delivered one.

#### Result:
| order_hour | number_of_pizzas | 
|------------|------------------|
| 11         | 1                |
| 13         | 3                |
| 18         | 3                |
| 19         | 1                |
| 21         | 3                |
| 23         | 3                |


### 10. What was the volume of orders for each day of the week?

````sql
--set Monday is first day of week
SET DATEFIRST 1;

SELECT 
	DATEPART(WEEKDAY, order_time) AS weekday,
	COUNT(DISTINCT order_id) AS number_of_orders
FROM customer_orders
GROUP BY DATEPART(WEEKDAY, order_time);
````

#### Steps:
- Set the first day of the week to Monday using ```SET DATEFIRST 1```.
- Group the data by the hour of the order. This calculation includes all orders, not just the delivered one.


#### Result:
| weekday | number_of_orders | 
|---------|------------------|
| 3       | 5                |
| 4       | 2                |
| 5       | 1                |
| 6       | 2                |


## B. Runner and Customer Experience

This section contains basic questions and answers about orders.
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code/pizza_runner_MSSQL-all_sections.sql)

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SELECT 
	CEILING(DATEPART(dayofyear, registration_date) / 7.0) AS number_of_week,
	COUNT(*) AS number_of_runners
FROM runners
GROUP BY CEILING(DATEPART(dayofyear, registration_date) / 7.0);
````

#### Steps:
- Calculate the week number using the ```DATAPART()``` function to get the day of the year, then divide it by 7 and round up to the whole number using the ```CEILING()``` function: ```CEILING(DATEPART(dayofyear, registration_date) / 7.0)```
- Group the data by the calculated week number.   

#### Result:
| number_of_week | number_of_runners | 
|----------------|-------------------|
| 1              | 2                 |
| 2              | 1                 |
| 3              | 1                 |


### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
WITH runner_pickup_times AS (
	SELECT 
		ro.order_id,
		ro.runner_id,
		DATEDIFF(minute, co.order_time, ro.pickup_time) AS pickup_time
	FROM runner_orders ro
	LEFT JOIN customer_orders co
	ON co.order_id = ro.order_id

	WHERE ro.cancellation IS NULL
	GROUP BY 	ro.order_id, ro.runner_id, ro.pickup_time, co.order_time)

SELECT
	runner_id,
	AVG(pickup_time) AS avg_pickup_time
FROM  runner_pickup_times
GROUP BY runner_id;
````

#### Steps:
- Creat a temporary ```CTE``` table that includes the pickup time for every delivered orders. The pickup time is calculeted using the ```DATEDIFF()``` function with the parameter set to minutes: ```DATEDIFF(minute, co.order_time, ro.pickup_time)```.
- Using the data from the temporary table, calculate the average of pickup time for each runner.

#### Result:
| runner_id | avg_pickup_time | 
|-----------|-----------------|
| 1         | 14              |
| 2         | 20              |
| 3         | 10              |

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql 
WITH orders_with_prepare_times AS (
	SELECT 
		co.order_id,
		COUNT(*) AS number_of_pizzas,
		DATEDIFF(minute, MIN(co.order_time), MIN(ro.pickup_time)) AS prepare_time_min
	FROM customer_orders co
	INNER JOIN runner_orders ro
	ON ro.order_id = co.order_id

	WHERE ro.cancellation IS NULL
	GROUP BY co.order_id)

SELECT 
	number_of_pizzas AS number_of_pizzas_in_order,
	AVG(prepare_time_min) AS avg_prepare_time_min,
	MIN(prepare_time_min) AS min_prepare_time_min,	-- it is not necessary 
	MAX(prepare_time_min) AS max_prepare_time_min	-- it is not necessary 
FROM orders_with_prepare_times
GROUP BY number_of_pizzas;
````

In calculation ```DATEDIFF(minute, MIN(co.order_time), MIN(ro.pickup_time))``` I used the aggregation function ```MIN()```, but the ideal approach would be use the aggregation function ```ANY_VALUE()```. Unfortunately, ```ANY_VALUE()``` is not supported in Microsoft SQL Server (although it works in Oracle and Postgres).

#### Result:
![Zrzut ekranu 2024-09-23 140754](https://github.com/user-attachments/assets/91abd117-4d68-4bfb-a2f3-a0670e547cc7)

Base on the collected data, we can speculate that each pizza in an order adds around 10 minutes of preparation time. An order with one pizza takes approximately 10 minutes, with two pizzas around 20 minutes, and so on.

### 4. What was the average distance travelled for each customer?

````sql
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
````

#### Result:
![Zrzut ekranu 2024-09-23 144010](https://github.com/user-attachments/assets/de62c09e-eb9d-4490-8857-f9ea73b1d991)

All customers live approximately 20 km from the Pizza Runner headquarters.

### 5. What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT 
	MAX(duration_min) - MIN(duration_min) AS difference_delivery_time
FROM runner_orders
WHERE cancellation IS NULL;
````

#### Result:
| difference_delivery_time |
|--------------------------|
| 30                       | 

The differences is 30 minutes. The shortest delivery took 10 minutes, and the longest took 40 minutes.

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT 
	order_id,
	runner_id,
	CAST (distance_km / (duration_min /60.0) AS NUMERIC(3,0)) AS avg_speed
	--DATEPART(HOUR, pickup_time)
FROM runner_orders
WHERE cancellation IS NULL;
````

#### Result:
![Zrzut ekranu 2024-09-23 150354](https://github.com/user-attachments/assets/630e0948-a673-4d86-bbb0-da209f58569c)

It appears that Runner 2 is using a faster vehicle than the rest of the runners. We can assume that the average speed of delivery is around 40 kilometers per hour.

### 7. What is the successful delivery percentage for each runner?

````sql
SELECT 
	runner_id,
	CAST( SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)* 100.0 / COUNT(*) AS NUMERIC(4,0)) AS perc_of_successful_delivery
FROM runner_orders
GROUP BY runner_id;
````

#### Result:
![Zrzut ekranu 2024-09-23 150613](https://github.com/user-attachments/assets/2f8eda6b-7511-4e6a-ae71-0abd2d9eb05b)

The first runner (runner_id = 1) has the highest success rate in delivering food.


***

## C. Ingredient Optimisation

This section contains questions and answers about the ingredients in pizzas and changes in orders. 
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code/pizza_runner_MSSQL-all_sections.sql)

### 1. What are the standard ingredients for each pizza?

````sql
SELECT
	pn.pizza_name,
	STRING_AGG (pt.topping_name, ', ') AS ingredients
FROM pizza_recipes pr
INNER JOIN pizza_names pn
ON pn.pizza_id = pr.pizza_id
INNER JOIN pizza_toppings pt
ON pt.topping_id = pr.topping_id
GROUP BY pn.pizza_name;
````
![Zrzut ekranu 2024-09-23 153655](https://github.com/user-attachments/assets/7f172604-fd39-4008-b88d-fd231bdc500e)

### 2. What was the most commonly added extra?

````sql
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
````
![Zrzut ekranu 2024-09-23 153823](https://github.com/user-attachments/assets/57b73660-1b22-47b8-b329-60f6c23e7d86)

Customers of Pizza Runner seem to like adding becon to their pizza. Creating a new kind of pizza with backon could be a good move for the business.

### 3. What was the most common exclusion?

````sql
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
````
![Zrzut ekranu 2024-09-23 154144](https://github.com/user-attachments/assets/15ea1fe3-4357-4ba0-9649-e10ac389c225)

The most commonly excluded ingredient was cheese. This suggests that some customers may be vegan, so adding vegan options to the menu could be a good idea.

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

````sql 
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
````

#### Steps:
- Create two temporary tables with lists of extras and exclusions using the ```STRING_AGG()``` functions: ```'Extra ' + STRING_AGG(pt.topping_name, ', ')```.
- Create the final list in the expected format using a ```CONCAT()``` function: ```CONCAT(pn.pizza_name, ' - ' + exc.list_of_exclusions, ' - ' + ext.list_of_extras)```.

#### Result:
![Zrzut ekranu 2024-09-23 154407](https://github.com/user-attachments/assets/6bdaea05-8eae-4d72-bc11-328ed685a049)

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meatlovers: 2xBacon, Beef, ... , Salami"

````sql
WITH all_ingredients AS (
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

all_count_ingredients AS (
	SELECT 
		ai.customer_order_id,
		pn.pizza_name,
		pt.topping_name,
		SUM(ai.number) AS number
	FROM all_ingredients ai
	INNER JOIN pizza_names pn
	ON ai.pizza_id = pn.pizza_id
	INNER JOIN pizza_toppings pt
	ON ai.topping_id = pt.topping_id
	GROUP BY ai.customer_order_id, pn.pizza_name, pt.topping_name
	HAVING SUM(ai.number) > 0)
	
SELECT 
	customer_order_id,
	pizza_name,
	STRING_AGG(	CASE number 
				WHEN 1 THEN topping_name
				ELSE CAST(number AS VARCHAR(3)) + 'x' + topping_name
			END, ', ')
		WITHIN GROUP (ORDER BY topping_name ASC) AS list_of_ingredient
FROM all_count_ingredients
GROUP BY customer_order_id, pizza_name;
````

#### Steps:
- Create a temporary table ```all_ingredients``` containing the columns ```customer_order_id```, ```pizza_id```, ```topping_id``` and ```number```. The ```number``` column contains 1 if the toppings should be on the pizza and -1 if the topping shoud be excluded. 
- Create a second temporary table ```all_count_ingredients``` based on the ```all_ingredients``` table, which aggregates the informaction about toppings and adds the pizza name and topping names. In this table, filter out toppings that should not be used on the pizza (```HAVING SUM(ai.number) > 0```).
- Generate a list of topping names for each ordered pizza using the ```STRING_AGG()``` function and ```CASE``` to add the information about multiples (e.g., "2x" for toppings used twice).

#### Result:
![Zrzut ekranu 2024-09-23 162852](https://github.com/user-attachments/assets/d69a0f57-3046-4dba-bcdd-50942fbd0364)


### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

````sql
WITH all_ingredients AS (
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
	pt.topping_name,
	SUM(ai.number) AS total_quantity
FROM all_ingredients ai
INNER JOIN pizza_names pn
ON ai.pizza_id = pn.pizza_id
INNER JOIN pizza_toppings pt
ON ai.topping_id = pt.topping_id
GROUP BY pt.topping_name
HAVING SUM(ai.number) > 0
ORDER BY SUM(number) DESC;
````

#### Steps:
- Create a temporary table ```all_ingredients``` with columns ```customer_order_id```, ```pizza_id```, ```topping_id``` and ```number```, where ```number``` is 1 for toppings should be included and -1 for toppings that shoud be excluded. The step is the same as in Question 5.
- Group all ingriedients by the name of topping and sort them by usage frequency. 

#### Result:
![Zrzut ekranu 2024-09-23 165448](https://github.com/user-attachments/assets/37d269a5-b2b7-4dae-9058-bb254eaf3eee)

The most common ingrediont is bacon. Customers of Pizza Runner seem to like becon on their pizza (it was also the most popular extra added). Creating a new kind of pizza with backon could be a good move for the business.

***

## D. Pricing and Ratings

This section contains questions and answers about the pizza pricing and ranner ratings. 
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code/pizza_runner_MSSQL-all_sections.sql)

### 1. If a Meatlovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?


````sql
SELECT 
	SUM(CASE co.pizza_id
			WHEN 1 THEN 12
			WHEN 2 THEN 10
		END) AS total_revenue
FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL; --the result includes only the delivered orders
````

#### Result:
| total_revenue |
|---------------|
| 138           | 


### 2. What if there was an additional $1 charge for any pizza extras?

````sql
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
````

#### Steps:
- Create a temporary table (```CTE```) with information about the number of extras.
- Calculate the total price using the ```CASE``` clause.

#### Result:
| total_revenue |
|---------------|
| 142           | 

### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

````sql
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
````

#### Relationship Diagram:



### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
* ``customer_id``
* ``order_id``
* ``runner_id``
* ``rating``
* ``order_time``
* ``pickup_time``
* Time between order and pickup
* Delivery duration
* Average speed
* Total number of pizzas

````sql
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
````

#### Result:

### 5. If a Meatlovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

````sql
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
````

#### Steps:
- Declare two local variables: one for the total cost and one for the total revenue.
- Variable ```@v_cost``` containts the total delivery cost: ```SUM(distance_km) * 0.30```.
- Variable ```@v_revenue``` containts the total revenue from pizza sales: ```CASE co.pizza_id WHEN 1 THEN 12 WHEN 2 THEN 10 END```.
- Print the total profit for Pizza Runner ```PRINT @v_revenue - @v_cost```

#### Result:
$94,44

*** 
## E. Bonus Questions

### If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an ``INSERT`` statement to demonstrate what would happen if a new ``Supreme`` pizza with all the toppings was added to the Pizza Runner menu?

````sql
-- add a new type of pizza

INSERT INTO pizza_names(pizza_id, pizza_name)
VALUES (3, 'Supreme');

/*
SELECT *
FROM pizza_recipes;

SELECT *
FROM pizza_toppings;
*/

-- add information about the toppings for the new pizza

INSERT INTO pizza_recipes(pizza_id, topping_id)
SELECT 
	3,
	topping_id
FROM pizza_toppings;
````