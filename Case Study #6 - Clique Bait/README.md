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

...


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

...


#### 4. What is the number of events for each event type?
#### 5. What is the percentage of visits which have a purchase event?
#### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
#### 7. What are the top 3 pages by number of views?
#### 8. What is the number of views and cart adds for each product category?
#### 9. What are the top 3 products by purchases?



```sql

```

##### Step:
- I used the functi

##### Result:
All 17 .