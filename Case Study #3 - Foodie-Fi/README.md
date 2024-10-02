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
-- check how customers changed their plans over time based on popularity

WITH plans_in_time AS (
SELECT 
	customer_id,
	STRING_AGG (plan_id, ',') AS plan_list -- concatenate the information about all plans for each customer in chronological order (by start_date)
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

### Subscription Rules:
- The trial lasts 7 days.
- After the trial, the customer automatically continue with the Pro Monthly plan.
- If the customer churns, the subscription will end after the current payment period.
- If the customer upgrades from the Basic to the Pro plan, the higher plan begins immediately.
- If the customer downgrades, the plan change will take effect after the current payment period ends.


*** 

### Customer Journeys:

**Customer 12** started their journey with a free trial on 22 Sep 2020. After the trial ended on 29 Sep 2020, they subscribed to the basic monthly planand have remained on this plan since.

<img src="https://github.com/user-attachments/assets/5ee3e17a-ccde-4539-a0d4-048847a773ac"  width="400">

**Custumer 168** started their journey with a free trial on 7 Mar 2020. After the trial ended on 14 Mar 2020, they subscribed to the pro monthly plan, and are still on this plan.

<img src="https://github.com/user-attachments/assets/861f230f-3b1e-4a6f-8baa-4f09524d8f60"  width="400">

**Custumer 354** started their journey with a free trial on 19 Mar 2020. After the trial ended on 26 Mar 2020, they churned and did not subscribe to any plan.

<img src="https://github.com/user-attachments/assets/ecfa42d8-0a0b-43fe-9133-e58e24f801e6" width="400">

**Custumer 432** started their journey with a free trial on 19 Mar 2020. After the trial ended on 26 Mar 2020, they subscribed to the basic monthly plan. On 22 May 2020, they upgraded to the pro annual plan (which started immediately on 22 May).

<img src="https://github.com/user-attachments/assets/f6928b31-2e0a-44f9-8c7a-7bc08c74a4c5" width="400">

**Custumer 470** started their journey with a free trial on 28 Apr 2020. After the trial ended on 5 May 2020, they subscribed to the pro monthly plan. On 8 May 2020, they switched to the pro annual plan.

<img src="https://github.com/user-attachments/assets/a1da93d3-8b97-4b36-8d88-29938fefd5fa" width="400">

**Custumer 901** started their journey with a free trial on 21 Apr 2020. After the trial ended on 28 Apr 2020, they subscribed to the basic monthly plan. On 22 May 2020, they upgraded to the pro monthly plan (which began on the same day).

<img src="https://github.com/user-attachments/assets/1faf81ce-1a35-4937-a8af-d5c4a2fae86d" width="400">

**Custumer 918** started their journey with a free trial on 3 Jun 2020. After the trial ended on 10 Jun 2020, they subscribed to the basic monthly plan. On 1 Sep 2020, they upgraded to the pro monthly plan (which started on 1 Sep). Later, on 1 Dec 2020, they switched to the pro annual plan.

<img src="https://github.com/user-attachments/assets/ed7794c1-1812-4ae0-9025-b243be2a2d91" width="400">

**Custumer 996** started their journey with a free trial on 11 Nov 2020. After the trial ended on 18 Nov 2020, they subscribed to the basic monthly plan. On 7 Dec 2020, they churned, and the plan ended on 17 Dec 2020.

<img src="https://github.com/user-attachments/assets/ce2fc586-62e1-4775-a2ef-b11c6fefa2fe" width="400">


***

## B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

````sql
SELECT COUNT(DISTINCT customer_id) AS number_of_customers
FROM subscriptions;
````

#### Result:
| number_of_customers |
| ------------------- |
| 1000                |

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

````sql
SELECT 
	DATETRUNC(month, start_date) AS start_of_month, -- truncated to the start tof the month
	COUNT(*) AS number_of_customers
FROM subscriptions
WHERE plan_id = 0 -- select only records related to the trial plan
GROUP BY DATETRUNC(month, start_date)
ORDER BY start_of_month; -- use the alias for the column: DATETRUNC(month, start_date)
````

#### Result:
![Zrzut ekranu 2024-10-02 120444](https://github.com/user-attachments/assets/4fab25c9-a06a-483d-bfe7-5b1fd53460a9)

![Zrzut ekranu 2024-10-02 121235](https://github.com/user-attachments/assets/b63cf1df-926d-4d9c-8823-20a29877a547)


The average number of new customers per month is around 80. The number of new customers starting a trial plan is consistent each month. The largest difference between two months was 26 (with 94 in March and 68 in February), but for the rest of the months, the numbers were quite similar, ranging between 75 and 89.


### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

````sql
SELECT 
	YEAR(s.start_date) AS start_year,
	p.plan_name,
	COUNT(*) AS number_of_plans
FROM subscriptions s
INNER JOIN plans p
ON p.plan_id = s.plan_id
WHERE YEAR(s.start_date) > 2020
GROUP BY YEAR(s.start_date), p.plan_name;
````

#### Result:

![Zrzut ekranu 2024-10-02 122458](https://github.com/user-attachments/assets/a1fe31e5-4d6d-4ed4-a27a-62af1a7c87b6)

No one started a trial after 2020, which could mean that the plan no longer exists or that the product has stopped attracting new customers. One out of three subscriptions after 2020 was churned, which may indicate that the product is no longer attractive to customers.

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

````sql
DECLARE @n_customer_churn INT; --declare the local variable 
DECLARE @n_customer INT;

SET @n_customer_churn = 
(SELECT
	COUNT(*)
FROM subscriptions
WHERE plan_id = 4);

SET @n_customer =
(SELECT COUNT(DISTINCT customer_id)
FROM subscriptions);

-- print the results
PRINT 'Number of customers who churned: ' + CAST(@n_customer_churn AS VARCHAR);
PRINT 'Percentage of customers who have churned: ' + CAST(CAST(@n_customer_churn * 100.0 / @n_customer AS NUMERIC (4,1)) AS VARCHAR) +'%';
````

#### Steps:
- Declared two integer local variables. The total number of customers is stored in ```@n_customers``` and the number of churned customers is stored in ```@n_customers_churn```.
- Set the values for ```@n_customers``` and ```@n_customers_churn``` based on the data from the ```subscriptions``` table.
- Printed the value of  ```@n_customers_churn``` and calculated the percentage of all customers. The result includes text explaining the number, which is why I changed the data type of results to ```VARCHAR```. 

#### Result:

![Zrzut ekranu 2024-10-02 134851](https://github.com/user-attachments/assets/947a4c83-ab78-4d27-a0b7-9b8db8a1df88)


Almost one in every three customers has churned (30.7%). It would be beneficial to monitor this value over time to determine if this is a baseline churn rate for this business or if it may indicate potential issues.

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

````sql
WITH plan_change_histories AS (
SELECT 
	customer_id,
	STRING_AGG (plan_id, ',') WITHIN GROUP (ORDER BY start_date ASC) AS plan_change_history
FROM subscriptions
GROUP BY customer_id
)

SELECT 
	plan_change_history,
	COUNT(*) AS number_of_customers,

	-- use a subquery to calculate the total number of customers
	CAST(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS NUMERIC (3,0)) AS percent_of_customers
FROM plan_change_histories
--WHERE plan_change_history = '0,4' --filter to show only the relevent case (customers who churned immediately after the trial)
GROUP BY plan_change_history
ORDER BY number_of_customers DESC;
````

#### Result:
![Zrzut ekranu 2024-10-02 154513](https://github.com/user-attachments/assets/d062d5a9-8523-4725-b893-02b9cd90ced5)


9% of all customers churned immediately after the trial. It would be beneficial to monitor this value over time.

### 6. What is the number and percentage of customer plans after their initial free trial?

````sql
WITH plan_change_histories AS (
SELECT 
	customer_id,
	STRING_AGG (plan_id, ',') WITHIN GROUP (ORDER BY start_date ASC) AS plan_change_history,
	SUBSTRING(STRING_AGG (plan_id, ',') WITHIN GROUP (ORDER BY start_date ASC), 3, 1) AS plan_after_trial --select the plan_id for the plan after the trial
FROM subscriptions
GROUP BY customer_id
)

SELECT 
	p.plan_name AS plan_name_after_trial,
	COUNT(*) AS number_of_customers,
	CAST(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS NUMERIC (4,1)) AS percent_of_customers
FROM plan_change_histories h
INNER JOIN plans p --join the plans table to display the names of the plans
ON p.plan_id = h.plan_after_trial
GROUP BY p.plan_name;
````

#### Results:
![Zrzut ekranu 2024-10-02 154612](https://github.com/user-attachments/assets/0a3ae517-a92e-4af5-8825-7a4608a444fe)


The largest fraction (87%) of customers decided to purchase monthly subscriptions after the trial, with 55% opting for the Basic Monthly plan and 32% for the Pro Monthly plan.

### 7. What is the customer count and percentage breakdown of all plan_name values at 2020-12-31?

````sql
WITH plan_change_histories AS (
SELECT 
	customer_id,
	--STRING_AGG (plan_id, ',') WITHIN GROUP (ORDER BY start_date ASC) plan_change_history,
	SUBSTRING(STRING_AGG (plan_id, ',') WITHIN GROUP (ORDER BY start_date DESC), 1, 1) AS plan_end_2020 --select the last plan_id in 2020
FROM subscriptions
WHERE YEAR(start_date) < 2021 --filter the data to include only entries before the year 2021
GROUP BY customer_id
)

SELECT 
	p.plan_name AS plan_name_end_2020,
	COUNT(*) AS number_of_customers,
	CAST(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions WHERE YEAR(start_date) < 2021) AS NUMERIC (4,1)) AS percent_of_customers
FROM plan_change_histories h
INNER JOIN plans p
ON p.plan_id = h.plan_end_2020
GROUP BY p.plan_name;
````

#### Result:
![Zrzut ekranu 2024-10-02 154655](https://github.com/user-attachments/assets/7d98df55-e462-4f59-b75e-c4589d79b614)


By the end of 2020, 55% of customers were on a monthly plan, and 19.5% were on an annual plan. This means that three out of four of the total customers had a paid subscription.

### 8. How many customers have upgraded to an annual plan in 2020?

````sql
SELECT 
	COUNT(DISTINCT customer_id) AS number_of_customers
FROM subscriptions
WHERE YEAR(start_date) < 2021
AND plan_id = 3;
````

#### Result:

| number_of_customers |
| ------------------- |
| 195                 |


### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

````sql
WITH customers_with_annual_plan AS ( -- for each customer on annual plan, select the start date of this plan
	SELECT 
		customer_id,
		MIN(start_date) AS start_annual_plan 
	FROM subscriptions
	WHERE plan_id = 3
	GROUP BY customer_id),

customers_start_date AS(  -- for each customer, select the start date of the trial
	SELECT 
		customer_id,
		MIN(start_date) AS start_trial
	FROM subscriptions
	WHERE plan_id = 0
	GROUP BY customer_id
	)

SELECT 
	AVG(DATEDIFF(day, start_trial, start_annual_plan)) AS avg_days_to_annual_plan --calculate the differenc in days between the strat of the trial and the start of the annual plan
FROM customers_with_annual_plan ap
LEFT JOIN customers_start_date sd -- use a left join because we need information only for customers who upgraded to the annual plan
ON ap.customer_id = sd.customer_id;
````

#### Steps:
- Created a temporaty table (CTE) ```customers_with_annual_plan```, which includes the start date of the annual plan for each customer on that plan.
- Created a temporaty table (CTE) ```customers_start_date```, which includes the start date of the trial for each customer.
- Joined the temporary table ```customers_with_annual_plan``` and ```customers_start_date``` using a ```LEFT JOIN ``` clause because I need information only for customers who upgraded to the annual plan.
- Calculate the difference in days between the start of the trial and the start of the annual plan using ```DATEDIFF(day, start_trial, start_annual_plan)``` and applied the ```AVG()``` function on the results.


#### Result:
| avg_days_to_annual_plan |
| ----------------------- |
| 104                     |

On average, customers need three months to upgrade to the annual plan (exactly 104 days). However, it is important to note that the average is not always the best statistic. Question 10 will provide more insight into customer behavior.

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc).

````sql
WITH customers_with_annual_plan AS ( -- for each customer on annual plan, select the start date of this plan
	SELECT 
		customer_id,
		MIN(start_date) AS start_annual_plan
	FROM subscriptions
	WHERE plan_id = 3
	GROUP BY customer_id),

customers_start_date AS( -- for each customer, select the start date of the trial
	SELECT 
		customer_id,
		MIN(start_date) AS start_trial
	FROM subscriptions
	WHERE plan_id = 0
	GROUP BY customer_id
	),

customer_with_split_groups AS (
	SELECT 
		ap.customer_id,
		DATEDIFF(day, sd.start_trial, ap.start_annual_plan) AS days_to_annual_plan,
		FLOOR(DATEDIFF(day, sd.start_trial, ap.start_annual_plan)/30.0) AS group_id 
	FROM customers_with_annual_plan ap
	LEFT JOIN customers_start_date sd  -- use a left join because we need information only for customers who upgraded to the annual plan
	ON ap.customer_id = sd.customer_id)

SELECT 
	CONCAT(
		CASE group_id 
			WHEN 0 THEN 0
			ELSE (group_id  * 30) +1
		END,
		' - ', 
		(group_id +1) * 30) AS group_name_days,
	COUNT(*) AS number_of_customers
FROM customer_with_split_groups
GROUP BY group_id;
````

#### Steps:
- As in Question 9, I created a temporary table (CTE) ```customers_with_annual_plan``` and ```customers_start_date```.
- Created a temporary table ```customer_with_split_groups``` based on the data about customers who upgraded to the annual plan. The table includes the following information about each customer:
	- ```days_to_annual_plan``` - number of days needed to upgrade, 
	- ```grup_id``` - whole number representing the divided number of days needed to upgrade by 30
- Grouped the data from ```customer_with_split_groups``` by ```group_id``` and base on ```group_id``` added a name for each grupe.

````sql
-- group_name_days

CONCAT(
	CASE group_id 
		WHEN 0 THEN 0
		ELSE (group_id  * 30) +1
	END,
	' - ', 
	(group_id +1) * 30)
````

#### Result:
![Zrzut ekranu 2024-10-02 154736](https://github.com/user-attachments/assets/fdfc0be5-f5b0-4b5e-90ae-0230e0f8f5e8)


Most of the customers (95%) who upgraded to the annual plan did so within 210 days (7 months) of starting the trial. One in five customers with an annual plan upgraded in the first 30 days.

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
WITH plan_change_histories AS (
SELECT 
	customer_id,
	STRING_AGG (plan_id, ',') WITHIN GROUP (ORDER BY start_date ASC) AS plan_change_history
FROM subscriptions
WHERE YEAR(start_date) < 2021
GROUP BY customer_id
)

SELECT 
	CHARINDEX('2,1', plan_change_history) AS downgraded_from_2_to_1,
	COUNT(*) As number_of_customers
FROM plan_change_histories
WHERE CHARINDEX('2,1', plan_change_history) != 0
GROUP BY CHARINDEX('2,1', plan_change_history);
```

#### Result:
None of the clients of Foodie-Fi downgraded from a Pro Monthly to a Basic Monthly plan in 2020.
