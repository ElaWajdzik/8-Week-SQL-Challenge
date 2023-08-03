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

##### Step:
- 

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

##### Step:
- 
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

##### Step:
- 

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

##### Step:
- 

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
- I used the functi

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
- 

czy % ze wszystkich 
czy % z tych co zobaczyły koszyk

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

##### Step:
- 

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
- 

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
- 

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/3ff6286f-c3e2-4548-a2eb-6cc4a5e0c03b" width="500">
