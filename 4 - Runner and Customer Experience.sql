##################### Runner and Customer Experience ##################### 
-- 1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
	WEEK(registration_date) Weeks,
    COUNT(runner_id) Registrations
FROM
    runners
GROUP BY
	Weeks;
/*
############ Answer ############
Weeks, Registrations
0 			1
1 			2
2			1
############ Answer ############
*/

-- 2) What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
	runner_orders.runner_id,
	ROUND(
		AVG(
			TIMESTAMPDIFF(MINUTE, customer_orders.order_time, runner_orders.pickup_time)),
            2) AvgMinutes
FROM
    runner_orders
		LEFT JOIN
	customer_orders ON runner_orders.order_id = customer_orders.order_id
WHERE 
	TIMESTAMPDIFF(MINUTE, customer_orders.order_time, runner_orders.pickup_time) IS NOT NULL
GROUP BY
	runner_id;
/*
############ Answer ############
Average time for runner_id 1 is 15.33 minutes
Average time for runner_id 2 is 23.40 minutes
Average time for runner_id 3 is 10 minutes
############ Answer ############
*/

-- 3) Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT
	customer_orders.order_id,
    COUNT(customer_orders.pizza_id) NumberOfPizzas,
    SUM(TIMESTAMPDIFF(MINUTE, customer_orders.order_time, runner_orders.pickup_time)) as PrepareTime_min
FROM
	customer_orders
		INNER JOIN
	runner_orders ON customer_orders.order_id = runner_orders.order_id
GROUP BY
	customer_orders.order_id
HAVING
	PrepareTime_min IS NOT NULL
ORDER BY 
	NumberOfPizzas desc;
/*
############ Answer ############
We can see that there is a certain relationship between the number of pizzas and how long it takes for the order to be prepared.
It seems that the greater the number of pizzas per order, the longer it takes to prepare.
We see that to prepare a pizza, it takes 10 minutes, but for 2 pizzas it is not 20 minutes, but between 30 and 42 minutes. When there were 3 pizzas in one order, we have that the preparation time reaches 87 minutes.
############ Answer ############
*/

-- 4) What was the average distance travelled for each customer?
SELECT
	customer_orders.customer_id,
    ROUND(AVG(runner_orders.distance_km), 2) AS AvgDistance
FROM
	customer_orders
		INNER JOIN
	runner_orders ON customer_orders.order_id = runner_orders.order_id
WHERE
	runner_orders.distance_km IS NOT NULL
GROUP BY
	customer_orders.customer_id
ORDER BY
	customer_orders.customer_id;
/*
############ Answer ############
The average distance traveled by each customer is:
customer_id, AvgDistance
101				 20
102				 16.73
103 			 23.4
104 			 10
105 			 25
############ Answer ############
*/

-- 5) What was the difference between the longest and shortest delivery times for all orders?
SELECT
  MIN(duration_min) AS MinTimeDeliver_min,
  MAX(duration_min) AS MaxTimeDeliver_min,
   MAX(duration_min) - Min(duration_min) DeliverTimeDifference_min
FROM
  runner_orders;
/*
############ Answer ############
The difference is 30 minutes.
############ Answer ############
*/

-- 6) What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- 6.1) 
SELECT 
	order_id,
    runner_id,
    distance_km,
    duration_min,
    ROUND(distance_km * 60 / duration_min, 2) AS 'KM per Hour'
FROM
    runner_orders
WHERE
    cancellation IS NULL
ORDER BY 
	ROUND(distance_km * 60 / duration_min, 2) DESC;
/*
############ Answer ############
The average speed for each runner for each order is as follows:
order_id, runner_id, distance_km, duration_min, KM per Hour
8			2			23.4		   15			93.6
7			2			25			   25			60
10			1			10			   10			60
2			1			20			   27			44.44
3			1			13.4		   20			40.2
5			3			10			   15			40
1			1			20			   32			37.5
4			2			23.4		   40			35.1
############ Answer ############
*/   
    
SELECT 
    runner_id,
    AVG(ROUND(distance_km * 60 / duration_min, 2)) AS 'AVG KM per Hour'
FROM
    runner_orders
WHERE
    cancellation IS NULL
GROUP BY
	runner_id;
/*
############ Answer ############
The average speed for runner_id 1 is 45.535
The average speed for runner_id 2 is 62.9
The average speed for runner_id 3 is 40
############ Answer ############
*/

-- 7) What is the successful delivery percentage for each runner?
SELECT 
    runner_id,
    COUNT(pickup_time),
    COUNT(*) AS TotalOrders,
    CONCAT(ROUND(100 * COUNT(pickup_time) / COUNT(*)), '%') AS DeliverPercentage
FROM
    runner_orders
GROUP BY 
	runner_id
ORDER BY 
	runner_id;
/*
############ Answer ############
The successful delivery percentage for runner_id 1 is 100%
The successful delivery percentage for runner_id 2 is 75%
The successful delivery percentage for runner_id 3 is 50%
############ Answer ############
*/