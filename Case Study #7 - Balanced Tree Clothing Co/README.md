I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #6: 👕 Balanced Tree Clothing Co.
<img src="https://8weeksqlchallenge.com/images/case-study-designs/7.png" alt="Balanced Tree Clothing Compant" height="400">

## Introduction

Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

## Available Data

For this case study there is a total of 4 datasets for this case study - however you will only need to utilise 2 main tables to solve all of the regular questions, and the additional 2 tables are used only for the bonus challenge question!

- ``product_details`` includes all information about the entire range that Balanced Clothing sells in their store
- ``sales`` contains product level information for all the transactions made for Balanced Tree including quantity, price, percentage discount, member status, a transaction ID and also the transaction timestamp
- ``product_hierarchy``
- ``product_prices``


***
***

## Question and Solution

I was using MySQL to solve the problem, if you are interested, the complete SQL code is available [here]().

**In advance, thank you for reading.** If you have any comments on my work, please let me know. My emali address is ela.wajdzik@gmail.com.

***
###  A. High Level Sales Analysis

#### 1. What was the total quantity sold for all products?

```sql
SELECT
    SUM(qty) AS total_quantity
FROM sales;
```

##### Result:

... cs7_a_1

There were 45216 products sold.

#### 2. What is the total generated revenue for all products before discounts?

```sql
SELECT
    SUM(qty*price) AS revenue
FROM sales;
```

##### Result:

...cs7_a_2

The total revenue was $1 289 453 

#### 3. What was the total discount amount for all products?

```sql
SELECT
    ROUND(SUM(qty*price*discount/100),2) AS total_discount
FROM sales;
```

To calculate the total discount, I used information about quantity (``qty``), price (``price``) and percentage discount (``discount``). I multiplied all three metrics and divided by 100 because ``discount`` in the table is an integer, not a percent.

##### Result:

...cs7_a_3

The total discount amount was $156 229.14

***
###  B. Transaction Analysis

#### 1. How many unique transactions were there?

```sql
SELECT
    COUNT(DISTINCT txn_id) AS number_of_transactions
FROM sales;
```

##### Result:

...cs7_b_1

There were 2500 unique transactions.

#### 2. What is the average unique products purchased in each transaction?

```sql
SELECT
    ROUND(AVG(number_of_different_products),0) AS average_unique_products
FROM (
    SELECT
        txn_id,
        COUNT(DISTINCT prod_id) AS number_of_different_products
    FROM sales
    GROUP BY txn_id) AS txn_sales;
```
##### Result:

...cs7_b_2

The average number of unique products in each transaction was equal to 6.


#### 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

```sql
WITH txn_sales AS (
SELECT
    txn_id,
    SUM(qty*price) AS revenue
FROM sales
GROUP BY txn_id
),
percentiles AS (
    SELECT
        revenue,
        PERCENT_RANK() OVER (ORDER BY revenue) AS percent_rank
    FROM txn_sales
),
25th_percentile AS (
SELECT
    MIN(revenue) AS 25th_perc
FROM percentiles
WHERE percent_rank >= 0.25
),
50th_percentile AS (
SELECT
    MIN(revenue) AS 50th_perc
FROM percentiles
WHERE percent_rank >= 0.5
),
75th_percentile AS (
SELECT
    MIN(revenue) AS 75th_perc
FROM percentiles
WHERE percent_rank >= 0.75
)
SELECT 
    *
FROM 25th_percentile, 50th_percentile, 75th_percentile;
```

To calculate the percentile I need to use the function **PERCENT_RANK()** and after that I choose the value of revenue according to the 25th, 50th and 75th percentiles.

##### Result:

...cs7_b_3


#### 4. What is the average discount value per transaction?

```sql
SELECT
    ROUND(AVG(discount),2) AS avg_discount
FROM (
    SELECT
        txn_id,
        SUM(qty*price*discount/100) AS discount
    FROM sales
    GROUP BY txn_id) AS txn_sales;
```

##### Result:

...cs7_b_4

The average discount for each transaction was $62.49.


#### 5. What is the percentage split of all transactions for members vs non-members?

