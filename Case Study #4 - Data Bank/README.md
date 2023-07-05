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

I was using MySQL to solve the problem, if you are interested, the complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/8e02234c7889c6df67b043b60a833934f4257bd5/Case%20Study%20%234%20-%20Data%20Bank/SQL%20code).

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


<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/c70d6bb7-90d8-4794-9df8-43ba6a4f0bb4" width="300">


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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/1747b947-4738-4eea-a773-74eed18a40b2" width="300">

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


<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/b17528f7-fae0-4b08-ac51-31e5a4bbc077" width="400">

***

***

## B. Customer Nodes Exploration
***

### 1. What is the unique count and total amount for each transaction type?

```sql
SELECT 
    txn_type,
    COUNT(txn_amount) AS number_of_transactions,
    SUM(txn_amount) AS sum_of_amount
FROM customer_transactions
GROUP BY txn_type;
```
#### Steps:
- I counted the numbers and the values of ``txn_amount`` grouped by ``txn_type``. 

#### Result:

...

***

### 2. What is the average total historical deposit counts and amounts for all customers?

```sql
SELECT
    ROUND(COUNT(txn_amount)/COUNT(DISTINCT customer_id),1) AS avg_number_of_deposite,
    ROUND(AVG(txn_amount),0) AS avg_amount_of_deposite
FROM customer_transactions
WHERE txn_type = 'deposit';
```
#### Steps:
- I used the filter (**WHERE txn_type = 'deposit'** ) to include only the data about ``deposite`` in the calculation.
- I counted the average count of depisite using clauses **COUNT** (to calculate the number of all depisite) and **COUNT DISTINCT** (to calculate the number of all customers).
- I calculated the average deposit amount using clause **AVG**.


#### Result:

| avg_number_of_deposite | avg_amount_of_deposite |
| ---------------------- | ---------------------- |
| 5.3                    | 509                    | 

***


### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
 

```sql
WITH pivot_transactions AS (
    SELECT
        customer_id,
        MONTH(txn_date) AS date_month,
        SUM(
            CASE 
                WHEN txn_type = 'deposit' THEN 1 
                ELSE 0
            END) AS number_of_deposits,
        SUM(
            CASE 
                WHEN txn_type = 'purchase' THEN 1 
                ELSE 0
            END) AS number_of_purchases,   
        SUM(
            CASE 
                WHEN txn_type = 'withdrawal' THEN 1 
                ELSE 0
            END) AS number_of_withdrawals
    FROM customer_transactions
    GROUP BY customer_id, date_month
)


SELECT
    date_month,
    COUNT(customer_id) AS number_of_customers
FROM  pivot_transactions
WHERE 
    number_of_deposits > 1 AND 
    (number_of_purchases >= 1 OR number_of_withdrawals >= 1)
GROUP BY date_month;
```
#### Steps:
- I created a temporary table ``pivot_transactions`` where I calculated for each customer and month the number of deposits, purchases, and withdrawals. I calculated the number of each type of transaction ``txn_type`` using the clauses **SUM** and **CASE**.
Next, using the temporary table ``pivot_transactions`` I calculated the number of customers who made more than 1 deposit and either 1 purchase or 1 withdrawal (using clause **WHERE** with a few conditions) in each month.

#### Result:
...

***


### 4. What is the closing balance for each customer at the end of the month? 

```sql

DROP TABLE IF EXISTS t4;

CREATE TABLE t4 (
    month_date int,
    txn_type varchar(10),
    txn_amount int
);

INSERT INTO t4
  (month_date, txn_type, txn_amount)
VALUES
  ('1', 'balance', '0'),
  ('2', 'balance', '0'),
  ('3', 'balance', '0'),
  ('4',  'balance', '0');


WITH customer_transaction_with_balance AS (
    SELECT DISTINCT 
        ct.customer_id, 
        t4.month_date, 
        t4.txn_type, 
        t4.txn_amount
    FROM customer_transactions AS ct, t4
    UNION
    SELECT 
        customer_id, 
        MONTH(txn_date) AS month_date, 
        txn_type, 
        txn_amount
    FROM customer_transactions
),
month_aggregation_data AS (
    SELECT
        customer_id,
        month_date,
        SUM(
            CASE 
                WHEN txn_type='deposit' THEN txn_amount 
                ELSE txn_amount * -1
            END) AS month_change
    FROM customer_transaction_with_balance
    GROUP BY customer_id, month_date
)

SELECT 
    *,
    SUM(month_change) OVER (PARTITION BY customer_id ORDER BY month_date) AS end_month_balance
FROM month_aggregation_data
WHERE customer_id IN (1,2,3,4,5); -- this filetr is only to limit the result
```

#### Steps:
- I created the extra table ``t4`` with four rows (include ``month_date`` a number from 1 to 4, ``txn_type`` it's eqal ``balance``, ``txn_amount`` it's eqal ``0``) which I added to the calculated data to have for every customer at least one record in each month.
- I created a temporary table ``customer_transaction_with_balance`` where I **UNION** the original data from tables ``customer_transactions`` and ``t4``.
- I aggregated the monthly amount of transactions for each customer in table ``month_aggregation_data``.
- In the final result, add a column with the ``end_month_balance``. I calculated the balance using the function **SUM() OVER (PARTITION BY customer_id ORDER BY month_date)**.
- In the result, I showed data only for 5 to simplify. 

#### Result:

...

***

### 2. 

```sql
SELECT 


GROUP BY txn_type;
```
#### Steps:
- I counted 

#### Result:

| number_of_nodes |
| --------------- |
| 5               |  

***