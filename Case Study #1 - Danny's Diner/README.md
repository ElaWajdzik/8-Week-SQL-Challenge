I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #1: 🍜 Danny's Diner 
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" alt="Image Danny's Diner - the taste of success" height="400">

## Introduction
Danny seriously loves Japanese food so at the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but has no idea how to use their data to help them run the business.


## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:
* ```sales```
* ```menu```
* ```members```

You can inspect the entity relationship diagram and example data below.

## Relationship Diagram

<img width="404" alt="graf1" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/f8120a7a-13d9-49e9-92f4-2077ec3041a9">


## Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


## Solution

Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/997d4dd5b006d9b8b1f945e9f64e9e4e0f1baa91/Case%20Study%20%231%20-%20Danny's%20Diner/SQL%20code).

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT 
    sales.customer_id,
    COUNT(sales.customer_id) AS number_orders,
    SUM(menu.price) AS amount_spent
FROM dannys_diner.sales AS sales
LEFT JOIN dannys_diner.menu AS menu
ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;
````

#### Steps:
- Use **SUM** and **GROUP BY** to find out the ```amount_spent``` for each customer.
- Use **COUNT** and **GROUP BY** to find out the ```number_orders``` for each customer.
- Use **JOIN** to merge two tables, ```sales``` and ```menu```. The ```customer_id``` comes from the ```sales``` table and the ```price``` comes from the ```menu```.

#### Result:
| customer_id | number_orders | amount_spent |
| ----------- | ------------- | ------------ |
| A           | 6             | 76           |
| B           | 6             | 74           |
| C           | 3             | 36           |


- Customer **A** ordered 6 products and spent $76.
- Customer **B** ordered 6 products and spent $74.
- Customer **C** ordered 3 products and spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT 
    sales.customer_id,
    COUNT(DISTINCT sales.order_date) AS number_of_visits
FROM dannys_diner.sales AS sales
GROUP BY sales.customer_id;
````

#### Steps:
- Use **COUNT DISTINCT** to count the number of different days of a visit. The function **COUNT(DISTINCT)** returns the number of rows with different non-NULL values. In this case, it will be the number of days visited for each customer.


#### Result:
| customer_id | number_of_visits |
| ----------- | -----------------|
| A           | 4                |
| B           | 6                |
| C           | 2                |

