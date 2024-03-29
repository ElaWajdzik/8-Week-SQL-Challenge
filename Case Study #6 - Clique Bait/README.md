I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #6: 🎣 Clique Bait
<img src="https://8weeksqlchallenge.com/images/case-study-designs/6.png" alt="Image Clique Bait - attention capturing" height="400">

## Introduction

Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Available Data

For this case study there is a total of 5 datasets which you will need to combine to solve all of the questions.

- ``Users`` - Customers who visit the Clique Bait website are tagged via their ``cookie_id``.
- ``Events`` - Customer visits are logged in this ``events`` table at a ``cookie_id`` level and the ``event_type`` and ``page_id`` values can be used to join into relevant satellite tables to obtain further information about each event. The ``sequence_number`` is used to order the events within each visit.
- ``Event Identifier`` - The ``event_identifier`` table shows the types of events which are captured by Clique Bait’s digital data systems.
- ``Campaign Identifier`` - This table shows information for the 3 campaigns that Clique Bait has ran on their website so far in 2020.
- ``Page Hierarchy`` - This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.


***
***

## Question and Solution

I was using MySQL to solve the problem, if you are interested, the complete SQL code is available [here]().

**In advance, thank you for reading.** If you have any comments on my work, please let me know. My emali address is ela.wajdzik@gmail.com.

***
### 1. Enterprise Relationship Diagram

Using the following [DDL](https://dbdiagram.io/home) schema details to create an ERD for all the Clique Bait datasets.

Relationship diagram for the Clique Bait dataset that I created in DDL:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/0453a89f-4e70-4f63-aa90-849818475013" width="600">

***

### 2. Digital Analysis

#### 1. How many users are there?

```sql
SELECT 
    COUNT(DISTINCT user_id) AS number_of_users
FROM users;
```

##### Result:

| number_of_users |
|-----------------|
| 500             |


#### 2. How many cookies does each user have on average?

```sql
SELECT
    ROUND(COUNT(user_id)/COUNT(DISTINCT user_id),1) AS avg_number_of_cookis_per_user
FROM users;
```

##### Result:

| avg_number_of_cookis_per_user |
|-------------------------------|
| 3.6                           |


#### 3. What is the unique number of visits by all users per month?


```sql
SELECT 
    MONTH(event_time) AS month,
    COUNT(DISTINCT visit_id) AS unique_number_of_visit
FROM events
GROUP BY MONTH(event_time);
```

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/e996a9da-3354-4b32-a5bf-8587c039efe1" width="300">


#### 4. What is the number of events for each event type?

```sql
SELECT
    e.event_type,
    ei.event_name,
    COUNT(e.event_type) AS number_of_events
FROM events AS e, event_identifier AS ei
WHERE e.event_type = ei.event_type
GROUP BY event_type;
```

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/4322a19c-c6e3-457e-9945-63afa7467f4a" width="400">


#### 5. What is the percentage of visits which have a purchase event?

```sql
SELECT 
    ROUND((COUNT(DISTINCT e.visit_id)/n_visit.number_of_visit)*100,1) AS proc_of_visits_with_purchase
FROM events AS e, 
    (SELECT 
        COUNT(DISTINCT visit_id) AS number_of_visit
    FROM events) AS n_visit
WHERE event_type = 3;
```

##### Step:
- I created a subquery where I calculated the number of all visits.
- I counted the percent of visits with purchases using a query with the clause **WHERE event_type  = 3**.

##### Result:

| proc_of_visits_with_purchase |
|------------------------------|
| 49.9                         |


#### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?


```sql
WITH visit_checkout_purchase AS (
SELECT
    visit_id,
    MAX(CASE 
        WHEN event_type = 3 THEN 1  
        ELSE 0 
    END) AS visit_with_purchase,
    MAX(CASE 
        WHEN page_id = 12 THEN 1 
        ELSE 0
    END) AS visit_with_checkout_page
FROM events
GROUP BY visit_id
)

SELECT
    SUM(visit_with_checkout_page)-SUM(visit_with_purchase) AS number_of_visit_with_checkout_without_purchase,
    ROUND(((SUM(visit_with_checkout_page)-SUM(visit_with_purchase))/COUNT(*))*100,1) AS proc_of_visit_with_checkout_without_purchase
FROM visit_checkout_purchase AS vcp;
```

##### Step:
- I created a temporary table with the three data ``visit_id``, ``visit_with_purchase`` which was 1 or 0 (1 if in this visit was a purchase and 0 if not), and ``visit_with_checkout_page`` which was 1 or 0 (1 if in this visit had visited the checkout page and 0 if not).
- I calculated the number of visits that include visits on the checkout page but do not include purchases, like a differential between the sum of ``visit_with_purchase``.  NOTE: Every purchase requires a visit to the checkout page.
- In my opinion the main question has two interpretations. For me, the **1** interpretation makes more sense, which is why I calculated the answer to this question.
    1. What is the percentage of visits which view the checkout page but do not have a purchase event? **And 100% is all visits in service Clique Bait**
    2. What is the percentage of visits which view the checkout page but do not have a purchase event? **And 100% is only visits in service Clique Bait which include visits on the checkout page**

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/46b3308d-7231-4571-9e7f-764c010ce8fd" width="300">


#### 7. What are the top 3 pages by number of views?

```sql
SELECT 
    e.page_id,
    ph.page_name,
    COUNT(e.page_id) AS number_of_viewes
FROM events AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id
GROUP BY e.page_id
ORDER BY COUNT(e.page_id) DESC
LIMIT 3;
``` 

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/8abc506b-822d-47fe-b8b4-1c0868ed9f7f" width="400">

#### 8. What is the number of views and cart adds for each product category?

```sql
SELECT 
    ph.product_category,
    COUNT(e.page_id) AS number_of_viewes,
    SUM(CASE 
        WHEN e.event_type = 2 THEN 1
        ELSE 0
    END) AS number_of_cart_adds
FROM events AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id AND ph.product_category IS NOT NULL
GROUP BY ph.product_category
ORDER BY COUNT(e.page_id) DESC;
```

##### Step:
- I counted every visit for each ``page_id``. And selected only the pages that have ``product_category``.
- I calculated the number of adds to the cart using clause **CASE** to count every event **Add to Cart** (``event_type`` = 2).
- And ordered the results in descending order.

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/4e5fb1c0-1515-44da-9205-74251601f493" width="500">


#### 9. What are the top 3 products by purchases?

```sql
WITH events_with_purchase AS (
    SELECT 
        *
    FROM events
    WHERE visit_id IN (
        SELECT
            visit_id
        FROM events
        WHERE event_type = 3)
)

SELECT 
    ph.page_name AS product_name,
    ph.product_category,
    SUM(CASE 
        WHEN e.event_type = 2 THEN 1
        ELSE 0
    END) AS number_of_buy
FROM events_with_purchase AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id AND ph.product_category IS NOT NULL
GROUP BY ph.page_name
ORDER BY number_of_buy DESC
LIMIT 3;
```

##### Step:
- I created a temporary table where every visit includes the purchase. A query with a subquery included only ``visit_id`` with the purchase.
- I counted the number of events **Add to Cart** ()``event_type`` = 2) for every page.

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/3ff6286f-c3e2-4548-a2eb-6cc4a5e0c03b" width="500">

