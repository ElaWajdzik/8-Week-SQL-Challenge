--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Ela Wajdzik
--Date: 11.05.2023
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

-- with temporary tables
WITH first_visit AS (
	SELECT 
		sales.customer_id,
		MIN(sales.order_date) AS data_first_visit
	FROM dannys_diner.sales 
	GROUP BY sales.customer_id
),
first_product AS (
	SELECT
		first_visit.customer_id,
		sales.product_id
	FROM first_visit
	LEFT JOIN dannys_diner.sales
	ON (first_visit.customer_id,first_visit.data_first_visit) = (sales.customer_id, sales.order_date)
	GROUP BY first_visit.customer_id, sales.product_id
)

SELECT 
	first_product.customer_id,
    menu.product_name
FROM first_product
LEFT JOIN dannys_diner.menu
ON first_product.product_id = menu.product_id
ORDER BY first_product.customer_id;

-- the other way is to use rank and select only the first position
-- DENSE_RANK() OVER(PARTITION BY s.c_id ORDER BY s.o_date) AS rank

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
    sales.customer_id;



-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
