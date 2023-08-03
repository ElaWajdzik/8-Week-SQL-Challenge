-----------------------
--2. Digital Analysis--
-----------------------

--Author: Ela Wajdzik
--Date: 3.08.2023
--Tool used: Visual Studio Code & xampp


USE clique_bait;

-- 1. How many users are there?

SELECT 
    COUNT(DISTINCT user_id) AS number_of_users
FROM users;

-- 2. How many cookies does each user have on average?

SELECT
    ROUND(COUNT(user_id)/COUNT(DISTINCT user_id),1) AS avg_number_of_cookis_per_user
FROM users;

-- 3. What is the unique number of visits by all users per month?

SELECT 
    MONTH(event_time) AS month,
    COUNT(DISTINCT visit_id) AS unique_number_of_visit
FROM events
GROUP BY MONTH(event_time);


SELECT 
    ROUND(COUNT(DISTINCT visit_id)/5,0) AS avg_number_of_visits_per_month
FROM events;

-- 4. What is the number of events for each event type?

SELECT
    e.event_type,
    ei.event_name,
    COUNT(e.event_type) AS number_of_events
FROM events AS e, event_identifier AS ei
WHERE e.event_type = ei.event_type
GROUP BY event_type;

-- 5. What is the percentage of visits which have a purchase event?

SELECT 
    ROUND((COUNT(DISTINCT e.visit_id)/n_visit.number_of_visit)*100,1) AS proc_of_visits_with_purchase
FROM events AS e, 
    (SELECT 
        COUNT(DISTINCT visit_id) AS number_of_visit
    FROM events) AS n_visit
WHERE event_type = 3;

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

-- visits which view the checkout page -> page_id = 12
-- purchase event -> event_type = 3

-- NOTE: Every purchase requires a visit to the checkout page.

WITH visit_checkout_purchase AS (
SELECT
    visit_id,
    MAX(CASE 
        WHEN event_type = 3 THEN 1  
        ELSE 0 
    END) AS visit_with_purchase,
    MAX(CASE 
        WHEN page_id = 12 THEN 1 
        ELSE 0
    END) AS visit_with_checkout_page
FROM events
GROUP BY visit_id
)

SELECT
    SUM(visit_with_checkout_page)-SUM(visit_with_purchase) AS number_of_visit_with_checkout_without_purchase,
    ROUND(((SUM(visit_with_checkout_page)-SUM(visit_with_purchase))/COUNT(*))*100,1) AS proc_of_visit_with_checkout_without_purchase
FROM visit_checkout_purchase AS vcp;


-- 7. What are the top 3 pages by number of views?

SELECT 
    e.page_id,
    ph.page_name,
    COUNT(e.page_id) AS number_of_viewes
FROM events AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id
GROUP BY e.page_id
ORDER BY COUNT(e.page_id) DESC
LIMIT 3;


-- 8. What is the number of views and cart adds for each product category?

SELECT 
    ph.product_category,
    COUNT(e.page_id) AS number_of_viewes,
        SUM(CASE 
        WHEN e.event_type = 2 THEN 1
        ELSE 0
    END) AS number_of_cart_adds
FROM events AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id AND ph.product_category IS NOT NULL
GROUP BY ph.product_category
ORDER BY COUNT(e.page_id) DESC;


-- 9. What are the top 3 products by purchases?

WITH events_with_purchase AS (
    SELECT 
        *
    FROM events
    WHERE visit_id IN (
        SELECT
            visit_id
        FROM events
        WHERE event_type = 3)
)

SELECT 
    ph.page_name AS product_name,
    ph.product_category,
    SUM(CASE 
        WHEN e.event_type = 2 THEN 1
        ELSE 0
    END) AS number_of_buy
FROM events_with_purchase AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id AND ph.product_category IS NOT NULL
GROUP BY ph.page_name
ORDER BY number_of_buy DESC
LIMIT 3;
