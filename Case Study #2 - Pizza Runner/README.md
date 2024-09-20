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

<img width="430" alt="graf2" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/b8c108d2-0bf9-40af-867a-ae307acbf921">


## Case Study Questions
This case study includes questions about:
- Pizza Metrics
- Runner and Customer Experience
- Ingredient Optimisation
- Pricing and Ratings
- Bonus DML Challenges (DML = Data Manipulation Language)

***

***

## Solution
Complete SQL code is available [here](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code).

**Thank you in advance for reading.** If you have any comments on my work, please let me know. My email address is ela.wajdzik@gmail.com.

Additionally, I am open to new work opportunities. If you are looking for someone with my skills (or know of someone who is), I would be grateful for any information.

***

## Data Cleaning Process 
The complete SQL syntax canbe found in the file [pizza_runner_MSSQL-cleaning](https://github.com/ElaWajdzik/8-Week-SQL-Challenge/edit/main/Case%20Study%20%232%20-%20Pizza%20Runner/SQL%20code/pizza_runner_MSSQL-cleaning.sql)

The existing data model has several issues that need to be addressed before performing any analysis. First, I remodeled the database from its old structure to a new one. The new model includes two additional tables: ```change_orders``` and ```change_types```. These tables contain information about ingredient changes and also help clean up data types in the existing tables.

Old Relationship Diagram
![the old relationship diagram!](/assets/images/san-juan-mountains.jpg "The old relationship diagram")

New Relationship Diagram After Remodeling
![the new relationship diagram!](/assets/images/san-juan-mountains.jpg "The new relationship diagram")

### 🔨 ```runner_orders```

1. Standardized the null values in ```pickup_time``` and ```cancellation``` columns.
2. Added two new numeric columns, distance_km and duration_min, and populated them with data from the distance and duration columns, excluding any text.

````sql

--add new columns
ALTER TABLE runner_orders
ADD 	distance_km NUMERIC(4,1),
	duration_min NUMERIC(3,0);

--insert the numeric values into the new column
UPDATE runner_orders
SET distance_km = CAST(
			CASE distance
				WHEN 'null' THEN NULL
				ELSE TRIM('km' FROM distance)
			END 
			AS NUMERIC(4,1));

--insert the numericvalues to the new column
UPDATE runner_orders
SET duration_min = CAST(
			TRIM('minutes' FROM 
				CASE duration WHEN 'null' THEN NULL ELSE duration END) 
			AS NUMERIC(3,0));

--delate the old columns
ALTER TABLE runner_orders
DROP COLUMN duration, distance;
````

After these stepes, the table changes from the old vesrion (left table) to the new version (right table).
![The table runners_orders!](/assets/images/san-juan-mountains.jpg "The table runners_orders")

### 🔨 ```pizza_recipes```

1. Created a new table containing ```pizza_id``` and ```topping_id```, as the old table had non-atomical values in the ```toppings``` column.
2. Inserted the data from old ```pizza_recipes``` table into the new one.

````sql
-- rename the old table
EXEC sp_rename 'pizza_recipes', 'pizza_recipes_temp';

-- create the new pizza_recipes table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
	id INT IDENTITY PRIMARY KEY NOT NULL,
	pizza_id INT,
	topping_id INT NOT NULL
);

-- insert data into the new table using the STRING_SPLIT() function
INSERT INTO pizza_recipes(pizza_id, topping_id)
SELECT 
	pizza_id, 
	TRIM(value) AS topping_id
FROM pizza_recipes_temp
	CROSS APPLY STRING_SPLIT(toppings, ',');
````

After these steps, the table changes from the old version (left table) to the new version (right table).
![The table runners_orders!](/assets/images/san-juan-mountains.jpg "The table runners_orders")

### 🔨 ```customer_orders```

1. Create two new tables: ```change_orders``` which include information about extras and exclusions, and ```change_types``` which defines the unique codes for extras and exclusions.
2. Creat a primary key in the ```customer_orders``` table to establish a relationship with the ```change_orders``` table.
3. Insert the data into the ```change_orders``` table.


````sql
--creat the change_types table and insert data
DROP TABLE IF EXISTS change_types;
CREATE TABLE change_types (
	change_type_id INT PRIMARY KEY,
	change_name VARCHAR(16) NOT NULL
);

INSERT INTO change_types
  (change_type_id, change_name)
VALUES
  (1, 'exclusion'),
  (2, 'extra');

--creat the change_orders table
DROP TABLE IF EXISTS change_orders;
CREATE TABLE change_orders (
  change_id INTEGER IDENTITY PRIMARY KEY,
  customer_order_id INTEGER NOT NULL,
  change_type_id INTEGER,
  topping_id INTEGER,
  CONSTRAINT change_orders_change_type_id_fk FOREIGN KEY (change_type_id) REFERENCES change_type(change_type_id),
  CONSTRAINT change_orders_topping_id_fk FOREIGN KEY (topping_id) REFERENCES pizza_toppings(topping_id),
);

--add the ID column to custumer_orders to build relationship with change_orders
ALTER TABLE customer_orders
ADD customer_order_id INT IDENTITY PRIMARY KEY NOT NULL;

--insert the data into change_orders for extras and exclusions
INSERT INTO change_orders(customer_order_id, topping_id, change_type_id)
SELECT 
	customer_order_id, 
	TRIM(value) AS topping_id,
	2 AS change_type_id
FROM customer_orders
	CROSS APPLY STRING_SPLIT(extras, ',');

INSERT INTO change_orders(customer_order_id, topping_id, change_type_id)
SELECT 
	customer_order_id, 
	TRIM(value) AS topping_id,
	1 AS change_type_id
FROM customer_orders
	CROSS APPLY STRING_SPLIT(exclusions, ',');
````

After these steps, the table changes from the old version (left table) to three new tables (right tables).
![The table runners_orders!](/assets/images/san-juan-mountains.jpg "The table runners_orders")

