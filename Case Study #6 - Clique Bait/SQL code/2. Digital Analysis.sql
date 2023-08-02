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
    MONTH(event_time),
    COUNT(DISTINCT visit_id)
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


/* 

What is the percentage of visits which have a purchase event?
What is the percentage of visits which view the checkout page but do not have a purchase event?
What are the top 3 pages by number of views?
What is the number of views and cart adds for each product category?
What are the top 3 products by purchases?
*/