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
 	1) If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
	- how much money has Pizza Runner made so far if there are no delivery fees?
*/
SELECT 
	SUM(
		CASE 
			WHEN customer_orders.pizza_id = 1 THEN 12
			ELSE 10
		END
	) AS total_revenue
FROM pizza_runner.customer_orders;


/*
	2) What if there was an additional $1 charge for any pizza extras? + Add cheese is $1 extra
*/
WITH cleaned_cte AS (
SELECT 
	customer_orders.order_id,
	customer_orders.customer_id,
	customer_orders.pizza_id,
	customer_orders.exclusions,
	CASE 
		WHEN customer_orders.extras LIKE '%4%' AND customer_orders.extras IS NOT NULL
		THEN CONCAT(customer_orders.extras, ',1')
		WHEN customer_orders.extras NOT LIKE '%4%' AND customer_orders.extras IS NOT NULL
		THEN CONCAT(customer_orders.extras, '')
		ELSE NULL
	END AS extras,
	customer_orders.order_time,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS original_row_number
FROM pizza_runner.customer_orders
WHERE EXISTS (
    SELECT 1 
	FROM pizza_runner.runner_orders
    WHERE customer_orders.order_id = runner_orders.order_id
      AND runner_orders.cancellation IS NULL
  )
)
SELECT 
	SUM(total_revenue) AS total_revenue
FROM
(
SELECT 
	SUM(
		CASE 
			WHEN cleaned_cte.pizza_id = 1 THEN 12
			ELSE 10
		END)+
		COALESCE(LEN(cleaned_cte.extras), 0) - 
		COALESCE((LEN(cleaned_cte.extras) - LEN(REPLACE(cleaned_cte.extras, ',', '')))/LEN(','), 0)-
		COALESCE((LEN(cleaned_cte.exclusions) - LEN(REPLACE(cleaned_cte.exclusions, ',', '')))/LEN(','), 0)
		AS total_revenue
FROM cleaned_cte
GROUP BY 
	cleaned_cte.extras, cleaned_cte.exclusions
) AS prep_cost;


/*
	3) The Pizza Runner team now wants to add an additional ratings system that 
	allows customers to rate their runner, how would you design an additional table 
	for this new dataset - generate a schema for this new table and insert your own 
	data for ratings for each successful customer order between 1 to 5.
*/
DROP TABLE IF EXISTS pizza_runner.ratings;
CREATE TABLE pizza_runner.ratings 
	(
	 order_id INT,
	 ratings INT
	);
INSERT INTO pizza_runner.ratings
SELECT 
	runner_orders.order_id,
	FLOOR(1 + 5 * RAND()) AS ratings
FROM pizza_runner.runner_orders
WHERE runner_orders.cancellation IS NULL
ORDER BY 1 ASC;

--Orders with order_id# 6 and 9 were cancelled


/*
	4) Using your newly generated table 
	- can you join all of the information together to form a table 
	which has the following information for successful deliveries? 
		+ customer_id 
		+ order_id 
		+ runner_id 
		+ rating 
		+ order_time 
		+ pickup_time 
		+ Time between order and pickup 
		+ Delivery duration 
		+ Average speed 
		+ Total number of pizzas
*/
WITH cte_adjusted_runner_orders AS (
SELECT
  t1.order_id,
  t1.runner_id,
  t2.order_time,
  t3.ratings,
  t1.pickup_time AS pickup_time,
  t2.duartion,
  t1.distance
FROM pizza_runner.runner_orders AS t1
INNER JOIN #fixed_date_cte AS t2
  ON t2.order_id = t1.order_id
LEFT JOIN pizza_runner.ratings AS t3
  ON t1.order_id = t3.order_id
WHERE t1.pickup_time IS NOT NULL
)
SELECT
  t1.order_id,
  t1.runner_id,
  t1.ratings,
  t1.order_time,
  t1.pickup_time,
  DATEPART(MINUTE, (t1.pickup_time-t1.order_time)) AS pickup_minutes,
 CAST(ROUND((t1.distance/(t1.duartion))*60, 2) AS DECIMAL(5, 1)) AS avg_speed,
 COUNT(t2.pizza_id) AS pizza_count
FROM cte_adjusted_runner_orders AS t1
INNER JOIN pizza_runner.customer_orders AS t2
	ON t1.order_id = t2.order_id
GROUP BY
  t1.order_id,
  t1.runner_id,
  t1.ratings,
  t1.order_time,
  t1.pickup_time,
  DATEPART(MINUTE, (t1.pickup_time-t1.order_time)),
  (t1.distance/(t1.duartion))*60
ORDER BY 1 ASC;

SELECT * FROM pizza_runner.customer_orders

/*
	5) If a Meat Lovers pizza was $12 and Vegetarian $10 
	fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
	- how much money does Pizza Runner have left over after these deliveries?
*/
WITH cte_adjusted_runner_orders AS (
SELECT
  t1.order_id,
  t1.runner_id,
  t2.order_time,
  t3.ratings,
  t1.pickup_time,
  t1.duration,
  t1.distance,
  SUM(CASE WHEN t2.pizza_id = 1 THEN 1 ELSE 0 END) AS meatlovers_count,
  SUM(CASE WHEN t2.pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian_count
FROM pizza_runner.runner_orders AS t1
INNER JOIN pizza_runner.customer_orders AS t2
  ON t1.order_id = t2.order_id
LEFT JOIN pizza_runner.ratings AS t3
  ON t1.order_id = t3.order_id
WHERE t1.pickup_time IS NOT NULL 
GROUP BY
  t1.order_id,
  t1.runner_id,
  t3.ratings,
  t2.order_time,
  t1.pickup_time,
  t1.duration,
  t1.distance
)
SELECT
  SUM(
    ((12 * meatlovers_count) + (10 * vegetarian_count))
	- 0.3 * distance
  ) AS leftover_revenue
FROM cte_adjusted_runner_orders;