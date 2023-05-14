--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Ela Wajdzik
--Date: 11.05.2023 (update 14.05.2023)
--Tool used: Visual Studio Code & xampp

CREATE DATABASE dannys_diner;

USE dannys_diner;

CREATE TABLE sales (
  customer_id varchar(1),
  order_date date,
  product_id int
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

CREATE TABLE menu (
  product_id int,
  product_name varchar(5),
  price int
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

CREATE TABLE members (
  customer_id varchar(1),
  join_date date
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT * FROM dannys_diner.sales;
------------------------
--CASE STUDY QUESTIONS--
------------------------


--1. What is the total amount each customer spent at the restaurant?

SELECT 
    sales.customer_id,
    COUNT(sales.customer_id) AS number_orders, --    is not necesery to cout how many orders do each customer
    SUM(menu.price) AS amount_spent
FROM dannys_diner.sales AS sales
LEFT JOIN dannys_diner.menu AS menu
ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;


-- 2. How many days has each customer visited the restaurant?

SELECT 
    sales.customer_id,
    COUNT(DISTINCT sales.order_date) AS number_of_visits
FROM dannys_diner.sales AS sales
GROUP BY sales.customer_id;


-- 3. What was the first item from the menu purchased by each customer?

-- with temporary tables and dense_rank
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


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
  menu.product_name,
  COUNT(sales.product_id) AS number_of_orders
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY sales.product_id
ORDER BY number_of_orders DESC;

-- 5. Which item was the most popular for each customer?

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

-- 6. Which item was purchased first by the customer after they became a member?

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

-- 7. Which item was purchased just before the customer became a member?

WITH member_orders_before AS(
    SELECT 
        sales.customer_id,
        sales.product_id,
        sales.order_date,
        members.join_date,
        DENSE_RANK() OVER(
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS rank_after_join
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
WHERE member_orders_before.rank_after_join = 1
ORDER BY customer_id;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
    sales.customer_id,
    COUNT(DISTINCT sales.product_id) AS number_of_item,
    SUM(menu.price) AS total_spent
FROM dannys_diner.members
JOIN dannys_diner.sales
    ON members.customer_id=sales.customer_id
JOIN dannys_diner.menu
    ON sales.product_id=menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
    sales.customer_id,
    SUM(IF(menu.product_name='sushi',2,1)*menu.price * 10) AS points 
FROM dannys_diner.sales
JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

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


-------------------
--Bonus Questions--
-------------------

--1. Join All The Things
--Recreate the following table output using the available data

--customer_id   order_date  product_name	price	member
--A             2021-01-01  curry	        15	    N

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

--2. Rank All The Things

--customer_id	order_date	product_name	price	member	ranking
--A	            2021-01-01	curry	        15	    N	    null

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
