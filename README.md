# Pizza Runner

Analyzing Danny's Pizza Runner with MySQL. This is Case Study #2 of the [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-2/), a set of business questions answered in SQL over a small pizza-delivery dataset.

<img align="center" src=https://user-images.githubusercontent.com/111542025/230740791-e7daec80-24e3-4aa1-b12e-7cf34444069f.png>

## Introduction
Did you know that over 115 million kilograms of pizza is consumed daily worldwide? (Well, according to Wikipedia anyway.)

Danny was scrolling through his Instagram feed when something really caught his eye, "80s Retro Styling and Pizza Is The Future!"

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire, so he had one more idea to combine with it. He was going to Uberize it, and so Pizza Runner was launched.

Danny started by recruiting "runners" to deliver fresh pizza from Pizza Runner Headquarters (Danny's house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Business Problem
The dataset has six tables: orders placed by customers, orders dispatched to runners, runner signups, pizza names, pizza recipes, and the topping list. The challenge is to answer operational questions a real pizza business would ask: how many pizzas get delivered, which runners are fast and reliable, which ingredients customers add or remove, and how much money the business actually keeps after paying for delivery.

Data source: the data was provided by Danny in his [website](https://8weeksqlchallenge.com/case-study-2/).

The questions are broken up by area of focus:
* [Pizza Metrics](https://github.com/Caio-Felice-Cunha/PizzaRunner/blob/main/3%20-%20Pizza%20Metrics.sql)
* [Runner and Customer Experience](https://github.com/Caio-Felice-Cunha/PizzaRunner/blob/main/4%20-%20Runner%20and%20Customer%20Experience.sql)
* [Ingredient Optimisation](https://github.com/Caio-Felice-Cunha/PizzaRunner/blob/main/5%20-%20Ingredient%20Optimisation.sql)
* [Pricing and Ratings](https://github.com/Caio-Felice-Cunha/PizzaRunner/blob/main/6%20-%20Pricing%20and%20Ratings.sql)

## Requirements
* MySQL 8.0 or newer. The scripts use `JSON_TABLE`, `SUBSTRING_INDEX`, window functions, and CTEs, which need MySQL 8.
* The sample data is public and ships inside the scripts. No external download is needed.

## How to Run
Run the scripts in numbered order against a fresh MySQL 8 server:

1. `1 - Creating Tables - Query.sql` creates the `pizza_runner` schema and loads the sample data.
2. `2 - Cleaning and Preparing Tables.sql` normalizes the messy text fields (empty strings and the literal word "null" become real NULLs) and splits the recipe lists into a `new_pizza_recipes` lookup table.
3. Files `3` through `6` answer the case-study questions. Each query is followed by an answer block in a comment.

Example using the MySQL client:

```bash
mysql -u root -p < "1 - Creating Tables - Query.sql"
mysql -u root -p < "2 - Cleaning and Preparing Tables.sql"
mysql -u root -p pizza_runner < "3 - Pizza Metrics.sql"
```

## Solution Strategy
MySQL was used as the database management system. Answering the questions required:
* SELECT
* WHERE
* GROUP BY and ORDER BY
* Common table expressions (CTE)
* JOINs
* Window functions
* Data cleaning and labeling
* Date and time manipulation
* Subqueries

## Results
All numbers below come from the answer blocks in the SQL scripts. Several were corrected in this version (see Corrections).

* 14 pizzas were ordered across 10 unique orders. 12 were delivered: 9 Meatlovers and 3 Vegetarian (2 orders were cancelled).
* Successful delivery rate by runner: runner 1 = 100%, runner 2 = 75%, runner 3 = 50%.
* Average time to arrive at HQ for pickup: runner 1 = 15.33 min, runner 2 = 23.40 min, runner 3 = 10 min.
* Average speed: runner 1 = 45.5 km/h, runner 2 = 62.9 km/h, runner 3 = 40 km/h. The single fastest delivery was 93.6 km/h (order 8).
* Most commonly added extra: Bacon (4 times). Most common exclusion: Cheese (4 times).
* Larger orders take longer to prepare: about 10 minutes for a single pizza, 15 to 21 minutes for two, and 29 minutes for the one three-pizza order.
* Revenue at the base prices was $138 with no delivery fees. Adding a $1 charge per delivered extra brings it to $142. After paying runners $0.30 per km ($43.56), Pizza Runner keeps $94.44.

## Corrections
This version fixes several bugs in the original queries that produced wrong stated answers. The main ones:
* Several "delivered pizza" questions did not exclude cancelled orders. Pizza Metrics Q7 and Q8, and Pricing Q2, now join `runner_orders` and filter `cancellation IS NULL`.
* The schema script used the PostgreSQL `SET search_path` instead of MySQL `USE`, which aborted the script on MySQL. It now uses `USE pizza_runner;`.
* The runner-rating script dropped the wrong table name, so it was not re-runnable. Fixed.
* "Most common extra/exclusion" queries now `ORDER BY count DESC` before `LIMIT 1` instead of relying on row order.
* The prep-time question summed a per-order value once per pizza (reporting 87 minutes for a 29-minute order). It now takes the per-order value.

## Next Steps
* Solve the two remaining Ingredient Optimisation questions (the alphabetical "2x" ingredient list per order and the total quantity of each ingredient across delivered pizzas).
* Suggestions are welcome.

## Disclaimer
The case, the database, and the questions are authored by Danny in his [#8weeksqlchallenge](https://8weeksqlchallenge.com/). This is [Case Study #2 - Pizza Runner](https://8weeksqlchallenge.com/case-study-2/).
