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


***

## Case Study Questions
This case study includes questions about:
- Pizza Metrics
- Runner and Customer Experience
- Ingredient Optimisation
- Pricing and Ratings
- Bonus DML Challenges (DML = Data Manipulation Language)

### Cleaning data 
Sytax SQL is in the file "0. pizza_runner cleaning".

First of all, I cleaned and fixed the data in tables ```customer_orders``` and ```runner_orders```. 

In the table ```customer_orders``` was a problem only with the values **null** and **NULL**. Using the clause **CASE** I replace these two problematic values. I do this operation for the columns ```exclusions``` and ```extras```.


Part of the syntax with the clause **CASE**:

````sql
CASE
    WHEN exclusions LIKE 'null' OR exclusions IS NULL THEN ''
    ELSE exclusions
END AS exclusions,  
````

In the table ```runner_orders``` there were some problems:
- column ```cancellation``` had a problem with the values **null** and **NULL**,
- columns ```distance``` and ```duration``` had a problem with the value **null**, with the extra text in the data and with the type of data,
- column ```pickup_time``` had a problem with the value **null** and with the type of data.

To fix this problem, first I use clauses **CASE** and **TRIM** to change some wrong data. Second, I use the clause **MODIFY COLUMN** to change the type of data in some columns.


Part of the syntax with clauses **CASE**mand **TRIM**:

````sql
CASE 
    WHEN duration like 'null' THEN NULL
    WHEN duration like '%minute' THEN TRIM('minute' FROM duration)
    WHEN duration like '%minutes' THEN TRIM('minutes' FROM duration)
    WHEN duration like '%mins' THEN TRIM('mins' FROM duration)
    ELSE duration
END AS duration,
````

Part of the syntax with the clause **MODIFY COLUMN**:

````sql
ALTER TABLE runner_orders_temp
MODIFY COLUMN duration INT NULL;
````

Column ```duration``` - For this column I chose the type of data **INT** because this column contains information about the duration of delivery in minutes.
Column ```distance``` - For this column, I chose the type of data **FLOAT** because this column contains information about the distance of delivery in kilometers with one number after the decimol point.
Column ```pickup_time``` - For this column I chose the type of data **TIMESTAMP** because this column contains exact time of pick up (data with hour).

I don't want to change the origin input, that why I created a temporary tables with this changes. In the next part I will use the table ```customer_orders_temp``` insted of ```customer_order``` and ```runner_orders_temp``` insted of ```runner_orders```.

***

## A. Pizza Metrics

This section contains basic questions and answers about orders.
Complete syntax is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20syntax)


### 1. How many pizzas were ordered?

````sql
SELECT 
    COUNT(pizza_id) AS number_of_orders
FROM customer_orders_temp;
````

The customers ordered 14 pizzas, this is the number of rows in table ```customer_orders_temp```.

### 2. How many unique customer orders were made?

````sql
SELECT 
    COUNT(DISTINCT order_id) AS number_of_customers
FROM customer_orders_temp;
````

The customers made 10 orders, this is the number of unique ```order_id``` in table ```customer_orders_temp```.

### 3. How many successful orders were delivered by each runner?

````sql
SELECT
    runner_id,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;
````

In the data were 10 orders, but only 8 of them were successfully delivered. Orders that were not delivered have ```pickup_time``` = NULL, which is why I use clause ```WHERE pickup_time IS NOT NULL```. Deliveries were made by three runners, and runner 1 delivered 4 orders, runner 2 delivered 3 orders, runner 4 delivered 1 order.

<img width="202" alt="CS2 - A3" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/291518dd-20f9-4abe-8396-06ae25afbeb6">

### 4. How many of each type of pizza was delivered?

````sql
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
````

To answer this question, I need to join three tables:
* ```customer_orders_temp``` - data about ``pizza_id`` in orders,
* ```runner_orders_temp``` - data about successful delivery
* ```pizza_names``` - data about the names of pizzas.

Pizza Meatlovers (9 orders) is more likely to be ordered than Pizza Vegetarian (3 orders).

<img width="262" alt="CS2 - A4" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/d61803c7-53cf-400f-a5f1-25e9f656dbc4">

### 5. How many Vegetarian and Meatlovers were ordered by each customer?

````sql
SELECT 
    customer_id,
    pizza_names.pizza_name,
    COUNT(pizza_names.pizza_name) AS number_of_orders
FROM customer_orders_temp
JOIN pizza_names
    ON customer_orders_temp.pizza_id = pizza_names.pizza_id
