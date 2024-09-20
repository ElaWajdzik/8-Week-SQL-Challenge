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
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/997d4dd5b006d9b8b1f945e9f64e9e4e0f1baa91/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code).


***

### Cleaning data 
Sytax SQL is in the file "0. pizza_runner cleaning".

First of all, I cleaned and fixed the data in tables ```customer_orders``` and ```runner_orders```. 

In the table ```customer_orders``` was a problem only with the values **null** and **NULL**. Using the clause **CASE** I replace these two problematic values. I do this operation for the columns ```exclusions``` and ```extras```.


Part of the code with the clause **CASE**:

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


Part of the code with clauses **CASE** and **TRIM**:

````sql
CASE 
    WHEN duration like 'null' THEN NULL
    WHEN duration like '%minute' THEN TRIM('minute' FROM duration)
    WHEN duration like '%minutes' THEN TRIM('minutes' FROM duration)
    WHEN duration like '%mins' THEN TRIM('mins' FROM duration)
    ELSE duration
END AS duration,
````

Part of the code with the clause **MODIFY COLUMN**:

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

This section contains basic questions and answers about orders.\
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/997d4dd5b006d9b8b1f945e9f64e9e4e0f1baa91/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code)

***

### 1. How many pizzas were ordered?

````sql
SELECT 
    COUNT(pizza_id) AS number_of_pizzas
FROM customer_orders_temp;
````

#### Step:
- I used **COUNT** to count the number of rows in table ```customer_orders_temp```, because one row is one ordered pizza.

#### Result:
| number_of_pizzas | 
| ---------------- | 
| 14               | 

- The customers ordered 14 pizzas, this is the number of rows in table ```customer_orders_temp```.

***

### 2. How many unique customer orders were made?

````sql
SELECT 
    COUNT(DISTINCT order_id) AS number_of_orders
FROM customer_orders_temp;
````

#### Step:
- I used **COUNT DISTINCT** to count the number of unique orders in the table ```customer_orders_temp```.

#### Result:
| number_of_orders | 
| ---------------- | 
| 10               | 

- The customers made 10 orders, this is the number of unique ```order_id``` in table ```customer_orders_temp```.

***

### 3. How many successful orders were delivered by each runner?

````sql
SELECT
    runner_id,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;
````

#### Step:
- I used **COUNT DISTINCT** to count the number of orders, and I used the clause **WHERE pickup_time IS NOT NULL** to limit the data to only delivered orders.
- I grouped (using **GROUP BY**) the data by every runner.

#### Result:

<img width="300" alt="CS2 - A3" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/291518dd-20f9-4abe-8396-06ae25afbeb6">

- Deliveries were made by three runners, and runner 1 delivered 4 orders, runner 2 delivered 3 orders, runner 4 delivered 1 order.

***

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


#### Step:
- I joined three tables. ```customer_orders_temp``` - data about ``pizza_id`` in orders, ```runner_orders_temp``` - data about successful delivery and ```pizza_names``` - data about the names of pizzas.
- I selected the data about delivered orders using **WHERE pickup_time IS NOT NULL**.
- I counted the number of occurring each ```pizza_id``` and grouped data by ``pizza_name``.

#### Result:

<img width="300" alt="CS2 - A4" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/d61803c7-53cf-400f-a5f1-25e9f656dbc4">

- Pizza Meatlovers (9 orders) is more likely to be ordered than Pizza Vegetarian (3 orders).

***

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

#### Step:
- I joined tables ```customer_orders_temp``` and ```pizza_names``` to find the names of products.
- I counted the number of orders for every type of pizza clause **COUNT** and grouped them by ``customer_id`` and ``pizza_name``.
- In the query, I used only the data about successfully delivered.

#### Result:

<img width="300" alt="CS2 - A5" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/291a21f3-6365-4d34-8e49-8a237b6f1ecb">

***

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


#### Step:
- I counted the number of pizzas in the orders.
- I joined tables ``customer_orders_temp`` with ``runner_orders_temp`` to select only the successfully delivered orders.
- I used clause **ORDER BY** (to order orders using the number of pizzas in order) with parameters **DESC** (in descending order) and **LIMIT** (to show only the first row after ordering).

