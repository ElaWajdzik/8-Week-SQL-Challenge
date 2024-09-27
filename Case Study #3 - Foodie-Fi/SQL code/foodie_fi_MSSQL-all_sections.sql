------------------------------
--A. Customer Journey--
------------------------------

--Author: Ela Wajdzik
--Date: 27.09.2024
--Tool used: Microsoft SQL Server


--Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
--Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!



Select list of customer IDs (901, 470, 996, 918, 354, 168, 12, 432).

Check how the customers change their plan over time based on popularity.

Every customer starts with a free trial.

Customers may either churn (cancel their subscription) or maintain an active subscription.

-- generate a random list of 8 unique customer IDs.

WITH customers AS (
	SELECT DISTINCT customer_id
	FROM subscriptions
)

SELECT 
	TOP 8 * 
FROM customers
ORDER BY NEWID();

-- select list of customer IDs (901, 470, 996, 918, 354, 168, 12, 432).

-- check how the customers change their plan over time based on popularity.

WITH plans_in_time AS (
SELECT 
	customer_id,
	STRING_AGG (plan_id, ',') AS plan_list
FROM subscriptions
GROUP BY customer_id
)

SELECT 
	plan_list,
	COUNT(*) AS customer_number
FROM plans_in_time
GROUP BY plan_list
ORDER BY customer_number DESC;

--Based on the data, we can observe that:
--		Every customer starts with a free trial.
--		Customers may either churn (cancel their subscription) or maintain an active subscription.
--		No client downgraded their plan (switched from the Pro plan to the Basic plan)


SELECT 
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
FROM subscriptions s
INNER JOIN plans p
ON s.plan_id = p.plan_id
WHERE s.customer_id IN (901, 470,  996,  918, 354, 168, 12, 432);


------------------------------
--B. Data Analysis Questions--
------------------------------
