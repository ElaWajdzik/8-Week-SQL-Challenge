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

## Case Study Questions

### Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of ``trial`` plan ``start_date`` values for our dataset - use the start of the month as the group by value
3. What plan ``start_date`` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each ``plan_name``
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 ``plan_name`` values at ``2020-12-31``?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

### Challenge Payment Question

### Outside The Box Questions


## Solution
Complete SQL code is available [here]()

***

### 1. How many customers has Foodie-Fi ever had?

```sql
SELECT 
    COUNT(DISTINCT customer_id) AS number_of_customers
FROM subscriptions;
```

#### Step:
- I used **COUNT DISTINCT** to calculate the number of unique ``customer_id``.

#### Result:
| number_of_customers |
| ------------------- |
| 1000                |


- Foodie-Fi had 1000 customers.

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
SELECT 
    MONTH(start_date) AS month_start,
    COUNT(customer_id) AS number_of_customers
FROM subscriptions
WHERE plan_id=0
GROUP BY month_start;
```

#### Steps:
- I extracted the month from the ``start_date`` using the function **MONTH**.
- I used **COUNT** to aggregate the number of customers in months.
- I used clause **WHERE** to take only data about the castomers in ``trial`` plan.

#### Result:

![CS3 - B2](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/05840a7f-567b-4a96-8d33-e484d391c148)

![plotCS3B02](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/487f890d-8366-457a-88ec-cc7781e73c2e)


- The average number of new customers in a month is around 80. The number of new customers on a trial plan is similar every month. The biggest difference between two months was 26 (mar - 94 and feb - 68), but the rest of the month's data is close to each other (between 75 and 89).

***

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

```sql
SELECT 
    YEAR(start_date) AS year_start,
    plan_name,
    COUNT(customer_id) AS number_of_customers
FROM subscriptions AS sub
JOIN plans
    ON plans.plan_id = sub.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY year_start, plan_name;
```

#### Steps:
- I used the function **YEAR()** to limit the data that came after 2020.
- I aggregated the data using **GROUP BY** in two data ``year_start`` and ``plan_name``.


#### Result:
- After 2020, no one starts the ``trial`` (``plan_id`` = 0). More than 1/3 of events in 2021 were churned (71 events ``churn``). In data are 8 events of the starting plan ``basic monthly``, 60 events of the starting plan ``pro monthly`` and 63 events of the starting plan ``pro annual``.

![CS3 - B3](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/beebc2a8-6a6f-46a6-a014-195bc3572d70)

***

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
SELECT
    COUNT(DISTINCT customer_id) AS number_of_churned,
    ROUND(COUNT(DISTINCT customer_id)/(
        SELECT
            COUNT(DISTINCT customer_id)
        FROM subscriptions
    )*100,1) AS pct_of_churned
FROM subscriptions
WHERE plan_id=4;
```

#### Steps:
- I used **COUNT DISTINCT** to count how many customers churned. In the data didn't exist case that someone after churned back to the subscription, it is not necessary to use **COUNT DISTINCT** the function **COUNT** will be enough.
- I calculated the percent of churned customers using the number of customers who churned and the total number of customers. Because the data are close, I know that the total number of customers is 1000, but in solving, I used a formula to count how many customers we have.


#### Result:
- In the data 307 customers churned, which means that churn is 30,7%.

| number_of_churned | pct_of_churned |
| ------------------|----------------|
| 307               | 30.7           |


***
### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?


```sql
WITH customers_plan AS (
SELECT 
    customer_id,
    GROUP_CONCAT(plan_id ORDER BY start_date) AS plan_path
FROM subscriptions
GROUP BY customer_id)

SELECT 
    COUNT(customer_id) AS number_of_customers_churn_after_trial,
    ROUND(COUNT(customer_id)/(
        SELECT
            COUNT(DISTINCT customer_id)
        FROM subscriptions
    )*100,0) AS pct_of_customers_churn_after_trial
FROM customers_plan
WHERE plan_path LIKE '%0,4%';
```

#### Steps:
- I created a temoraty table to create a column ``plan_path``, which includes the list of changed ``plan_id`` for each customer.
- I used clause **WHERE** and **LIKE** with **%** to calculate only the customers witch have in there ``plan_path`` 4 after 0 (``plan_id``= 4 it is churn, ``plan_id`` = 0 it is traial).

#### Result:
- In the data, there are **92** customers who churn straight after trial, which is **9%** of all customers.

| number_of_customers_churn_after_trial | pct_of_customers_churn_after_trial |
| --------------------------------------|------------------------------------|
| 92                                    | 9                                  |

***

### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
WITH plan_after_trial AS(
SELECT
    *,
    MIN(start_date) AS start_plan_after_trial
FROM subscriptions
WHERE plan_id!=0
GROUP BY customer_id
)

