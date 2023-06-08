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

....

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

...


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

....

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

...

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

...

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


### 10. What was the volume of orders for each day of the week?

````sql
SELECT
    DAYOFWEEK(order_time) AS order_day_of_week,
    COUNT(pizza_id) AS number_of_pizza
FROM customer_orders_temp
GROUP BY order_day_of_week;
````

I use clause **DAYOFWEEK()** which returns a number from 1 to 7, starting from Sunday (1=Sunday). The most orders were made on Wednesday (5 orders) and Saturday (5 orders).



***  
B. Runner and Customer Experience
 
C. Ingredient Optimisation

D. Pricing and Ratings
