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


***

**Thanks for reading.** Please let me know what you think about my work. My emali address is ela.wajdzik@gmail.com

I am open to new work opportunities, so if you are looking for someone (or know that someone is looking for) with my skills, I will be glad for information. 


**Have a nice day!**
