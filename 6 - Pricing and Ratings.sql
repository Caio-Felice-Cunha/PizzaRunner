##################### Pricing and Ratings ##################### 
-- 1) If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT
    SUM(CASE
		WHEN pizza_name = 'Meatlovers' THEN 12
        WHEN pizza_name = 'Vegetarian' THEN 10
        ELSE 0
        END) AS TotalMoney
FROM
    customer_orders
		LEFT JOIN
	runner_orders USING (order_id)
		LEFT JOIN
	pizza_names USING (pizza_id)
WHERE
	runner_orders.cancellation IS NULL;

/*
############ Answer ############
Pizza Runner made 138$ so far
############ Answer ############
*/

-- 2) What if there was an additional $1 charge for any pizza extras?
WITH IngredientsCount AS(
	SELECT 
		TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(customer_orders.extras, ',', n), ',', -1)) AS Toppings,
		COUNT(*) AS ExtraPrice
	FROM
		customer_orders
			CROSS JOIN
		(SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12) numbers
	WHERE
		n <= LENGTH(customer_orders.extras) - LENGTH(REPLACE(customer_orders.extras, ',', '')) + 1
	GROUP BY
		TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(customer_orders.extras, ',', n), ',', -1))
	ORDER BY
		Toppings)
SELECT 
    (SELECT SUM(IngredientsCount.ExtraPrice) FROM IngredientsCount) AS Extra,
    SUM(CASE
        WHEN pizza_name = 'Meatlovers' THEN 12
        WHEN pizza_name = 'Vegetarian' THEN 10
        ELSE 0
    END) AS TotalMoney,
    SUM(CASE
        WHEN pizza_name = 'Meatlovers' THEN 12
        WHEN pizza_name = 'Vegetarian' THEN 10
        ELSE 0
    END) + (SELECT SUM(IngredientsCount.ExtraPrice) FROM IngredientsCount) AS TotalMoneyExtra
FROM
    customer_orders
    LEFT JOIN
    runner_orders USING (order_id)
    LEFT JOIN
    pizza_names USING (pizza_id)
WHERE
    runner_orders.cancellation IS NULL;

/*
############ Answer ############
Pizza Runner made 138$ with the pizzas, and 6$ with extras. Total of 144$
############ Answer ############
*/

-- 3) The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS runner_rating;

CREATE TABLE runner_client_rating (
    order_id INTEGER,
    stars INTEGER,
    review VARCHAR(200)
);

INSERT INTO runner_client_rating
VALUES 	("1", "5", "Great! I love it"),
        ("2", "3", "The attendant was very kind"),
        ("3", "1", "Its too expensive and took a while to deliver"),
        ("4", "2","The service was good, but thats all. It takes time to deliver, then the pizza was cold" ),
        ("5", "4", "Very tasty"),
        ("7", "3", "I didnt like the service very much, but the pizza was very good"),
        ("8", "4", "Good pizza"),
        ("10", "2", NULL);


SELECT 
    *
FROM
    runner_client_rating;

-- 4) Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
/* customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas */
SELECT 
    customer_orders.customer_id,
    customer_orders.order_id,
    runner_orders.runner_id,
    runner_client_rating.stars,
    customer_orders.order_time,
    runner_orders.pickup_time,
    TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS TimePickUp,
    MAX(duration_min) AS TimeDelivery,
    ROUND(MAX(distance_km * 60 / duration_min), 2) AS SpeedAVG,
    COUNT(pizza_id) AS TotalPizzas
FROM
    customer_orders
        INNER JOIN
    runner_orders USING (order_id)
        INNER JOIN
    runner_client_rating USING (order_id)
GROUP BY 
	customer_orders.order_id, 
    customer_orders.customer_id, 
    runner_orders.runner_id, 
    runner_client_rating.stars, 
    customer_orders.order_time, 
    runner_orders.pickup_time;

-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
WITH OrderPrice AS(
	SELECT
		customer_orders.order_id,
		SUM(CASE
			WHEN customer_orders.pizza_id = 1 THEN 12
			WHEN customer_orders.pizza_id = 2 THEN 10
			ELSE 0
		END) AS OrderPrice
	FROM
		customer_orders
	GROUP BY
		customer_orders.order_id
)
SELECT
    CONCAT('$',SUM(OrderPrice)) AS TotalOrders,
    CONCAT('$',ROUND(SUM(runner_orders.distance_km) * 0.3, 2)) AS DeliveryFee,
    CONCAT('$',ROUND(SUM(OrderPrice) - (SUM(runner_orders.distance_km) * 0.3),2)) AS Total
FROM
    OrderPrice
		JOIN
	runner_orders USING(order_id)
WHERE
	runner_orders.cancellation IS NULL;
/*
############ Answer ############
TotalOrders, DeliveryFee, Total
$138		   $43.56	  $94.44
############ Answer ############
*/