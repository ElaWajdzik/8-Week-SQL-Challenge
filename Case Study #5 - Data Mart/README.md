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

<img width="300" alt="graf1" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/2bc51de5-d45b-48d9-9e31-b1af2280ecd9">


## Column Dictionary
The columns are pretty self-explanatory based on the column names but here are some further details about the dataset:
1. Data Mart has international operations using a multi-``region`` strategy
2. Data Mart has both, a retail and online ``platform`` in the form of a Shopify store front to serve their customers
3. Customer ``segment`` and ``customer_type`` data relates to personal age and demographics information that is shared with Data Mart
4. ``transactions`` is the count of unique purchases made through Data Mart and ``sales`` is the actual dollar amount of purchases

Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a ``week_date`` value which represents the start of the sales week.

***
***

## Question and Solution

I was using MySQL to solve the problem, if you are interested, the complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/8e02234c7889c6df67b043b60a833934f4257bd5/Case%20Study%20%234%20-%20Data%20Bank/SQL%20code).

**In advance, thank you for reading.** If you have any comments on my work, please let me know. My emali address is ela.wajdzik@gmail.com.


***

### 1. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the ``data_mart`` schema named ``clean_weekly_sales``:
- Convert the ``week_date`` to a ``DATE`` format,
- Add a ``week_number`` as the second column for each ``week_date`` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc,
- Add a ``month_number`` with the calendar month for each ``week_date`` value as the 3rd column,
- Add a ``calendar_year`` column as the 4th column containing either 2018, 2019 or 2020 values,
- Add a new column called ``age_band`` after the original ``segment`` column using the following mapping on the number inside the ``segment`` value

    | segment | age_band     |
    |---------|--------------|
    | 1       | Young Adults |
    | 2       | Middle Aged  |
    | 3 or 4  | Retirees     |

- Add a new ``demographic`` column using the following mapping for the first letter in the ``segment`` values:

    | segment | demographic |
    |---------|-------------|
    | C       | Couples     |
    | F	      | Families    |

- Ensure all ``null`` string values with an ``"unknown"`` string value in the original ``segment`` column as well as the new ``age_band`` and ``demographic`` columns,
- Generate a new ``avg_transaction`` column as the ``sales`` value divided by ``transactions`` rounded to 2 decimal places for each record

```sql
CREATE TABLE clean_weekly_sales AS(
    SELECT
        new_week_date AS week_date,
        ROUND((DAYOFYEAR(new_week_date)-MOD(DAYOFYEAR(new_week_date)-1,7))/7+1,0) AS week_number,
        MONTH(new_week_date) AS month_number,
        YEAR(new_week_date) AS calendar_year,
        
        segment,

        CASE 
        WHEN segment LIKE '%1%' THEN 'Young Adults'
        WHEN segment LIKE '%2%' THEN 'Middle Aged'
        WHEN segment LIKE '%3%' OR segment LIKE '%4%'THEN 'Retirees'
        ELSE 'unknown'
        END AS age_band,

        CASE 
        WHEN segment LIKE '%C%' THEN 'Couples'
        WHEN segment LIKE '%F%' THEN 'Families'
        ELSE 'unknown'
        END AS demographic,

        region,
        platform,
        customer_type,
        ROUND(sales/transactions,2) AS avg_transaction,
        
        transactions,
        sales

    FROM (
        SELECT
            *,
            STR_TO_DATE(week_date,'%d/%m/%Y') AS new_week_date
        FROM weekly_sales) AS new_weekly_sales
);
```

#### Steps:

- I converted the ``week_data`` to a ``DATA`` format using the function **STR_TO_DATE(week_date,'%d/%m/%Y')**. I did it in inline view to could reference this data in update format.
- I created a column ``week_number``. Following the instraction, it isn't a number of weeks in calendar meaning (for standard meaning, the week starts on Monday or on Sunday) but for every year the first week should start on the 1st of January, no matter of the weekday. That's why I couldn't use the function **WEEK()**. To calculate it, I used functions **DAYOFYEAR()** and **MOD()**, exactly I used a combination of a few functions **ROUND((DAYOFYEAR(new_week_date)-MOD(DAYOFYEAR(new_week_date)-1,7))/7+1,0)**.
- I created columns ``month_number`` and ``calendar_year`` simply using the standard functions **MONTH()** and **YEAR()**.
- Using the data ``segment`` I created ``age_band`` like in the description. e.g. If ``segment`` contains ``1`` then ``age_band`` is equal to ``Young Adults``. Function **CASE** with conditional **WHEN segment LIKE '%1%' THEN 'Young Adults'**.
- Using the data ``segment`` I created ``demographic`` like in the description. e.g. If ``segment`` contains ``C`` then ``demographic`` is equal to ``Couples``. Function **CASE** with conditional **WHEN segment LIKE '%C%' THEN 'Couples'**.
- I created ``avg_transaction`` divided ``sales`` by ``transactions``.

#### Result

...

***

### 2. Data Exploration

#### 1. What day of the week is used for each ``week_date`` value?
#### 2. What range of week numbers are missing from the dataset?
#### 3. How many total transactions were there for each year in the dataset?
#### 4. What is the total sales for each region for each month?
#### 5. What is the total count of transactions for each platform
#### 6. What is the percentage of sales for Retail vs Shopify for each month?
#### 7. What is the percentage of sales by demographic for each year in the dataset?
#### 8. Which ``age_band`` and ``demographic`` values contribute the most to Retail sales?
#### 9. Can we use the ``avg_transaction`` column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