#### Result:

<img width="300" alt="CS2 - A6" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/e062f5c6-ca25-4ced-9d6e-1ae6d15361f3">

- In order 4 (```order_id``` = 4) customer ordered 3 pizzas, this was the biggest order that would be successfully delivered.

***


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

#### Step:
- I concatenated data from columns ```extras``` and ```exclusions``` to detect if pizza had any changes.
- I calculated the number of pizzas with and without changes for every customer. I used clause **CONCAT** to merge the data about changes, **TRIM** to delete unnecessary signs. If this string is equal '' it means that pizza doesn't have any changes, otherwise, it has some changes.
- I joined tables ``customer_orders_temp`` with ``runner_orders_temp`` to select only the successfully delivered orders.

#### Result:

<img width="500" alt="CS2 - A7" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/a1a7eb43-2dc9-42bc-8c5a-e3c6b6e90f61">

- Customers **101** and **102** ordered only pizzas without change. Customers **103** and **105** ordered only pizzas with changes.

***

### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
SELECT
    SUM(IF(TRIM(extras)!='' AND TRIM(exclusions)!='',1,0)) AS pizza_with_extras_and_exclusions
FROM customer_orders_temp
JOIN runner_orders_temp
    ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.pickup_time IS NOT NULL;
````



#### Step:
- I counted the number of pizzas with exclusions and extras. I checked if the ``extras`` and ``exclusions`` contained something for the same pizza order (**SUM(IF(TRIM(extras)!='' AND TRIM(exclusions)!='',1,0))**).
- I joined tables ``customer_orders_temp`` with ``runner_orders_temp`` to select only the successfully delivered orders.

#### Result:
| pizza_with_extras_and_exclusions | 
| -------------------------------- | 
| 1                                | 

- Only 1 of delivered pizza has ```extras``` and ```exclusions```.

***


### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT
    HOUR(order_time) AS order_hour,
    COUNT(pizza_id) AS number_of_pizza
FROM customer_orders_temp
GROUP BY order_hour;
````


#### Step:
- I grouped data by houer of ``order_time`` (**HOUR(order_time)**) and I counted the number of pizzas for each houer.

#### Result:

<img width="300" alt="CS2 - A9" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/f88c4207-4066-49cc-a61a-8eaa191d0e1e">

- The most orders are made after 12 and before 00 (but maybe the Pizza Runner is open only in these hours).

***

### 10. What was the volume of orders for each day of the week?

````sql
SELECT
    DAYOFWEEK(order_time) AS order_day_of_week,
    COUNT(pizza_id) AS number_of_pizza
FROM customer_orders_temp
GROUP BY order_day_of_week;
````


#### Step:
- I extracted the day of the week from ``order_time`` (**DAYOFWEEK(order_time)**) and I counted the number of pizzas for every day of the week. I used the clause **DAYOFWEEK()** which returns a number from 1 to 7, starting from Sunday (1=Sunday).

#### Result:

<img width="400" alt="CS2 - A10" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/6a9e6bf3-8b0a-453d-8626-bbc29fd527b9">

- The most orders were made on Wednesday (5 orders) and Saturday (5 orders).

***

***  

## B. Runner and Customer Experience

This section contains questions and answers about the details of delivery and runners.\
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/997d4dd5b006d9b8b1f945e9f64e9e4e0f1baa91/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code)

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

#### Step:
- The standard function usually assumes that the week starts on Monday or Sunday. But 1.01.2021 was Friday, which is why I can't use the function **WEEK()**.
- I created a temporary table with an additional column, which was the date of last Friday (**DATE(registration_date - (registration_date - DATE('2021-01-01')) %7)**).
- I counted the number of people who signed up and grouped the data by the calculated date of last Friday.

#### Result:

<img width="300" alt="CS2 - B1" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/548a0f9a-d024-4362-b068-c2ffcd4c67f0">

