I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #1: 🍜 Danny's Diner 
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" alt="Image Danny's Diner - the taste of success" height="400">




Case Study Questions
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

