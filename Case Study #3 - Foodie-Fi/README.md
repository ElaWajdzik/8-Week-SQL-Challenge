I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #3: 🥑 Foodie-Fi
<img src="https://8weeksqlchallenge.com/images/case-study-designs/3.png" alt="Image Foodie-Fi - Avo good time" height="400">

## Introduction
Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!

Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

## Available Data
Danny has shared the data design for Foodie-Fi and also short descriptions on each of the database tables - our case study focuses on only 2 tables but there will be a challenge to create a new table for the Foodie-Fi team.

All datasets exist within the ``foodie_fi`` database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

## Relationship Diagram

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/6cdd34d8-1c23-4294-a4ad-95e45605ecb4" width="500">


## Case Study Questions

- A. Customer Journey

- B. Data Analysis Questions

- Challenge Payment Question

- Outside The Box Questions


***
***

## Solution

The complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner/SQL%20code).

**Thank you in advance for reading.** If you have any comments on my work, please let me know. My email address is ela.wajdzik@gmail.com.

Additionally, I am open to new work opportunities. If you are looking for someone with my skills (or know of someone who is), I would be grateful for any information.

***


## A. Customer Journey

Based off the 8 sample customers provided in the sample from the ```subscriptions``` table, write a brief description about each customer’s onboarding journey.
Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

````sql
-- generate a random list of 8 unique customer IDs.

WITH customers AS (
	SELECT DISTINCT customer_id
	FROM subscriptions)

SELECT 
	TOP 8 * 
FROM customers
ORDER BY NEWID();
````

````sql
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
````

### Sample Data:


### Example of a Customer’s Onboarding Journey

Subscription Rules:
- The trial lasts 7 days.
- After the trial, the customer will automatically continue with the Pro Monthly plan.
- If the customer churns, the plan will stop after the end of the current payment period.
- If the customer upgrades from the Basic to the Pro plan, the higher plan will begin immediately.
- If the customer downgrades, the plan change will take effect after the current payment period ends.