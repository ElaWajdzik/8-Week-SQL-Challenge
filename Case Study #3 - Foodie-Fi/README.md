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
![Zrzut ekranu 2024-09-27 234023](https://github.com/user-attachments/assets/fa955da0-fb3a-4fc8-8e93-f4da67096fc7)


### Example of a Customer’s Onboarding Journey:
![Zrzut ekranu 2024-09-27 142815](https://github.com/user-attachments/assets/c9deea62-b548-4cab-8bdf-e0d9e479659e)

Subscription Rules:
- The trial lasts 7 days.
- After the trial, the customer will automatically continue with the Pro Monthly plan.
- If the customer churns, the plan will stop after the end of the current payment period.
- If the customer upgrades from the Basic to the Pro plan, the higher plan will begin immediately.
- If the customer downgrades, the plan change will take effect after the current payment period ends.

*** 

**Customer 12** initiated their journey by starting the free trial on 22 Sep 2020. After the trial period ended on 29 Sep 2020, they subscribed to the basic monthly plan, and they are still on this plan.

<img src="https://github.com/user-attachments/assets/5ee3e17a-ccde-4539-a0d4-048847a773ac"  width="400">

**Custumer 168** initiated their journey by starting the free trial on 7 Mar 2020. After the trial period ended on 14 Mar 2020, they subscribed to the pro monthly plan, and they are still on this plan.

<img src="https://github.com/user-attachments/assets/861f230f-3b1e-4a6f-8baa-4f09524d8f60"  width="400">

**Custumer 354** initiated their journey by starting the free trial on 19 Mar 2020. After the trial period ended on 26 Mar 2020, they churned.

<img src="https://github.com/user-attachments/assets/ecfa42d8-0a0b-43fe-9133-e58e24f801e6" width="400">

**Custumer 432** initiated their journey by starting the free trial on 19 Mar 2020. After the trial period ended on 26 Mar 2020, they subscribed to the basic monthly plan. On 22 May 2020, they upgraded to the pro annual plan (which started on 22 May).

<img src="https://github.com/user-attachments/assets/f6928b31-2e0a-44f9-8c7a-7bc08c74a4c5" width="400">

**Custumer 470** initiated their journey by starting the free trial on 28 Apr 2020. After the trial period ended on 5 May 2020, they subscribed to the pro monthly plan. On 8 May 2020, they switched to the pro annual plan.

<img src="https://github.com/user-attachments/assets/a1da93d3-8b97-4b36-8d88-29938fefd5fa" width="400">

**Custumer 901** initiated their journey by starting the free trial on 21 Apr 2020. After the trial period ended on 28 Apr 2020, they subscribed to the basic monthly plan. On 22 May 2020, they upgraded to the pro monthly plan (which started on 22 May).

<img src="https://github.com/user-attachments/assets/1faf81ce-1a35-4937-a8af-d5c4a2fae86d" width="400">

**Custumer 918** initiated their journey by starting the free trial on 3 Jun 2020. After the trial period ended on 10 Jun 2020, they subscribed to the basic monthly plan. On 1 Sep 2020, they upgraded to the pro monthly plan (which started on 1 Sep). On 1 Dec 2020, they switched to the pro annual plan.

<img src="https://github.com/user-attachments/assets/ed7794c1-1812-4ae0-9025-b243be2a2d91" width="400">

**Custumer 996** initiated their journey by starting the free trial on 11 Nov 2020. After the trial period ended on 18 Nov 2020, they subscribed to the basic monthly plan. On 7 Dec 2020, they churned, and the monthly plan ended on 17 Dec 2020.

<img src="https://github.com/user-attachments/assets/ce2fc586-62e1-4775-a2ef-b11c6fefa2fe" width="400">
