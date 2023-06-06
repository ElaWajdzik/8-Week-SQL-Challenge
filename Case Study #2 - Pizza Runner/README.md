I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #2: 🍕 Pizza Runner
<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" alt="Image Danny's Diner - the taste of success" height="400">

## Introduction
Did you know that over **115 million kilograms** of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Available Data
Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

All datasets exist within the ```pizza_runner``` database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

## Relationship Diagram


***

## Case Study Questions
This case study includes questions about:
- Pizza Metrics
- Runner and Customer Experience
- Ingredient Optimisation
- Pricing and Ratings
- Bonus DML Challenges (DML = Data Manipulation Language)

### Cleaning data 
Sytax SQL is in the file "0. pizza_runner cleaning".


First of all, I cleaned and fixed the data in tables ```customer_orders``` and ```runner_orders```. 

In the table ```customer_orders``` was a problem only with the values **null** and **NULL**. Using the clause **CASE** I replace these two problematic values. I do this operation for the columns ```exclusions``` and ```extras```.


Part of the syntax with the clause **CASE**:

````sql
CASE
    WHEN exclusions LIKE 'null' OR exclusions IS NULL THEN ''
    ELSE exclusions
END AS exclusions,  
````

In the table ```runner_orders``` there were some problems:
- column ```cancellation``` had a problem with the values **null** and **NULL**,
- columns ```distance``` and ```duration``` had a problem with the value **null**, with the extra text in the data and with the type of data,
- column ```pickup_time``` had a problem with the value **null** and with the type of data.

To fix this problem, first I use clauses **CASE** and **TRIM** to change some wrong data. Second, I use the clause **MODIFY COLUMN** to change the type of data in some columns.


Part of the syntax with clauses **CASE**mand **TRIM**:

````sql
CASE 
    WHEN duration like 'null' THEN NULL
    WHEN duration like '%minute' THEN TRIM('minute' FROM duration)
    WHEN duration like '%minutes' THEN TRIM('minutes' FROM duration)
    WHEN duration like '%mins' THEN TRIM('mins' FROM duration)
    ELSE duration
END AS duration,
````

Part of the syntax with the clause **MODIFY COLUMN**:

````sql
ALTER TABLE runner_orders_temp
MODIFY COLUMN duration INT NULL;
````

Column ```duration``` - For this column I chose the type of data **INT** because this column contains information about the duration of delivery in minutes.
Column ```distance``` - For this column, I chose the type of data **FLOAT** because this column contains information about the distance of delivery in kilometers with one number after the decimol point.
Column ```pickup_time``` - For this column I chose the type of data **TIMESTAMP** because this column contains exact time of pick up (data with hour).


A. Pizza Metrics
 
B. Runner and Customer Experience
 
C. Ingredient Optimisation

D. Pricing and Ratings
