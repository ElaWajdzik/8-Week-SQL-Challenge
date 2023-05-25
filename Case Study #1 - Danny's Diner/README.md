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

## Entity Relationship Diagram



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

Complete syntax is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/SQL%20syntax/danny's%20diner.sql).

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
- Use **SUM** and **GROUP BY** to find out ```amount_spent``` for each customer.
- USe **COUNT** and **GROUP BY** to find out ```number_orders``` for each customers.
- Use **JOIN** to merge two tables ```sales``` and ```menu```. The ```customer_id``` come from ```sales``` table and the ```price``` is from ```menu```.


#### Answer:
| customer_id | number_orders | amount_spent |
| ----------- | ------------- | ------------ |
| A           | 6             | 76           |
| B           | 6             | 74           |
| C           | 3             | 36           |


- Customer A ordered 6 products and spent $76.
- Customer B ordered 6 products and spent $74.
- Customer C ordered 3 products and spent $36.

***

### 2. How many days has each customer visited the restaurant?