SELECT 
    plan_name,
    COUNT(customer_id) AS number_of_customers,
    ROUND(COUNT(customer_id)/10,1) AS pct_of_customers
FROM plan_after_trial 
JOIN plans
    ON plan_after_trial.plan_id = plans.plan_id
GROUP BY plan_name
ORDER BY COUNT(customer_id) DESC;
```

#### Steps:
- First, I created a temporary table that includes the data about the first change of plan (**MIN(start_date)**). Every customer starts a subscription from the trial, and they can't go back to the trial.
- Then I aggregated the data about ``plan_name`` every customer.

#### Result:
- The biggest group of customers go to the monthly plan (basic monthly 54,6% and pro monthly 32,5%). Only 14% of customers choose a different plan (churn 9,2% and pro annual 3,7%). More customers churn that go to the pro annual plan.
- Maybe in the future, it will be good to add ``basic annual`` plan.

![CS3 - B6](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/00d6ff22-68e5-43c1-8a97-c50b8fbdaf5d)


***

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
WITH plan_before_2021 AS (
SELECT 
    customer_id,
    MAX(start_date) AS start_last_plan_before_2021
FROM subscriptions
WHERE YEAR(start_date) < 2021
GROUP BY customer_id)

SELECT
    plan_name,
    COUNT(pb21.customer_id) AS number_of_customers,
    ROUND(COUNT(pb21.customer_id)/10,1) AS pct_of_customers
FROM plan_before_2021 AS pb21
JOIN subscriptions AS sub
    ON sub.customer_id = pb21.customer_id AND sub.start_date = pb21.start_last_plan_before_2021
JOIN plans
    ON sub.plan_id = plans.plan_id
GROUP BY plan_name
ORDER BY COUNT(pb21.customer_id) DESC; 
```

#### Steps:
- First, I created a temporary table with the last change of plan in 2020 (**WHERE YEAR(start_date) < 2021**) for every customer (**MAX(start_date)**).
- I joined the temporary tables with the information about the date of the last change plan with the ``subscriptions`` to know which plan they had.

#### Result:
- At 31.12.2020 almost 75% of all customers of Foodi-Fi were on a paid plan (exactly 74,5%). The more clients were ``pro monthly`` plan (32,6% of all customers). Almost one in four customers churned (23,6%).

![CS3 - B7](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/db4920c4-104c-4ac8-93c7-981b387b4c7f)


***

### 8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT
    COUNT(customer_id) AS number_of_customers
FROM subscriptions
WHERE plan_id = 3 AND YEAR(start_date) = 2020;
```

#### Steps:
- I used function **WHERE** with two conditionals to select the customers who upgrade to an annual plan in 2020.

#### Result:
- In 2020 **195** customers upgraded to an annual plan (that is 19,5% of customers).

| number_of_customers |
|---------------------|
| 195                 |

***

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
WITH customer_in_plan_3 AS (
SELECT
    customer_id,
    start_date AS upgrade_to_3
FROM subscriptions
WHERE plan_id = 3),
customers_start_date AS(
SELECT 
    customer_id,
    MIN(start_date) AS start_date
FROM subscriptions
GROUP BY customer_id)

SELECT 
    ROUND(AVG(DATEDIFF(c3.upgrade_to_3,csd.start_date)),0) AS avg_number_of_days_to_upgrade_to_3
FROM customer_in_plan_3 AS c3
JOIN customers_start_date AS csd
    ON c3.customer_id = csd.customer_id;
```

#### Steps:
-

#### Result:
-

| avg_number_of_days_to_upgrade_to_3 |
|------------------------------------|
| 105                                |

***



### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
WITH customer_in_plan_3 AS (
SELECT
    customer_id,
    start_date AS upgrade_to_3
FROM subscriptions
WHERE plan_id = 3),
customers_start_date AS(
SELECT 
    customer_id,
    MIN(start_date) AS start_date
FROM subscriptions
GROUP BY customer_id),
customers_in_category AS (
SELECT 
    c3.customer_id,
    TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0) AS category_id,
    CASE 
        WHEN TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0)*30 != 0 THEN TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0)*30+1
        ELSE TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0)*30 
    END AS start_category,
    TRUNCATE((DATEDIFF(c3.upgrade_to_3,csd.start_date)-1)/30,0)*30+30 AS end_category
FROM customer_in_plan_3 AS c3
JOIN customers_start_date AS csd
    ON c3.customer_id = csd.customer_id
GROUP BY c3.customer_id)

SELECT
    CONCAT(start_category,'-',end_category,' days') AS bucket,
    COUNT(customer_id) AS number_of_customers
FROM customers_in_category
GROUP BY category_id
ORDER BY category_id;
```

#### Steps:
-

#### Result:
-

![CS3 - B10](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/d9a395a7-cac2-4bb8-8e0d-93491321ed0e)

***