***


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
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/997d4dd5b006d9b8b1f945e9f64e9e4e0f1baa91/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code)

### 1. What are the standard ingredients for each pizza?

In the data, information about the ingredients is in table ``pizza_recipes``, which contains information about toppings in a list separated by commas. This kind of table is not exactly perfect for the data in the database because one file contains multiple values.

Origin table with the ingredients

<img width="293" alt="CS2 - C1a" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/19af91a1-5d26-4f32-909f-ee47d10aabab">


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
<img width="151" alt="CS2 - C1b" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/f2975633-9326-4a1a-8349-b0d4c29b608a">


After these steps, I calculated the final result using **GRUP_CONCAT**.
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

<img width="450" alt="CS2 - C1c" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/3b90bb2e-f13f-41da-ba40-a9ad1de96ff5">


Final thought:
* The method of this solution comes from https://www.delftstack.com/howto/mysql/mysql-split-string-into-rows/
* Unfortunately, in MySQL there is no reverse function for **GRUP_CONCAT**.
* In PSQL should be a function **UNNEST** which separates data about toppings into rows and doesn't need the auxiliary table with numbers.


### 2. What was the most commonly added extra?

```sql
WITH pizza_extras_temp AS(
SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(co.extras,',',numbers.n),',',-1)) AS extras_id,
    COUNT(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(co.extras,',',numbers.n),',',-1))) AS number_of_add
FROM customer_orders_temp AS co
JOIN numbers
    ON LENGTH(co.extras) - LENGTH(REPLACE(co.extras,',','')) +1 >= numbers.n
WHERE extras != ''
GROUP BY extras_id
)

SELECT 
    pt.topping_name,
    pe.number_of_add
FROM pizza_extras_temp AS pe
JOIN pizza_toppings AS pt
    ON pe.extras_id = pt.topping_id
ORDER BY pe.number_of_add DESC;
```

Customers Pizza Runner, like adding becon to the pizza, maybe create a new kind of pizza with beckon, which will be a good move for the Bisnes.

<img width="196" alt="CS2 - C2" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/324b0ee6-e602-4eb6-9f24-d416068bdc5b">


### 3. What was the most common exclusion?

```sql
WITH pizza_exclusions_temp AS(
SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(co.exclusions,',',numbers.n),',',-1)) AS exclusions_id,
    COUNT(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(co.exclusions,',',numbers.n),',',-1))) AS number_of_excluse
FROM customer_orders_temp AS co
JOIN numbers
    ON LENGTH(co.exclusions) - LENGTH(REPLACE(co.exclusions,',','')) +1 >= numbers.n
WHERE exclusions != ''
GROUP BY exclusions_id
)

SELECT 
    pt.topping_name,
    pe.number_of_excluse
FROM pizza_exclusions_temp AS pe
JOIN pizza_toppings AS pt
    ON pe.exclusions_id = pt.topping_id
ORDER BY pe.number_of_excluse DESC;
```

The most common excluded ingredient was cheese. It can suggest that customers are vegan, and adding vegan options to the menu will be good.


<img width="228" alt="CS2 - C3" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/d050a9ab-b0d1-471e-adfe-af92d9770737">


### 4. Generate an order item for each record in the ``customers_orders`` table in the format of one of the following:
* ``Meat Lovers``
* ``Meat Lovers - Exclude Beef``
* ``Meat Lovers - Extra Bacon``
* ``Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers``