***

### 3. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:
- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

#### New table ``product_number``

First I created a concept of how the new table will look and how I want to calculate the data.

The new table ``product_number`` will include columns

1. ``product_name`` - it is ``page_name`` from the table ``page_hierarchy``,
2. ``product_view`` - it is the number of views on specific pages (``event_type`` = 1),
3. ``product_add_to_cart`` - it is the number of items added to the cart on specific pages (``event_type`` = 2),
4. ``product_abandoned`` - it is the difference between ``product_add_to_cart`` and ``product_purchase``,
5. ``product_purchase`` - it is the number of items added to the cart on specific pages in the visit including purchase


NOTE If some visits include a purchase, it means that visits end (the max sequence_numnber) on a purchase (page_id = 13 and event_type = 3).


```sql
CREATE TABLE product_number (
WITH product_1 AS (
SELECT 
    e.page_id,
    ph.page_name AS product_name,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS product_view,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS product_add_to_cart
FROM events AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id
GROUP BY e.page_id
),
product_2 AS (
SELECT
    page_id,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS product_purchase
FROM (
    SELECT 
        *
    FROM events
    WHERE visit_id IN (
        SELECT
            visit_id
        FROM events
        WHERE event_type = 3)) AS events_with_purchase
GROUP BY page_id
)

SELECT 
    p1.product_name,
    p1.product_view,
    p1.product_add_to_cart,
    p1.product_add_to_cart - p2.product_purchase AS product_abandoned,
    p2.product_purchase
FROM product_1 AS p1, product_2 As p2
WHERE p1.page_id = p2.page_id AND p1.page_id NOT IN ('1','2','12','13')
);
```
<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/55a0cdac-7c8a-4921-9d77-ce8176ff9f4a" width="600">