GROUP BY customer_id, pizza_name;
````

This code counts data from every order, not only those that were successfully delivered.

<img width="388" alt="CS2 - A5" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/291a21f3-6365-4d34-8e49-8a237b6f1ecb">

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
SELECT
    customer_orders_temp.order_id,
    COUNT(customer_orders_temp.order_id) AS number_of_pizza_in_order
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_orders_temp.order_id
ORDER BY number_of_pizza_in_order DESC LIMIT 1;
````

In order 4 (```order_id``` = 4) customer ordered 3 pizzas, this was the biggest order that would be successfully delivered.
To create this solution, I need to use clause **ORDER BY** (to order orders using the number of pizzas in order) with parameters **DESC** (in descending order) and **LIMIT** (to show only the first row after ordering).

<img width="256" alt="CS2 - A6" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/e062f5c6-ca25-4ced-9d6e-1ae6d15361f3">

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
SELECT
    customer_id,
    SUM(IF(TRIM(CONCAT(extras,exclusions))='',0,1)) AS pizza_with_change,
    SUM(IF(TRIM(CONCAT(extras,exclusions))='',1,0)) AS pizza_without_change
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.pickup_time IS NOT NULL
GROUP BY customer_orders_temp.customer_id;
````


To check if the ordered pizza has some changes, first I concatenate data from columns ```extras``` and ```exclusions``` and second I check if this text is empty. When text is empty, it means that pizza has made no changes.

e.g. ```SUM(IF(TRIM(CONCAT(extras,exclusions))='',0,1)) AS pizza_with_change```

Customers **101** and **102** ordered only pizzas without change. Customers **103** and **105** ordered only pizzas with changes.

<img width="404" alt="CS2 - A7" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/a1a7eb43-2dc9-42bc-8c5a-e3c6b6e90f61">

### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
SELECT
    SUM(IF(TRIM(extras)!='' AND TRIM(exclusions)!='',1,0)) AS pizza_with_extras_and_exclusions
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.pickup_time IS NOT NULL;
````

Only 1 of delivered pizza has ```extras``` and ```exclusions```.

### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT
    HOUR(order_time) AS order_hour,
    COUNT(pizza_id) AS number_of_pizza
FROM customer_orders_temp
GROUP BY order_hour;
````

The most orders are made after 12 and before 00 (but maybe the Pizza Runner is open only in these hours).

<img width="200" alt="CS2 - A9" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/f88c4207-4066-49cc-a61a-8eaa191d0e1e">


### 10. What was the volume of orders for each day of the week?

````sql
SELECT
    DAYOFWEEK(order_time) AS order_day_of_week,
    COUNT(pizza_id) AS number_of_pizza
FROM customer_orders_temp
GROUP BY order_day_of_week;
````

I use clause **DAYOFWEEK()** which returns a number from 1 to 7, starting from Sunday (1=Sunday). The most orders were made on Wednesday (5 orders) and Saturday (5 orders).

<img width="251" alt="CS2 - A10" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/6a9e6bf3-8b0a-453d-8626-bbc29fd527b9">


***  

## B. Runner and Customer Experience

This section contains questions and answers about the details of delivery and runners. 
Complete syntax is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20syntax)

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
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
````

This question was tricky because we (and standard function) usually assume that the week starts on Monday or Sunday. 1.01.2021 was Friday, which is why I can't use the function **WEEK()**. 

To calculate the result, I created a temporary table with an additional column, which was the date of last Friday.

```DATE(registration_date - (registration_date - DATE('2021-01-01')) %7)```

<img width="271" alt="CS2 - B1" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/548a0f9a-d024-4362-b068-c2ffcd4c67f0">


### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
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
````

I thought that besic arithmetic operations would work in two **TIMESTAMP** values, but they don't. To count the difference in time between pickup and ordering, I use the function **TIMESTAMPDIFF()** (with parameter **MINUTE**).

<img width="218" alt="CS2 - B2" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/72c2642e-4d58-4059-b773-f86898a56ac8">


### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
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
````


First of all, the data contains information about only eight successful delivered orders, and only one of them is the order with three pizzas. Using this data, we can say that the average prep time is growing with the number of pizzas in order, but in my opinion, we don't have enough data to deduce the true conclusion.

In this calculation, I assume that the differences between time of pickup and order only come from the time of preparation, but in the real world, this can come from many factors (e.g. a lot of different orders, not enough runners).

<img width="479" alt="CS2 - B3" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/02dbc5d0-acc3-46f6-a615-65f86cdffdfc">

