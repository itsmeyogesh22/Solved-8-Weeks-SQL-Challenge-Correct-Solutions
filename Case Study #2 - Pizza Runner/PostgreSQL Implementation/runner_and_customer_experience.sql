/*
	We need to format the Date time values,
	in "customer_orders" and "runer_orders" tables to 12 hour format.
	Since, Postgres SQL does implicitly casts to 24 hour time format, unlike
	MS SQL Server.

	To implement this, we need to create a temprory view.
*/
DROP VIEW IF EXISTS fixed_date_cte;
CREATE TEMP VIEW fixed_date_cte AS
WITH delivery_info AS (
SELECT 
	DISTINCT
	runner_id,
	order_id,
	pickup_time_24_hr_format,
	MAKE_TIME(hours_fixed, minutes_fixed, seconds_fixed) AS pickup_time_12_hr_format
FROM
(
SELECT 
	runner_id,
	order_id,
	pickup_time AS pickup_date,
	CAST(pickup_time AS TIME) AS pickup_time_24_hr_format,
	(CASE 
		WHEN DATE_PART('HOUR', pickup_time)::INT > 12 
		THEN DATE_PART('HOUR', pickup_time)::INT - 12
		WHEN DATE_PART('HOUR', pickup_time)::INT = 0 THEN 12
	ELSE DATE_PART('HOUR', pickup_time)::INT
	END) AS hours_fixed,
	DATE_PART('MINUTE', pickup_time)::INT AS minutes_fixed,
	DATE_PART('SECOND', pickup_time)::INT AS seconds_fixed
FROM pizza_runner.runner_orders 
ORDER BY 1
) AS V1
)
SELECT 
	DISTINCT
	delivery_info.*,
	mv_customer_orders.order_time,
	CAST(mv_customer_orders.order_time AS TIME) AS order_time_24_hr_format,
	MAKE_TIME(
		(CASE 
		WHEN DATE_PART('HOUR', mv_customer_orders.order_time)::INT > 12 
		THEN DATE_PART('HOUR', mv_customer_orders.order_time)::INT - 12
		WHEN DATE_PART('HOUR', mv_customer_orders.order_time)::INT = 0 THEN 12
	ELSE DATE_PART('HOUR', mv_customer_orders.order_time)::INT
	END),
	DATE_PART('MINUTE', mv_customer_orders.order_time)::INT,
	DATE_PART('SECOND', mv_customer_orders.order_time)::INT
	) AS order_time_12_hr_format
FROM delivery_info
INNER JOIN pizza_runner.mv_customer_orders
	ON delivery_info.order_id = mv_customer_orders.order_id;



/*
	1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
*/
--Good remark by Danny: DATE_TRUNC function with a week input automatically 
--takes the start of the week as the Monday date 
SELECT
  (
	DATE_TRUNC('WEEK', registration_date) + 
	INTERVAL '4 DAYS'
	)::DATE AS registration_week,
  COUNT(*) AS runners
FROM pizza_runner.runners
GROUP BY registration_week
ORDER BY registration_week;


/*
	2) What was the average time in minutes it took for each 
	runner to arrive at the Pizza Runner HQ to pickup the order?
*/
SELECT 
	AVG(DATE_PART('MINUTE', (pickup_time_12_hr_format - order_time_12_hr_format))) AS avg_pickup_minutes
FROM fixed_date_cte
WHERE pickup_time_12_hr_format IS NOT NULL



--Actual answer was an average of 15.625 minutes, 
--which if rounded up, gets close to 16 
SELECT CEILING(15.625);


/*
	3) Is there any relationship between the number of pizzas and how 
	long the order takes to prepare?
*/
SELECT 
	mv_customer_orders.order_id,
	AVG(DATE_PART('MINUTE', (fixed_date_cte.pickup_time_12_hr_format - fixed_date_cte.order_time_12_hr_format))) AS pickup_minutes,
	COUNT(mv_customer_orders.pizza_id) AS pizza_count
FROM pizza_runner.mv_customer_orders
INNER JOIN fixed_date_cte
	ON mv_customer_orders.order_id = fixed_date_cte.order_id
WHERE fixed_date_cte.pickup_time_12_hr_format IS NOT NULL
GROUP BY 1
ORDER BY 3;




/*
	4) What was the average distance travelled for each customer?
*/
SELECT 
	V4.customer_id,
	ROUND(AVG(V4.distance)::NUMERIC, 2) AS avg_distance_covered
FROM
(
SELECT 
	DISTINCT
	mv_customer_orders.customer_id,
	mv_customer_orders.order_id,
	runner_orders.distance
FROM pizza_runner.mv_customer_orders
INNER JOIN pizza_runner.runner_orders
	ON mv_customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL AND runner_orders.distance IS NOT NULL
ORDER BY 1
) AS V4
GROUP BY 1
ORDER BY 1;



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
	mv_customer_orders.order_id,
	CASE 
		WHEN DATE_PART('HOUR', mv_customer_orders.order_time) > 22 THEN 0 
		ELSE DATE_PART('HOUR', mv_customer_orders.order_time) 
	END AS day_hours,
	runner_orders.distance AS distance_km,
	runner_orders.duration AS duration_minutes,
	ROUND(
		AVG(runner_orders.distance/
		(runner_orders.duration/6))*10 
	)AS avg_speed
FROM pizza_runner.mv_customer_orders
INNER JOIN pizza_runner.runner_orders
	ON mv_customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY 
	runner_orders.runner_id,
	mv_customer_orders.order_id,
	3,
	runner_orders.distance,
	runner_orders.duration
ORDER BY 2;


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
	) + COUNT(DISTINCT runner_orders.pickup_time)::NUMERIC),
	2) AS delivery_ratio
FROM pizza_runner.mv_customer_orders
INNER JOIN pizza_runner.runner_orders
	ON mv_customer_orders.order_id = runner_orders.order_id
GROUP BY 1;