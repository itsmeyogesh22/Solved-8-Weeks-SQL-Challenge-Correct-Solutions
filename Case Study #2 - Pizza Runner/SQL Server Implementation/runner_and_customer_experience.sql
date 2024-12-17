USE [8 Weeks SQL Challenge];


DROP TABLE IF EXISTS #fixed_date_cte;
CREATE TABLE #fixed_date_cte 
	(
	runner_id INT,
	order_id INT,
	pickup_time_24_hr_format TIME,
	pickup_time_12_hr_format TIME,
	duartion INT,
	order_time DATETIME,
	order_time_24_hr_format TIME,
	order_time_12_hr_format TIME
	);
WITH delivery_info AS (
SELECT 
	DISTINCT
	runner_id,
	order_id,
	pickup_time_24_hr_format,
	TIMEFROMPARTS(hours_fixed, minutes_fixed, seconds_fixed, 0, 0) AS pickup_time_12_hr_format,
	duration
FROM
(
SELECT 
	runner_id,
	order_id,
	pickup_time AS pickup_date,
	CAST(pickup_time AS TIME) AS pickup_time_24_hr_format,
	(CASE 
		WHEN DATEPART(HOUR, pickup_time) > 12 
		THEN DATEPART(HOUR, pickup_time) - 12
		WHEN DATEPART(HOUR, pickup_time) = 0 THEN 12
	ELSE DATEPART(HOUR, pickup_time)
	END) AS hours_fixed,
	DATEPART(MINUTE, pickup_time) AS minutes_fixed,
	DATEPART(SECOND, pickup_time) AS seconds_fixed,
	runner_orders.duration
FROM pizza_runner.runner_orders 
) AS V1
)
INSERT INTO #fixed_date_cte 
	(
	runner_id,
	order_id,
	pickup_time_24_hr_format,
	pickup_time_12_hr_format,
	duartion,
	order_time,
	order_time_24_hr_format,
	order_time_12_hr_format
	)
SELECT 
	DISTINCT
	delivery_info.*,
	customer_orders.order_time,
	CAST(customer_orders.order_time AS TIME) AS order_time_24_hr_format,
	TIMEFROMPARTS(
		(CASE 
		WHEN DATEPART(HOUR, customer_orders.order_time) > 12 
		THEN DATEPART(HOUR, customer_orders.order_time) - 12
		WHEN DATEPART(HOUR, customer_orders.order_time) = 0 THEN 12
	ELSE DATEPART(HOUR, customer_orders.order_time)
	END),
	DATEPART(MINUTE, customer_orders.order_time),
	DATEPART(SECOND, customer_orders.order_time), 
	0, 
	0
	) AS order_time_12_hr_format
FROM delivery_info
INNER JOIN pizza_runner.customer_orders
	ON delivery_info.order_id = customer_orders.order_id;



/*
	1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
*/
--Good remark by Danny: DATE_TRUNC function with a week input automatically 
--takes the start of the week as the Monday date 
SELECT
  DATEADD(DAY, -2, DATETRUNC(WEEK, DATEADD(DAY, 4, registration_date))) AS registration_week,
  COUNT(*) AS runners
FROM pizza_runner.runners
GROUP BY DATEADD(DAY, -2, DATETRUNC(WEEK, DATEADD(DAY, 4, registration_date)))
ORDER BY registration_week;



/*
	2) What was the average time in minutes it took for each 
	runner to arrive at the Pizza Runner HQ to pickup the order?
*/
SELECT 
	AVG(DATEPART(MINUTE, DATEADD(MINUTE, -(DATEPART(MINUTE, order_time_12_hr_format)), pickup_time_12_hr_format))) AS avg_pickup_minutes
FROM #fixed_date_cte
WHERE pickup_time_12_hr_format IS NOT NULL


--Actual answer was an average of 15.625 minutes, 
--which if rounded up, gets close to 16 
SELECT CEILING(15.625);



/*
	3) Is there any relationship between the number of pizzas and how 
	long the order takes to prepare?
*/
SELECT 
	customer_orders.order_id,
	ROUND(AVG(DATEPART(MINUTE, runner_orders.pickup_time - customer_orders.order_time)), 2)
	AS time_taken,
	COUNT(customer_orders.pizza_id) AS total_items
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
	ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY customer_orders.order_id
ORDER BY 3;



/*
	4) What was the average distance travelled for each customer?
*/
SELECT 
	customer_orders.customer_id,
	CEILING(
	CAST(
		AVG(runner_orders.distance) AS
	DECIMAL(5, 2))) AS avg_distance_covered
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
	ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL 
GROUP BY customer_orders.customer_id;



/*
	5) What was the difference between the longest and shortest 
	delivery times for all orders?
*/
SELECT 
	MAX(distance_covered.duration) -
	MIN(distance_covered.duration) AS max_difference
FROM
(
SELECT 
	customer_orders.order_id,
	runner_orders.duration
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
	ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
) AS distance_covered;


/*
	6) What was the average speed for each runner for each 
	delivery and do you notice any trend for these values?
*/
SELECT 
	runner_orders.runner_id,
	runner_orders.order_id,
	DATEPART(HOUR, #fixed_date_cte.pickup_time_24_hr_format) AS day_hours,
	runner_orders.distance AS distance_km,
	runner_orders.duration AS duration_minutes,
	CAST(ROUND((runner_orders.distance/(#fixed_date_cte.duartion))*60, 2) AS DECIMAL(5, 1)) AS avg_speed
FROM #fixed_date_cte
INNER JOIN pizza_runner.runner_orders
	ON #fixed_date_cte.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL;



/*
	7) What is the successful delivery percentage for each runner?
*/
SELECT 
	runner_orders.runner_id,
	ROUND(100*(COUNT(DISTINCT runner_orders.pickup_time))/
	(SUM(
		CASE 
			WHEN runner_orders.pickup_time IS NOT NULL 
			THEN 0 ELSE 1 
		END
	) + COUNT(DISTINCT runner_orders.pickup_time)),
	2) AS delivery_ratio
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
	ON customer_orders.order_id = runner_orders.order_id
GROUP BY runner_orders.runner_id;