### 4. What was the average distance travelled for each customer?

````sql
SELECT
    customer_id,
    ROUND(AVG(distance),1) As avg_distance
FROM runner_orders_temp
JOIN customer_orders_temp
    ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE distance IS NOT NULL
GROUP BY customer_id;
````

The distances for customers range from 10 to 25 kilometers. The distance is huge for delivering food, and I don't think that the pizza is still hot after delivery. I think that Danny should consider the advertisement in the closer neighborhood.

<img width="190" alt="CS2 - B4" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/e4a0199b-ff91-4f9a-ba3f-ca60114d979b">


### 5. What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT 
    MAX(duration) - MIN(duration) AS max_diff_time_delivery
FROM runner_orders_temp;
````

The differences amount to 30 minutes. The shortest delivery took 10 minutes, and the longest took 40 minutes.

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT 
    runner_id,
    order_id,
    distance,
    duration,
    ROUND(distance/(duration/60),0) AS avg_speed
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL;
````

It looks like the runner 2 is using a faster vehicle than the rest of the runners. We can assume that the average speed of delivery will be around 40 kilometers per hour.

<img width="354" alt="CS2 - B6" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/319d0e66-03ad-4656-8b1f-6de19a7e29b7">


### 7. What is the successful delivery percentage for each runner?

````sql
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
````

The first runner (runner_id = 1) is the most successful in delivering food.

<img width="487" alt="CS2 - B7" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/96dd169a-9d0f-4209-b692-76ebe4cfdbb2">

***

## C. Ingredient Optimisation

This section contains questions and answers about the ingredient in pizzas and changes in orders. 
Complete syntax is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20syntax)

### 1. What are the standard ingredients for each pizza?

In the data, information about the ingredients is in table ``pizza_recipes``, which contains information about toppings in a list separated by commas. This kind of table is not exactly perfect for the data in the database because one file contains multiple values.

Origin table with the ingredients
...

To solve this problem, I need to split the data about toppings from table ``pizza_recipes``, and write down the names of ingredients using the data from table ``pizza_toppings``. And at the end, concatenate this information into one string. 

Check how many ingredients are in every kind of pizza
```sql
SELECT
    *,
    (LENGTH(toppings) - LENGTH(REPLACE(toppings,",","")) + 1) AS number_of_ingredients    
FROM pizza_recipes;
```

Create an additional table with numbers, where ``n`` is the maximum number of toppings (in this case is 8).
```sql
CREATE TABLE numbers (
  n int
);

INSERT INTO numbers
    (n)
VALUES
    (1),(2),(3),(4),(5),(6),(7),(8);
```

Temporary tables with pizza ingredients, each one in a separate row.
```sql
CREATE TEMPORARY TABLE pizza_recipes_temp AS(
    SELECT
        pizza_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pizza_recipes.toppings, ',', numbers.n), ',', -1)) AS topping_id
    FROM numbers
    JOIN pizza_recipes
    ON LENGTH(pizza_recipes.toppings) - LENGTH(REPLACE(pizza_recipes.toppings,',','')) +1 >= numbers.n
);
```
...

```sql
SELECT
    pn.pizza_name,
    REPLACE(GROUP_CONCAT(pt.topping_name),',',', ') AS all_ingredients
FROM pizza_recipes_temp AS pr
JOIN pizza_toppings AS pt
    ON pr.topping_id = pt.topping_id
JOIN pizza_names AS pn
    ON pr.pizza_id = pn.pizza_id
GROUP BY pn.pizza_name;
```



P.S. In PSQL should be a function **UNNEST** which separates data about toppings into rows and doesn't need the auxiliary table with numbers.



### 2. What was the most commonly added extra?


### 3. What was the most common exclusion?


### 4. Generate an order item for each record in the ``customers_orders`` table in the format of one of the following:
* ``Meat Lovers``
* ``Meat Lovers - Exclude Beef``
* ``Meat Lovers - Extra Bacon``
* ``Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers``

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the ``customer_orders`` table and add a ``2x`` in front of any relevant ingredients
* For example: ``"Meat Lovers: 2xBacon, Beef, ... , Salami"``

### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

***

## D. Pricing and Ratings

### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
### 2. What if there was an additional $1 charge for any pizza extras?
* Add cheese is $1 extra
### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
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

### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

*** 
## E. Bonus Questions

### If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an ``INSERT`` statement to demonstrate what would happen if a new ``Supreme`` pizza with all the toppings was added to the Pizza Runner menu?