I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #4: 💲 Data Bank
<img src="https://8weeksqlchallenge.com/images/case-study-designs/4.png" alt="Image Data Bank - That's money" height="400">

## Introduction
There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches.

Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!

## Available Data
The Data Bank team have prepared a data model for this case study as well as a few example rows from the complete dataset below to get you familiar with their tables.

## Relationship Diagram

<img width="600" alt="graf1" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/d2a49141-8636-4c35-a3f8-fdb765201af9">

## Question and Solution

I was using MySQL to solve the problem, if you are interested, the complete SQL code is available [here]().

**In advance, thank you for reading.** If you have any comments on my work, please let me know. My emali address is ela.wajdzik@gmail.com.

## A. Customer Nodes Exploration
***

### 1. How many unique nodes are there on the Data Bank system?

```sql
SELECT 
    COUNT(DISTINCT node_id) AS number_of_nodes
FROM customer_nodes;
```
#### Steps:
- I counted the unique nodes using **COUNT DISTINCT**.

#### Result:
| number_of_nodes |
| --------------- |
| 5               |  

***

### 2. What is the number of nodes per region?

```sql
SELECT
    region_name,
    COUNT(DISTINCT node_id) AS number_of_nodes
FROM customer_nodes
JOIN regions
    ON regions.region_id = customer_nodes.region_id
GROUP BY region_name;
```

#### Steps:
- I counted the number of unique nodes (using **COUNT DISTINCT**) in every region (using clause **GROUP BY**).

#### Result:
- Every region has five different nodes.

/jpeg/

***

### 3. How many customers are allocated to each region?

```sql
SELECT
    region_name,
    COUNT(DISTINCT customer_id) AS number_of_customers
FROM customer_nodes
JOIN regions
    ON regions.region_id = customer_nodes.region_id
GROUP BY region_name;
```

#### Steps:
- I counted the number of customers (using **COUNT DISTINCT**) in every region (using clause **GROUP BY**).

#### Result:
- Every region has around 100 customers. The most customers were in Australia (110 customers), and the least in Europe (88 customers).

/jpeg/

***

### 4. How many days on average are customers reallocated to a different node?

```sql
SELECT 
    ROUND(AVG(DATEDIFF(end_date,start_date)),1) AS avg_number_of_days
FROM customer_nodes
WHERE YEAR(end_date) < 9999;
```

#### Steps:
- I checked the max and min ``start_date`` and ``end_date``. 14% of records had ``end_data`` equal ``9999-12-31. I assumed that if a customer in a node has  ``end_date`` equal ``9999-12-31`` it means that it is a current node for this customer. That's why I used the clause **WHERE YEAR(end_date) < 9999** to limit the data.
- I used the clause **DATEDIFF** to calculate the number of days between start and end.
- I used the clause **AVG** to count the average number of days.

#### Result:
- On average, customers were rellocated to a different node in 14.6 days.


| avg_number_of_days |
| ------------------ |
| 14.6               |  


***

### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

```sql
WITH customer_nodes_with_percentile AS (
    SELECT 
        *,
        DATEDIFF(end_date,start_date) AS number_of_days,
        ROUND(
            PERCENT_RANK() OVER (
                PARTITION BY region_id
                ORDER BY DATEDIFF(end_date,start_date)
            ) 
        ,2) AS percentile_rank
    FROM customer_nodes
    WHERE YEAR(end_date) < 9999),

80th_percentile AS (
SELECT 
    region_id,
    MIN(number_of_days) AS 80th_perc
FROM customer_nodes_with_percentile
WHERE percentile_rank >= 0.8
GROUP BY region_id),

95th_percentile AS (
SELECT 
    region_id,
    MIN(number_of_days) AS 95th_perc
FROM customer_nodes_with_percentile
WHERE percentile_rank >= 0.95
GROUP BY region_id),

50th_percentile AS (
SELECT 
    region_id,
    MIN(number_of_days) AS 50th_perc
FROM customer_nodes_with_percentile
WHERE percentile_rank >= 0.5
GROUP BY region_id)

SELECT 
    region_name,
    50th_perc,
    80th_perc,
    95th_perc
FROM regions
JOIN 50th_percentile AS 50th
    ON 50th.region_id = regions.region_id
JOIN 80th_percentile AS 80th
    ON 80th.region_id = regions.region_id
JOIN 95th_percentile AS 95th
    ON 95th.region_id = regions.region_id;
```

#### Steps:
- I created a temporary table ``customer_nodes_with_percentile`` where I calculated the number of days between ``start_date`` and ``end_date`` and added ``percentile_rank`` using the clause **PERCENT_RANK**.
- I created three tables for the 50th, 80th, and 95th percentiles to calculate the value of this percentile.
- I joined the calculated result into one table.


#### Result:
- The 50th, 80th, and 95th percentiles for every region are almost the same.

/jpeg/

***