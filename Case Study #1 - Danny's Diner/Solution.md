# Case Study #1: 🍜 Danny's Diner 

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



