##################### Runner and Customer Experience ##################### 
-- 1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- WEEK() uses Sunday-based calendar weeks, which splits the Jan 1 and Jan 3 signups
-- into different buckets. The question defines the week as a 7-day period from 2021-01-01,
-- so we bucket by 7-day offset from that anchor instead.
SELECT
	FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) + 1 AS Weeks,
    COUNT(runner_id) Registrations
FROM
    runners
GROUP BY
	Weeks
ORDER BY
	Weeks;
/*
############ Answer ############
Weeks, Registrations
1 			2
2 			1
3			1
(Week 1 = Jan 1 to Jan 7 gets both the Jan 1 and Jan 3 signups.)
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
-- Prep time is a single value per order (order_time to pickup_time). Because customer_orders
-- has one row per pizza, SUM() would add the same prep time once per pizza and inflate it.
-- We use MAX() (all pizza rows in an order share the same prep time) to get the true per-order value.
SELECT
	customer_orders.order_id,
    COUNT(customer_orders.pizza_id) NumberOfPizzas,
    MAX(TIMESTAMPDIFF(MINUTE, customer_orders.order_time, runner_orders.pickup_time)) as PrepareTime_min
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
order_id, NumberOfPizzas, PrepareTime_min
4			3				29
3			2				21
10			2				15
1			1				10
2			1				10
5			1				10
7			1				10
8			1				20
There is a relationship: larger orders take longer to prepare.
Single-pizza orders take about 10 minutes (order 8 is an outlier at 20).
Two-pizza orders take roughly 15 to 21 minutes, and the one three-pizza order took 29 minutes.
The previous claim of 87 minutes for 3 pizzas was a bug: it summed the single 29-minute prep
time once per pizza (29 x 3 = 87), not real elapsed time.
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