- Customer **A** visited Danny's Diner on 4 different days.
- Customer **B** visited Danny's Diner on 6 different days.
- Customer **C** visited Danny's Diner on 2 different days.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
WITH product_rank AS(
    SELECT
        customer_id,
        order_date,
        DENSE_RANK() OVER(
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS popular_rank,
        menu.product_name
    FROM dannys_diner.sales
    JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
    GROUP BY sales.product_id, sales.order_date
)

SELECT
    customer_id,
    product_name
FROM product_rank
WHERE popular_rank=1;
````

#### Steps:
- I created a temporary table to calculate the ranking of orders. Clause **WITH**
- I created the ranking of orders using the clause **DENSE_RANK**. The function **DENSE_RANK()** is used to find the rank of a row in a set (which we can specify in the parameter **PARTITION BY**). This function displays the numbers from one, and in the case of identical values, it receives the same result and doesn't skip the values in the results. e.g. If in the set we have two values whose rank is equal to 2, then the next value will have rank equal to 3.

#### Result:
| customer_id | product_name |
| ----------- | -------------|
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |

- Customer **A** in his/her first purchase bought two dishes, sushi and curry.
- Customer **B** first purchased curry.
- Customer **C** first purchased ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT
  menu.product_name,
  COUNT(sales.product_id) AS number_of_orders
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY sales.product_id
ORDER BY number_of_orders DESC;
````

#### Steps:
- I use **COUNT** to calculate the number of orders for each dish.
- I ordered the results in descending order using **ORDER BY** with parameter **DESC** to find which item was the most frequently purchased.

#### Result:
| product_name | number_of_orders |
|--------------|------------------|
| ramen        | 8                |
| curry        | 4                |
| sushi        | 3                |

- The most frequently purchased item was ramen. The customers at Danny's Dinner bought it 8 times (two times more than curry).

***

### 5. Which item was the most popular for each customer?

````sql
WITH popular_order AS (
    SELECT 
	    sales.customer_id,
        menu.product_name,
	    COUNT(sales.product_id) AS number_of_orders,
        DENSE_RANK() OVER (
            PARTITION BY customer_id
            ORDER BY number_of_orders DESC
        ) AS popular_rank
    FROM dannys_diner.sales
    LEFT JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
    GROUP BY 
        sales.product_id, 
        sales.customer_id
)        

SELECT 
    customer_id,
    product_name
FROM popular_order
WHERE popular_rank=1
ORDER BY customer_id;
````

#### Steps:
- I created a temporary table (using **WITH**) to create a ranking of popularity (using **DENSE_RANK**).
- Print only part of the temporary table **WHERE** ranking of popularity is equal to 1.

#### Result:
| customer_id | product_name |
|-------------|--------------|
| A           | ramen        |
| B           | curry        |
| B           | ramen        |
| B           | sushi        |
| C           | ramen        |

- The most popular item for every customer was ramen.
- In addition, customer **B** liked every item (ramen, sushi and curry).

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
WITH member_orders AS(
    SELECT 
        sales.customer_id,
        sales.product_id,
        sales.order_date,
        members.join_date,
        DENSE_RANK() OVER(
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS rank_after_join
    FROM dannys_diner.members
    JOIN dannys_diner.sales
    ON members.customer_id=sales.customer_id
    WHERE sales.order_date >= members.join_date
)

SELECT 
    customer_id,
    menu.product_name
FROM member_orders
JOIN dannys_diner.menu
ON member_orders.product_id = menu.product_id
WHERE member_orders.rank_after_join = 1
ORDER BY customer_id;
````

#### Steps:
- Like in question 5, I created a temporary table (using **WITH**) to create a ranking of orders (using **DENSE_RANK**).
- Pick the first order for every member after joining, using the ranking of orders, and select only the first value (clause **WHERE**).


#### Result:
| customer_id | product_name |
|-------------|--------------|
| A           | curry        |
| B           | sushi        |

- After customer **A** became a member, he/she purchased first curry.
- After customer **B** became a member, he/she purchased first sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
WITH member_orders_before AS(
    SELECT 
        sales.customer_id,
        sales.product_id,
        sales.order_date,
        members.join_date,
        DENSE_RANK() OVER(
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS rank_before_join
    FROM dannys_diner.members
    JOIN dannys_diner.sales
    ON members.customer_id=sales.customer_id
    WHERE sales.order_date < members.join_date
)

SELECT 
    customer_id,
    menu.product_name
FROM member_orders_before
JOIN dannys_diner.menu
ON member_orders_before.product_id = menu.product_id
WHERE member_orders_before.rank_before_join = 1
ORDER BY customer_id;
````

#### Steps:
- I use a similar function like in question 6. The biggest change is to use **DENSE_RANK** in descending order.

#### Result:
| customer_id | product_name |
|-------------|--------------|
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

- Customer **A** in the order before starting to be a member bought two kinds of items - sushi and carry.
- Customer **B** in the order before starting to be a member bought sushi.

According to results from questions 6 and 7, customers **A** and **B** bought the same product just before becoming members and just after becoming members.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT 
    sales.customer_id,
    COUNT(sales.product_id) AS number_of_item,
    COUNT(DISTINCT sales.product_id) AS number_of_diffrent_item,
    SUM(menu.price) AS total_spent
FROM dannys_diner.members
JOIN dannys_diner.sales
    ON members.customer_id=sales.customer_id
JOIN dannys_diner.menu
    ON sales.product_id=menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id;
````

#### Steps:
- I use calculatet functions **COUNT**, **COUNT DISTINCT** and **SUM**.
- I need to join all three tables to create a result.

#### Result:
| customer_id | number_of_item | number_of_diffrent_item | total_spent |
|-------------|----------------|-------------------------|-------------|
| A           | 2              | 2                       | 25          |
| B           | 3              | 2                       | 40          |

- Customer **A** before becoming a member, spent $25 at Danny Diner's and bought 2 items.
- Customer **B** before becoming a member, spent $40 at Danny Diner's and bought 3 items (2 different items).

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
SELECT
    sales.customer_id,
    SUM(IF(menu.product_name='sushi',2,1)*menu.price * 10) AS points 
FROM dannys_diner.sales
JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
GROUP BY customer_id;
````

#### Steps:
- I use the function **IF** to act on the 2x points multiplier for sushi. According to the value of ``product_name`` I calculated 1 or 2 (if ``product_name`` is equal to sushi, then 2 in other cases, multiplication doesn't exist, which means it equals 1).

#### Result:
| customer_id | points |
|-------------|--------|
| A           | 860    |
| B           | 940    |
| C           | 360    |

- Customer **A** colected 860 points, customer **B** colected 940 points and customer **C** colected 360 points.

It is interesting how they can get for these points.


***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

````sql
SELECT
    sales.customer_id,
    SUM(IF((sales.order_date>= members.join_date AND sales.order_date< members.join_date +7) OR sales.product_id=1,2,1) *
    menu.price * 10) AS points
FROM dannys_diner.sales
JOIN dannys_diner.members
    ON sales.customer_id = members.customer_id
JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
WHERE order_date < '2021-02-01'
GROUP BY sales.customer_id;
````

#### Steps:
- It is important not to increase the multiplier for sushi during the first week of membership to 4.
- I use the functions **SUM** and **IF** to calculate the number of points. Function **IF** has two conditions. (1) orders come from the first week of becoming a member, or (2) the order product was sushi. If it was one of those two conditions the multiplayer was equal to 2, in the other case it was 1.
- I limited the data on orders to the end of January.


#### Result:

| customer_id | points |
|-------------|--------|
| A           | 1370   |
| B           | 820    |

- Customer **A** collected 1370 points.
- Customer **B** collected 820 points. If we look closer at the data, we can find out that this customer didn't collect any extra points because she/he became a member.


***

***



## Bonus Questions

### Join All The Things

Recreate the following table output using the available data

| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | curry	      | 15	  | N      |


````sql
SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    IF (members.join_date <= sales.order_date,'Y','N') AS member
FROM dannys_diner.sales
JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members
    ON sales.customer_id = members.customer_id;
````

#### Steps:
- I need to join all three tables to create the expected table. From the table ``sales`` I need dates about ``customer_id`` and ``order_date``. From the table ``menu`` I need dates about  ``product_name`` and ``price``. The date from the table ``members`` was needed to calculate the value of column ``member``.

#### Result:
<img width="406" alt="CaseStudy#1 - Join All The Things" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/0a538c49-1e9c-466b-b9c9-d7b869aaa1eb">



***

### Rank All The Things
Create a table like before in **Join All The Things** but add the ``ranking``. The ``ranking`` of customer products is only for member purchases, and the ``ranking`` value is **null** when customers are not yet part of the loyalty program.


````sql
WITH temporary_member AS (
SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    IF (members.join_date <= sales.order_date,'Y','N') AS member
FROM dannys_diner.sales
JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members
    ON sales.customer_id = members.customer_id
)

SELECT *,
    CASE 
        WHEN member = 'N' THEN  NULL
        ELSE RANK() OVER(
        PARTITION BY customer_id, member
        ORDER BY order_date)
    END AS ranking
FROM temporary_member;
````

#### Steps:
- I created the table like before but using the clause **WITH**.
- In the second step, I add the ``ranking`` only for the data that involves the member's purchase.

#### Result:
<img width="463" alt="CaseStudy#1 - Rank All The Things" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/be758897-0cc2-4a95-a953-2465fa0d33ae">


***

**Thanks for reading.** If you have some comments have I can improve my work, please let me know. I am open to new work opportunities, so if you are looking for someone (or know that someone is looking for) with my skills, I will be glad for information. My emali address is ela.wajdzik@gmail.com


**Have a nice day!**