```sql
WITH txn_sales AS (
    SELECT
        member,
        COUNT(DISTINCT txn_id) AS number_of_transactions
    FROM sales
    GROUP BY member
)
SELECT 
    CASE 
        WHEN member = 1 THEN 'members'
        ELSE 'non-members'
    END AS member,
    number_of_transactions,
    ROUND(number_of_transactions/(SUM(SUM(number_of_transactions)) OVER ())*100,1) AS proc_of_transactions
FROM txn_sales
GROUP BY member;
```

##### Steps:
- First, I created the temporary table ``txn_sales`` which contains the number of unique transactions for members and non-members.
- In the result I changed the value in column ``memeber`` from **1** and **0** to **members** and **non-members**. I calculated the percentage of all transactions for each group of clients.

##### Result:

... cs7_b_5

#### 6. What is the average revenue for member transactions and non-member transactions?

```sql
WITH txn_revenue AS (
    SELECT
        txn_id,
        member,
        SUM(qty*price) AS revenue
    FROM sales
    GROUP BY txn_id, member
)
SELECT 
    CASE 
        WHEN member = 1 THEN 'members'
        ELSE 'non-members'
    END AS member,
    ROUND(AVG(revenue),2) AS avg_revenue
FROM txn_revenue
GROUP BY member;
```

##### Result:

...cs7_b_6

The average revenue for transactions for members was $516.27 and for non-members was $515.04. The difference between those two values was only $1.23.

***
###  C. Product Analysis

#### 1. What are the top 3 products by total revenue before discount?


```sql
SELECT
    pd.product_name,
    SUM(s.qty*s.price) AS revenue,
    ROUND(SUM(s.qty*s.price)/(SUM(SUM(s.qty*s.price)) OVER ())*100,1) AS proc_of_revenue
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY revenue DESC LIMIT 3;
```

##### Result:

...cs7_c_1

The top 3 products by revenue were **Blue Polo Shirt - Mens** (revenue around $218k which is 16,9% of total revenue), **Grey Fashion Jacket - Womens** (revenue around $209k which is 16,2% of total revenue) and **White Tee Shirt - Mens** (revenue around $152k which is 11,8% of total revenue).

#### 2. What is the total quantity, revenue and discount for each segment?


```sql
SELECT
    pd.segment_name,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty * s.price * s.discount /100),2) AS total_discount
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.segment_name;
```

##### Result:

...cs7_c_2

#### 3. What is the top selling product for each segment?

NOTE. Top selling products can be calculated by revenue or by quantity sold.

Top selling products by quantity sold.
```sql
WITH product_sales AS (
SELECT
    pd.segment_name,
    pd.product_name,
    DENSE_RANK() OVER (PARTITION BY pd.segment_name ORDER BY SUM(s.qty) DESC) AS selling_ranking,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty *s.price) AS revenue
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.segment_name, pd.product_name
)
SELECT
    segment_name,
    product_name,
    total_quantity,
    revenue
FROM product_sales
WHERE selling_ranking = 1;
```

##### Result:

by quantity sold
...cs7_c_3a


by revenue
...cs7_c_3b

In 3 of 4 segments, the same product generated the most revenue and the most sales. Only in the segment **Jeans** the products were different, **Navy Oversized Jeans - Womens** generated the biggest number of sales (3856) and **Black Straight Jeans - Womens** generated the biggest revenue (around $120k).

#### 4. What is the total quantity, revenue and discount for each category?


```sql
SELECT
    pd.category_name,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty * s.price * s.discount /100),2) AS total_discount
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.category_name;
```

##### Result:

...cs7_c_4

#### 5. What is the top selling product for each category?

Like in question 3 we can calculate the top products by revenue or by quantity sold.

Top selling products by quantity sold.
```sql
WITH product_sales AS (
SELECT
    pd.category_name,
    pd.product_name,
    DENSE_RANK() OVER (PARTITION BY pd.category_name ORDER BY SUM(s.qty) DESC) AS selling_ranking,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty *s.price) AS revenue
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.category_name, pd.product_name
)
SELECT
    category_name,
    product_name,
    total_quantity,
    revenue
FROM product_sales
WHERE selling_ranking = 1;
```

##### Result:

by quantity sold
...cs7_c_5a


by revenue
...cs7_c_5a

The result is exactly the same.



***

**Thanks for reading.** Please let me know what you think about my work. My emali address is ela.wajdzik@gmail.com

I am open to new work opportunities, so if you are looking for someone (or know that someone is looking for) with my skills, I will be glad for information. 


**Have a nice day!**
