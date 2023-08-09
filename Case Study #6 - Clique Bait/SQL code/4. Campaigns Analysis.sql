-------------------------
--4. Campaigns Analysis--
-------------------------

--Author: Ela Wajdzik
--Date: 9.08.2023
--Tool used: Visual Studio Code & xampp


USE clique_bait;

/*
Generate a table that has 1 single row for every unique visit_id record and has the following columns:
    * user_id
    * visit_id
    * visit_start_time: the earliest event_time for each visit
    * page_views: count of page views for each visit
    * cart_adds: count of product cart add events for each visit
    * purchase: 1/0 flag if a purchase event exists for each visit
    * campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
    * impression: count of ad impressions for each visit
    * click: count of ad clicks for each visit

(Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)
*/

CREATE TABLE campaign_numbers (
WITH visit_campaign AS (
SELECT 
    e.visit_id,
    c.campaign_name
FROM (
    SELECT 
        visit_id,
        MIN(event_time) AS visit_start_time
    FROM events
    GROUP BY visit_id) AS e
JOIN campaign_identifier AS c 
ON e.visit_start_time BETWEEN c.start_date AND c.end_date
),
visit_cart AS (
SELECT 
    e.visit_id,
    GROUP_CONCAT(ph.page_name ORDER BY e.sequence_number SEPARATOR ', ') AS cart_products
FROM events AS e, page_hierarchy AS ph
WHERE e.page_id = ph.page_id AND e.event_type = 2
GROUP BY e.visit_id
)

SELECT 
    u.user_id,
    e.visit_id,
    MIN(e.event_time) AS visit_start_time,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
    MAX(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END) AS purchase,
    c.campaign_name,
    SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS impression,
    SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS click,
    cart.cart_products

FROM events AS e, users AS u, visit_campaign AS c, visit_cart AS cart
WHERE e.cookie_id = u. cookie_id AND e.visit_id=c.visit_id AND cart.visit_id = e.visit_id 
GROUP BY e.visit_id);


/* 
Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

* Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
* Does clicking on an impression lead to higher purchase rates?
* What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
* What metrics can you use to quantify the success or failure of each campaign compared to eachother?

*/

SELECT *
FROM campaign_numbers
LIMIT 10;

SELECT 
    campaign_name,
    impression,
    SUM(CASE WHEN impression > 0 THEN 1 END) AS all_impression,
    COUNT(*),
    SUM(page_views),
    SUM(cart_adds),
    SUM(purchase),
    SUM(click)
FROM campaign_numbers
GROUP BY campaign_name, impression;