#### New table ``category_number``

To prepare the table ``category_number`` I used the tampate like in the table ``product_number``. And the biggest change was to use ``product_category`` instead of ``page_name` to name the categories.


```sql
CREATE TABLE category_number (
WITH category_1 AS (
SELECT 
    ph.product_category AS category_name,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS category_view,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS category_add_to_cart
FROM events AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id
GROUP BY ph.product_category
),
category_2 AS (
SELECT
    ph.product_category AS category_name,
    SUM(CASE WHEN ep.event_type = 2 THEN 1 ELSE 0 END) AS category_purchase
FROM (
    SELECT 
        *
    FROM events
    WHERE visit_id IN (
        SELECT
            visit_id
        FROM events
        WHERE event_type = 3)) AS ep, page_hierarchy AS ph
WHERE ep.page_id = ph.page_id
GROUP BY ph.product_category
)

SELECT 
    c1.category_name,
    c1.category_view,
    c1.category_add_to_cart,
    c1.category_add_to_cart - c2.category_purchase AS category_abandoned,
    c2.category_purchase
FROM category_1 AS c1, category_2 As c2
WHERE c1.category_name = c2.category_name AND c1.category_name IS NOT NULL);
```

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/07fe875b-2c80-4956-8af3-297eee498934" width="600">

#### Questions 

##### 1. Which product had the most views, cart adds and purchases?

Oyster had the most views (1568).
Lobster had the highest number of items added to the cart (968) and purchases (754).

##### 2. Which product was most likely to be abandoned?

Russian caviar had the biggest number of abandoned.

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/fc29abf4-f430-49eb-9853-764ffacc738d" width="600">

##### 3. Which product had the highest view to purchase percentage?

```sql
SELECT 
    product_name,
    ROUND((product_purchase/product_view)*100,1) AS purchase_conversion
FROM product_number
ORDER BY purchase_conversion DESC;
```

Lobster has the highest conversion rate (48.7%). In the data conversion rate all products were similar, the smallest was 44.6% and the biggest was 48.7%.

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/d6ac9921-2c63-4330-a4bf-b16d97803f0b" width="350">

##### 4. What is the average conversion rate from view to cart add?

```sql
SELECT 
    product_name,
    ROUND((product_add_to_cart/product_view)*100,1) AS add_to_cart_conversion
FROM product_number
ORDER BY add_to_cart_conversion DESC;

SELECT 
    ROUND((SUM(product_add_to_cart)/SUM(product_view))*100,1) AS add_to_cart_conversion
FROM product_number;
```

The average conversion rate from view to cart add was 60.9%, which means that 3 of 5 views end with adding to the cart.
Looking at the data about products, we can see that the CR for every product was close (the smallest CR was 59.0% and the biggest CR was 62.9%).

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/ec3ac951-4df9-41ec-ad1c-e7a15cdd0311" width="250"> 
<br>
<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/7295464e-148b-4b0c-a657-aba42e2d4f69" width="350">

##### 5. What is the average conversion rate from cart add to purchase?

```sql
SELECT 
    product_name,
    ROUND((product_purchase/product_add_to_cart)*100,1) AS cart_to_purchase_conversion
FROM product_number
ORDER BY cart_to_purchase_conversion DESC;

SELECT 
    ROUND((SUM(product_purchase)/SUM(product_add_to_cart))*100,1) AS cart_to_purchase_conversion
FROM product_number;
```

The average conversion rate from cart add to purchase was 75.9%, which means that 3 of 4 adds to the cart ended with a purchase. 75% is not a small number, but I think it needs to be checked why 1 of 4 clients abandoned the cart.
The data about products also show small differences (the biggest CR was 77.9% and the smallest was 73.7%).


<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/6c96e05a-ba2c-4b3e-b61b-8d1a19b616c4" width="250">
<br>
<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/d25e224a-4829-4c4a-8222-1386548b4d5b" width="350">

***

**Thanks for reading.** Please let me know what you think about my work. My emali address is ela.wajdzik@gmail.com

I am open to new work opportunities, so if you are looking for someone (or know that someone is looking for) with my skills, I will be glad for information. 


**Have a nice day!**
