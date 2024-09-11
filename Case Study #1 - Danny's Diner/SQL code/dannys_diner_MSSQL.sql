--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Ela Wajdzik
--Date: 9.09.2024
--Tool used: Microsoft SQL Server


--create tables with data

CREATE SCHEMA dannys_diner;
--SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
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
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
 
 CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

--create relationships between tables and add constraints

--members.customer_id = sales.customer_id (1 to many)
--menu.product_id = sales.product_id (1 to many)

ALTER TABLE members
ALTER COLUMN customer_id VARCHAR(1) NOT NULL;

ALTER TABLE members
ADD CONSTRAINT members_customer_id_pk PRIMARY KEY (customer_id);

ALTER TABLE menu
ALTER COLUMN product_id INT NOT NULL;

ALTER TABLE menu
ADD CONSTRAINT menu_product_id_pk PRIMARY KEY (product_id);

ALTER TABLE sales
ADD CONSTRAINT sales_product_id_fk 
FOREIGN KEY(product_id) REFERENCES menu(product_id);

--we can't create a foreign key constraint between members.customer_id and sales.customer_id because not every customer is also a member

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?

SELECT
	s.customer_id,
  COUNT(s.customer_id) AS number_orders, 	--is not necesery to cout how many orders do each customer
	SUM(m.price) AS total_amount
FROM sales s
LEFT JOIN menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;

--2. How many days has each customer visited the restaurant?

SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS number_of_days
FROM sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?

WITH sales_with_ranking AS (
	SELECT
		s.*,
		m.product_name,									--add the name of the product
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranking	--product ranking order
	FROM sales s
	LEFT JOIN menu m
	ON m.product_id = s.product_id)

SELECT
	customer_id,
	product_name
FROM sales_with_ranking
WHERE ranking = 1			--select only the first order
GROUP BY customer_id, product_name;	--grup by the same product

--If I work with PostgreSQL, I will make use of the construct called SELECT DISTINCT ON () and ORDER BY order_date ASC.

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
	m.product_name,
	COUNT(*) AS number_of_orders  --counts every order from every client
FROM sales s
LEFT JOIN menu m
	ON m.product_id = s.product_id
GROUP BY m.product_name;

--5. Which item was the most popular for each customer?

WITH sales_with_popularity_by_client AS (
	SELECT 
		s.customer_id,
		m.product_name,
		COUNT(*) AS number_of_orders,								--counts every product bought by every client
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS ranking	--the most popular product ranking by each client
	FROM sales s
	LEFT JOIN menu m
		ON m.product_id=s.product_id
	GROUP BY s.customer_id, m.product_name)

SELECT
	customer_id,
	product_name,
	number_of_orders		--this information is not necessary
FROM sales_with_popularity_by_client
WHERE ranking = 1;





--6. Which item was purchased first by the customer after they became a member?
--7. Which item was purchased just before the customer became a member?
--8. What is the total items and amount spent for each member before they became a member?
--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
