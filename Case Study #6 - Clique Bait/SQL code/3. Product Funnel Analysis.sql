------------------------------
--3. Product Funnel Analysis--
------------------------------

--Author: Ela Wajdzik
--Date: 6.08.2023
--Tool used: Visual Studio Code & xampp


USE clique_bait;

/*
Using a single SQL query - create a new output table which has the following details:

- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?
- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
*/

-- NOTE If some visits include a purchase, it means that visits end (the max sequence_numnber) on a purchase (page_id = 13 and event_type = 3)

-- expecting columns
-- | product_name | prodact_view | prodact_add_to_cart | prodact_abandoned | prodact_purchase |

CREATE TABLE product_number (
WITH product_1 AS (
SELECT 
    e.page_id,
    ph.page_name AS product_name,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS prodact_view,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS prodact_add_to_cart
FROM events AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id
GROUP BY e.page_id
),
product_2 AS (
SELECT
    page_id,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS prodact_purchase
FROM (
    SELECT 
        *
    FROM events
    WHERE visit_id IN (
        SELECT
            visit_id
        FROM events
        WHERE event_type = 3)) AS events_with_purchase
GROUP BY page_id
)

SELECT 
    p1.product_name,
    p1.prodact_view,
    p1.prodact_add_to_cart,
    p1.prodact_add_to_cart - p2.prodact_purchase AS prodact_abandoned,
    p2.prodact_purchase
FROM product_1 AS p1, product_2 As p2
WHERE p1.page_id = p2.page_id AND p1.page_id NOT IN ('1','2','12','13')
);


-- expecting columns
-- | category_name | category_view | category_add_to_cart | category_abandoned | category_purchase |

CREATE TABLE category_number (
WITH category_1 AS (
SELECT 
    ph.product_category AS category_name,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS category_view,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS category_add_to_cart
FROM events AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id
GROUP BY ph.product_category
),
category_2 AS (
SELECT
    ph.product_category AS category_name,
    SUM(CASE WHEN ep.event_type = 2 THEN 1 ELSE 0 END) AS category_purchase
FROM (
    SELECT 
        *
    FROM events
    WHERE visit_id IN (
        SELECT
            visit_id
        FROM events
        WHERE event_type = 3)) AS ep, page_hierarchy AS ph
WHERE ep.page_id = ph.page_id
GROUP BY ph.product_category
)

SELECT 
    c1.category_name,
    c1.category_view,
    c1.category_add_to_cart,
    c1.category_add_to_cart - c2.category_purchase AS category_abandoned,
    c2.category_purchase
FROM category_1 AS c1, category_2 As c2
WHERE c1.category_name = c2.category_name AND c1.category_name IS NOT NULL
);


/*
Use your 2 new output tables - answer the following questions:

1. Which product had the most views, cart adds and purchases?
2. Which product was most likely to be abandoned?
3. Which product had the highest view to purchase percentage?
4. What is the average conversion rate from view to cart add?
5. What is the average conversion rate from cart add to purchase?
*/