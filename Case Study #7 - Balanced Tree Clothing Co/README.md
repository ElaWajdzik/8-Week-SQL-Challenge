I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #7: 👕 Balanced Tree Clothing Co.
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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/e79e0f60-3d09-4b3e-aa8a-5e576d9e85e6" width="150">

There were 45216 products sold.

#### 2. What is the total generated revenue for all products before discounts?

```sql
SELECT
    SUM(qty*price) AS revenue
FROM sales;
```

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/40c732f3-0d8d-445c-b0fc-6516b9698267" width="150">

The total revenue was $1 289 453 

#### 3. What was the total discount amount for all products?

```sql
SELECT
    ROUND(SUM(qty*price*discount/100),2) AS total_discount
FROM sales;
```

To calculate the total discount, I used information about quantity (``qty``), price (``price``) and percentage discount (``discount``). I multiplied all three metrics and divided by 100 because ``discount`` in the table is an integer, not a percent.

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/0073e10c-d0c7-4001-bb1e-e8262c48094d" width="150">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/5396d605-0c4a-4226-8940-563b9df0ae44" width="200">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/e3449b73-6bc5-4c2a-b03b-0e73d0e12331" width="200">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/892baca0-94d1-4ab9-96fa-3e6b3da1f649" width="400">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/a6a7eeb1-c816-45b1-bff9-f836a7f843dd" width="400">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/c7079c5a-27c2-4859-a2b7-06d91ab5cb0c" width="400">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/a73cfa64-3cf0-4039-99fc-754e46831f86" width="400">

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
<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/b4ee722d-4ebf-4361-840b-d73b7ce16c80" width="500">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/738071e3-0146-44c7-9e0d-67996ced9436" width="600">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/597c0f4c-3f2d-4dbb-80ee-f0129c130859" width="600">

by revenue

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/d8c25372-49c1-498e-85b1-7d6e87e6bb5d" width="600">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/7043db2c-3cb5-460f-8ccf-0621a9100535" width="500">

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

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/6f2502d6-3fdd-4d56-9e60-8715f3ae2160" width="600">


by revenue

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/6f2502d6-3fdd-4d56-9e60-8715f3ae2160" width="600">

The result is exactly the same.

#### 6. What is the percentage split of revenue by product for each segment?

```sql
SELECT
    pd.segment_name,
    pd.product_name,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty *s.price)/(SUM(SUM(s.qty *s.price)) OVER (PARTITION BY pd.segment_name)) *100, 1) AS percentage_of_revenue_in_segment
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.segment_name, pd.product_name;
```

The column ``percentage_of_revenue_in_segment`` includes information about the percentage of revenue for each segment. It means that the sum of products in one segment is equal to 100%, and the total sum of the column will be more than 100% because we have more than one segment.

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/6ae570cf-40b4-4fcd-9fad-32d5d0e970e2" width="600">

#### 7. What is the percentage split of revenue by segment for each category?

```sql
SELECT
    pd.category_name,
    pd.segment_name,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty *s.price)/(SUM(SUM(s.qty *s.price)) OVER (PARTITION BY pd.category_name)) *100, 1) AS percentage_of_revenue_in_category
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.category_name, pd.segment_name;
```

Like in question 6, the column ``percentage_of_revenue_in_category`` contains information about the percentage of revenue for each category. If in the data we have more than one segment, the total sum of this column will be greater than 100.

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/4b62264a-de3c-43df-bf5c-39cbaab09dae" width="600">

#### 8. What is the percentage split of total revenue by category?

```sql
SELECT
    pd.category_name,
    SUM(s.qty *s.price) AS revenue,
    ROUND(SUM(s.qty *s.price)/(SUM(SUM(s.qty *s.price)) OVER ()) *100, 1) AS percentage_of_revenue_in_category
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY pd.category_name;
```

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/9a537786-3ed2-4967-8f6a-c598ec23c6f0" width="500">

#### 9. What is the total transaction “penetration” for each product? 

NOTE. Penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions

```sql
SELECT
    s.prod_id,
    pd.product_name,
    ROUND(COUNT(*)/(
        SELECT 
            COUNT(DISTINCT txn_id)
        FROM sales) *100,2) AS penetration
FROM sales AS s, product_details AS pd
WHERE s.prod_id = pd.product_id
GROUP BY s.prod_id;
```

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/4b1a5d2b-5b06-4171-85c5-06a92dcecec7" width="400">

For every product, the penetration value is close to 50%.

#### 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

In this question, we want to find the most common three products bought in one transaction. In the data, we have 12 unique products and we want to find a combination of three of them. It is 220 different three product combinations because it is 12 combinations of 3.

$$ \binom{12}{3} = {12! \over 3!(12-3)!} = {12 * 11 * 10 \over 3!} = 220$$

To calculate the number of three-product commbinations that exist in every transaction, I joined three times the same table, which includes only ``pruduct_name`` and ``txn_id`` to generate every three-product commbination for every transaction.


```sql
WITH txn_products AS (
    SELECT
        s.txn_id,
        s.prod_id,
        pd.product_name AS product
    FROM sales AS s, product_details AS pd
    WHERE s.prod_id = pd.product_id
),
combination_3_products AS (
    SELECT
        tp1.product AS product_1,
        tp2.product AS product_2,
        tp3.product AS product_3,
        COUNT(*) AS number_of_transactions,
        RANK () OVER (ORDER BY COUNT(*) DESC) AS rank
    FROM txn_products AS tp1
    JOIN txn_products AS tp2 
    ON tp1.txn_id = tp2.txn_id AND tp1.product != tp2.product AND tp1.product < tp2.product
    JOIN txn_products AS tp3
    ON tp1.txn_id = tp3.txn_id AND tp1.product != tp3.product AND tp1.product < tp3.product
    AND tp2.product != tp3.product AND tp2.product < tp3.product
    GROUP BY tp1.product, tp2.product, tp3.product
    ORDER BY number_of_transactions DESC
)
SELECT *
FROM combination_3_products
WHERE rank = 1;
```

##### Result:

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/2d257f5e-cbcc-4bc1-a767-3de14cd4f29e" width="600">

The most common combination of 3 products in a transaction was bought 352 times, and it contains:
- Grey Fashion Jacket - Womens
- Teal Button Up Shirt - Mens
- White Tee Shirt - Mens

The SQL query took a lot of time to calculate the result.

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/b7ca4942-ad79-498d-93a8-ed405bf411d2" width="100">

***

**Thanks for reading.** Please let me know what you think about my work. My emali address is ela.wajdzik@gmail.com

I am open to new work opportunities, so if you are looking for someone (or know that someone is looking for) with my skills, I will be glad for information. 


**Have a nice day!**
