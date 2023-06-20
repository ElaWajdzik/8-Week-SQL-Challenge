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

...tab
...plot

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

....
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





### 

```sql
```

#### Steps:
-

#### Result:
-

***