```sql
WITH table_extras_temp AS(
SELECT
    co.id,
    REPLACE(GROUP_CONCAT(pt.topping_name),',',', ') AS extra_toppings,
    'extra' AS type
FROM customer_orders_temp AS co
JOIN numbers
    ON LENGTH(co.extras) - LENGTH(REPLACE(co.extras,',','')) +1>= numbers.n
JOIN pizza_toppings AS pt
    ON pt.topping_id = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(co.extras,',',numbers.n),',',-1))
WHERE extras != ''
GROUP BY id
),
table_exclusions_temp AS(
SELECT
    co.id,
    REPLACE(GROUP_CONCAT(pt.topping_name),',',', ') AS exclusion_toppings,
    'exclusion' AS type
FROM customer_orders_temp AS co
JOIN numbers
    ON LENGTH(co.exclusions) - LENGTH(REPLACE(co.exclusions,',','')) +1>= numbers.n
JOIN pizza_toppings AS pt
    ON pt.topping_id = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(co.exclusions,',',numbers.n),',',-1))
WHERE exclusions != ''
GROUP BY id
)

SELECT
    co.id,    
    CASE 
        WHEN co.exclusions != '' AND co.extras = '' THEN CONCAT(pn.pizza_name,' - Exclude ',table_exclusions.exclusion_toppings)
        WHEN co.exclusions = '' AND co.extras != '' THEN CONCAT(pn.pizza_name,' - Extra ',table_extras.extra_toppings)
        WHEN co.exclusions != '' AND co.extras != '' THEN CONCAT(pn.pizza_name,' - Exclude ',table_exclusions.exclusion_toppings,' - Extra ',table_extras.extra_toppings)
        ELSE pn.pizza_name
    END AS order_item

FROM customer_orders_temp AS co
JOIN pizza_names AS pn
    ON co.pizza_id = pn.pizza_id
LEFT JOIN  table_extras_temp AS table_extras 
    ON co.id = table_extras.id
LEFT JOIN table_exclusions_temp AS table_exclusions
    ON co.id = table_exclusions.id
GROUP BY co.id;
```

In the solution, I created two temporary tables with the extras and excludions. Then using **CASE** I considered four cases to write down orders in good format.

<img width="434" alt="CS2 - C4" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/ee544546-d5d0-46f9-809a-805c9b2c21b9">


### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the ``customer_orders`` table and add a ``2x`` in front of any relevant ingredients
* For example: ``"Meat Lovers: 2xBacon, Beef, ... , Salami"``

```sql
WITH table_extras_temp AS(
SELECT
    id,
    pizza_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras,',',numbers.n),',',-1)) AS topping_id,
    'extra' AS type,
    1 AS number
FROM customer_orders
JOIN numbers
    ON LENGTH(extras) - LENGTH(REPLACE(extras,',','')) +1>= numbers.n
WHERE extras != ''
),
table_excludions_temp AS(
SELECT
    id,
    pizza_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions,',',numbers.n),',',-1)) AS topping_id,
    'exclusion' AS type,
    -1 AS number
FROM customer_orders
JOIN numbers
    ON LENGTH(exclusions) - LENGTH(REPLACE(exclusions,',','')) +1>= numbers.n
WHERE exclusions != ''
),
table_pizza_toppings_temp AS(
SELECT
    id,
    co.pizza_id,
    topping_id,
    'pizza' AS type,
    1 AS number
FROM customer_orders AS co
JOIN pizza_recipes_temp
    ON co.pizza_id = pizza_recipes_temp.pizza_id
),
table_pizza_ingredions_temp AS(
SELECT 
    id,
    pizza_id,
    topping_name,
    SUM(number) AS number_of_use
FROM 
    (SELECT * FROM table_excludions_temp
    UNION ALL
    SELECT * FROM table_extras_temp
    UNION ALL
    SELECT * FROM table_pizza_toppings_temp
    )AS table_toppings_order
JOIN pizza_toppings
    ON table_toppings_order.topping_id = pizza_toppings.topping_id
GROUP BY id, topping_name
ORDER BY id
)

SELECT 
    pi.id,
    CONCAT(
        pizza_name,': ',
        REPLACE(GROUP_CONCAT(
            CASE 
                WHEN number_of_use > 1 THEN CONCAT(number_of_use,'x',topping_name)
                ELSE topping_name
            END),',',', ')) AS all_ingredions
FROM table_pizza_ingredions_temp AS pi
JOIN pizza_names
    ON pi.pizza_id = pizza_names.pizza_id
WHERE pi.number_of_use >0
GROUP BY pi.id;
```
To solve this problem, I use a table ``pizza_recipes_temp`` which was created in question 1 in section C.

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
