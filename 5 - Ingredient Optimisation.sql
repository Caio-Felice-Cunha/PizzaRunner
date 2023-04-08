##################### Ingredient Optimisation ##################### 
-- 1) What are the standard ingredients for each pizza?
select 
    pizza_names.pizza_name,
    pizza_toppings.topping_name
FROM
	pizza_toppings
		JOIN
	new_pizza_recipes ON pizza_toppings.topping_id = new_pizza_recipes.topping_id
		JOIN
	pizza_names ON pizza_names.pizza_id = new_pizza_recipes.pizza_id
ORDER BY
	pizza_names.pizza_name;
/*
############ Answer ############
pizza_name, topping_name
Meatlovers		Bacon
Meatlovers		BBQ Sauce
Meatlovers		Beef
Meatlovers		Cheese
Meatlovers		Chicken
Meatlovers		Mushrooms
Meatlovers		Pepperoni
Meatlovers		Salami
Vegetarian		Cheese
Vegetarian		Mushrooms
Vegetarian		Onions
Vegetarian		Peppers
Vegetarian		Tomatoes
Vegetarian		Tomato Sauce
############ Answer ############
*/

-- 2) What was the most commonly added extra?
WITH count_extras AS (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(customer_orders.extras, ',', n), ',', -1)) AS topping_id,
        COUNT(*) AS count
    FROM
        customer_orders
			CROSS JOIN
        (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12) numbers
    WHERE
        n <= LENGTH(customer_orders.extras) - LENGTH(REPLACE(customer_orders.extras, ',', '')) + 1
    GROUP BY
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(customer_orders.extras, ',', n), ',', -1))
    ORDER BY
        topping_id
)
SELECT 
    count_extras.count,
    pizza_toppings.topping_name
FROM
    count_extras
		LEFT JOIN
	pizza_toppings USING(topping_id)
LIMIT 1;
/*
############ Answer ############
The most commonly added extra is bacon with 4 occurrences
############ Answer ############
*/

-- 3) What was the most common exclusion?
WITH exclusion_counts AS (
	SELECT
		TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(customer_orders.exclusions, ',', n), ',', -1)) AS topping_id,
		COUNT(*) as counts
	FROM
		customer_orders
			CROSS JOIN
		(SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12) AS numbers
		WHERE
			n <= LENGTH(customer_orders.exclusions) - LENGTH(REPLACE(customer_orders.exclusions, ',', '')) + 1
		GROUP BY
			TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(customer_orders.exclusions, ',', n), ',', -1))
)
SELECT 
    exclusion_counts.counts,
    pizza_toppings.topping_name
FROM
    exclusion_counts
		LEFT JOIN
	pizza_toppings USING(topping_id)
LIMIT 1;

/*
############ Answer ############
The most commonly exclusion is cheese with 4 occurrences
############ Answer ############
*/

-- 4) Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

SELECT 
    customer_orders.order_id,
    customer_orders.pizza_id,
    pizza_names.pizza_name,
    customer_orders.exclusions,
    customer_orders.extras,
    CASE
        WHEN
            customer_orders.pizza_id = 1
                AND (exclusions IS NULL OR exclusions = 0)
                AND (extras IS NULL OR extras = 0)
							THEN
								'Meat Lovers'
        WHEN
            customer_orders.pizza_id = 2
                AND (exclusions IS NULL OR exclusions = 0)
                AND (extras IS NULL OR extras = 0)
							THEN
								'Veg Lovers'
        WHEN
            customer_orders.pizza_id = 2
                AND (exclusions = 4)
                AND (extras IS NULL OR extras = 0)
							THEN
								'Veg Lovers - Exclude Cheese'
        WHEN
            customer_orders.pizza_id = 1
                AND (exclusions = 4)
                AND (extras IS NULL OR extras = 0)
							THEN
								'Meat Lovers - Exclude Cheese'
        WHEN
            customer_orders.pizza_id = 1
                AND (exclusions LIKE '%3%' OR exclusions = 3)
                AND (extras IS NULL OR extras = 0)
							THEN
								'Meat Lovers - Exclude Beef'
        WHEN
            customer_orders.pizza_id = 1
                AND (exclusions IS NULL OR exclusions = 0)
                AND (extras LIKE '%1%' OR extras = 1)
							THEN
								'Meat Lovers - Extra Bacon'
        WHEN
            customer_orders.pizza_id = 1
                AND (exclusions LIKE '1, 4')
                AND (extras LIKE '6, 9')
							THEN
								'Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'
        WHEN
            customer_orders.pizza_id = 1
                AND (exclusions LIKE '2, 6')
                AND (extras LIKE '1, 4')
							THEN
								'Meat Lovers - Exclude BBQ Sauce,Mushroom - Extra Bacon, Cheese'
        WHEN
            customer_orders.pizza_id = 1
                AND (exclusions = 4)
                AND (extras LIKE '1, 5')
							THEN
								'Meat Lovers - Exclude Cheese - Extra Bacon, Chicken'
    END AS OrderItem
FROM
    customer_orders
        INNER JOIN
    pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id;