I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# Case Study #5: 🛒 Data Market
<img src="https://8weeksqlchallenge.com/images/case-study-designs/5.png" alt="Image Data Mark - fresh is best" height="400">

## Introduction
Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business question he wants you to help him answer are the following:
- What was the quantifiable impact of the changes introduced in June 2020?
- Which platform, region, segment and customer types were the most impacted by this change?
- What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?


## Available Data
For this case study there is only a single table: ``weekly_sales``.

## Column Dictionary
The columns are pretty self-explanatory based on the column names but here are some further details about the dataset:
1. Data Mart has international operations using a multi-``region`` strategy
2. Data Mart has both, a retail and online ``platform`` in the form of a Shopify store front to serve their customers
3. Customer ``segment`` and ``customer_type`` data relates to personal age and demographics information that is shared with Data Mart
4. ``transactions`` is the count of unique purchases made through Data Mart and ``sales`` is the actual dollar amount of purchases

Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a ``week_date`` value which represents the start of the sales week.

## Question and Solution

I was using MySQL to solve the problem, if you are interested, the complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/8e02234c7889c6df67b043b60a833934f4257bd5/Case%20Study%20%234%20-%20Data%20Bank/SQL%20code).

**In advance, thank you for reading.** If you have any comments on my work, please let me know. My emali address is ela.wajdzik@gmail.com.




Introduction
