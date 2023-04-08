##################### Pizza Metrics #####################
-- 1) How many pizzas were ordered?
SELECT 
    COUNT(order_id) AS OrderedPizzas
FROM
    customer_orders;
/*
############ Answer ############
In total, 14 pizzas were ordered.
############ Answer ############
*/

-- 2) How many unique customer orders were made?
SELECT 
	COUNT(DISTINCT order_id) as OrdersMade
FROM 
	runner_orders;
/*
############ Answer ############
In total, there were 10 unique orders
############ Answer ############
*/

-- 3) How many successful orders were delivered by each runner?
SELECT 
	runner_id,
    COUNT(order_id) AS SuccessfulOrders
FROM
    runner_orders
WHERE
	cancellation IS NULL
GROUP BY
	runner_id
ORDER BY
	runner_id;
/*
############ Answer ############
runner_id 1 placed 4 successful orders
runner_id 2 placed 3 successful orders
runner_id 3 placed 1 successful orders
############ Answer ############
*/

-- 4) How many of each type of pizza was delivered?
SELECT 
    pizza_names.pizza_name,
	COUNT(customer_orders.order_id) as DeliveredPizza
FROM
    customer_orders
		LEFT JOIN
	pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id
		LEFT JOIN
	runner_orders ON customer_orders.order_id = runner_orders.order_id
WHERE 
	runner_orders.cancellation IS NULL
GROUP BY 
	pizza_names.pizza_name;
/*
############ Answer ############
9 Meatlovers were delivered
3 Vegetarian were delivered
############ Answer ############
*/

-- 5) How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    customer_orders.customer_id,
    pizza_names.pizza_name,
    COUNT(pizza_names.pizza_name) Orders
FROM
    customer_orders
		LEFT JOIN
	pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY
	customer_orders.customer_id, pizza_names.pizza_name
ORDER BY 
	customer_id, pizza_name;
/*
############ Answer ############
The customer_id 101 received 2 Meatlovers and 1 Vegetarian
The customer_id 102 received 2 Meatlovers and 1 Vegetarian
The customer_id 103 received 3 Meatlovers and 1 Vegetarian
The customer_id 104 received 3 Meatlovers
The customer_id 105 received 1 Vegetarian
############ Answer ############
*/

-- 6)  What was the maximum number of pizzas delivered in a single order?
SELECT 
	customer_orders.customer_id,
    customer_orders.order_id,
    COUNT(customer_orders.pizza_id) AS Pizzas
FROM
    customer_orders
		LEFT JOIN
	runner_orders ON customer_orders.order_id = runner_orders.order_id
WHERE
	runner_orders. cancellation IS NULL
GROUP BY
	customer_orders.order_id,
    customer_orders.customer_id
ORDER BY 
	Pizzas desc
LIMIT 1;
/*
############ Answer ############
Maximum pizzas delivered in one order was 3 pizzas, for customer_id 103 (order 4)
############ Answer ############
*/

-- 7) For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- 7.1) Orders that had at least 1 change
SELECT 
    customer_id,
    COUNT(pizza_id) ChangedOrders
FROM
    customer_orders
WHERE
	exclusions IS NOT NULL OR  extras IS NOT NULL
group by customer_id;
/*
############ Answer ############
The customer_id 103 had 4 orders changed
The customer_id 104 had 2 orders changed
The customer_id 105 had 1 orders changed

############ Answer ############
*/

-- 7.2) Orders that had no changes
SELECT 
    customer_id,
    COUNT(pizza_id) NoChangedOrders
FROM
    customer_orders
WHERE
	exclusions IS NULL OR extras IS NULL
group by 
	customer_id;
/*
############ Answer ############
The customer_id 101 had 3 orders not changed
The customer_id 102 had 3 orders not changed
The customer_id 103 had 3 orders not changed
The customer_id 104 had 2 orders not changed
The customer_id 105 had 1 order not changed
############ Answer ############
*/

-- 8) How many pizzas were delivered that had both exclusions and extras?
SELECT 
    pizza_names.pizza_name,
    COUNT(customer_orders.pizza_id) NumberOfPizzas
FROM
    customer_orders
		LEFT JOIN
	pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id
WHERE
	exclusions IS NOT NULL AND extras IS NOT NULL
GROUP BY pizza_names.pizza_name;
/*
############ Answer ############
Total of 2 pizzas were delivered that had changes for both exclusion and extras. Both were meatlovers.
############ Answer ############
*/

-- 9) What was the total volume of pizzas ordered for each hour of the day?
SELECT 
	HOUR(order_time) AS Hours,
	COUNT(order_id) AS NumbOrderedPizzas,
	ROUND(100 * 
			COUNT(order_id) / SUM( COUNT(order_id) 
            ) OVER(), 2) AS VolumeOrderedPizzas
FROM 
	customer_orders
GROUP BY 
	Hours
ORDER BY 
	Hours;
/*
############ Answer ############
Hours, NumbOrderedPizzas, VolumeOrderedPizzas
11	 		1 					7.14
13			3 					21.43
18	 		3 					21.43
19	 		1 					7.14
21	 		3 					21.43
23	 		3 					21.43
############ Answer ############
*/
    
-- 10) What was the volume of orders for each day of the week?
SELECT 
	DAYNAME(order_time) AS WeekDay,
	COUNT(order_id) AS OrderedPizzas,
	ROUND(100*
			COUNT(order_id) / SUM( COUNT(order_id)
            ) OVER(), 2) AS VolumeOrderedPizzas
FROM 
	customer_orders
GROUP BY 
	WeekDay
ORDER BY 
	OrderedPizzas DESC;
/*
############ Answer ############




############ Answer ############
*/