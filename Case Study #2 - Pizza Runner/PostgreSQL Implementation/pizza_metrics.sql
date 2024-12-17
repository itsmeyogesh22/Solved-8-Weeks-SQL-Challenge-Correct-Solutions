--Dropping non-unique records
DROP MATERIALIZED VIEW IF EXISTS pizza_runner.mv_customer_orders;
CREATE MATERIALIZED VIEW pizza_runner.mv_customer_orders AS 
SELECT 
	order_id,
	customer_id,
	pizza_id,
	exclusions,
	extras,
	order_time
FROM
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY order_id, customer_id, pizza_id, exclusions, extras ORDER BY order_id) AS row_id
FROM pizza_runner.customer_orders
) AS V1
WHERE row_id <= 2;




/*
	1) How many pizzas were ordered?
*/
SELECT COUNT(*)
FROM pizza_runner.mv_customer_orders;


/*
	2) How many unique customer orders were made?

*/
SELECT 
	COUNT(DISTINCT mv_customer_orders.order_id) 
FROM pizza_runner.mv_customer_orders;


/*
	3) How many successful orders were delivered by each runner?
*/
SELECT 
	runner_orders.runner_id,
	COUNT(runner_orders.order_id)
FROM pizza_runner.runner_orders
WHERE 
	runner_orders.cancellation IS NULL 
	OR 
	runner_orders.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY 1
ORDER BY 1;


/*
	4) How many of each type of pizza was delivered?
*/
SELECT 
	pizza_names.pizza_name,
	COUNT(runner_orders.order_id)
FROM pizza_runner.mv_customer_orders
INNER JOIN pizza_runner.runner_orders
	ON mv_customer_orders.order_id = runner_orders.order_id
INNER JOIN pizza_runner.pizza_names
	ON mv_customer_orders.pizza_id = pizza_names.pizza_id
WHERE 
	runner_orders.cancellation IS NULL 
	OR 
	runner_orders.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY 1;


/*
	5) How many Vegetarian and Meatlovers were ordered by each customer?
*/
SELECT 
	mv_customer_orders.customer_id,
	SUM(CASE WHEN pizza_names.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS Vegetarian,
	SUM(CASE WHEN pizza_names.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS Meatlovers
FROM pizza_runner.mv_customer_orders
INNER JOIN pizza_runner.pizza_names
	ON mv_customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY mv_customer_orders.customer_id
ORDER BY 1 ASC;


/*
	6) What was the maximum number of pizzas delivered in a single order?
*/
SELECT 
	mv_customer_orders.customer_id,
	COUNT(DISTINCT mv_customer_orders.order_id) AS orders_placed
FROM pizza_runner.mv_customer_orders
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


/*
	7) For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
*/
SELECT
	customer_id,
	SUM(
	CASE 
		WHEN total_exclusions = 0 AND total_extras = 0
		THEN 1 
		WHEN total_exclusions != 0 AND total_extras = 0
		THEN total_extras
		WHEN total_exclusions = 0 AND total_extras != 0
		THEN total_exclusions
		WHEN total_exclusions != 0 AND total_extras != 0
		THEN 1
	ELSE 0 
	END) AS no_changes,
	SUM(
	CASE 
		WHEN total_exclusions = 0 AND total_extras = 0
		THEN 0
		WHEN total_exclusions != 0 AND total_extras = 0
		THEN total_exclusions
		WHEN total_exclusions = 0 AND total_extras != 0
		THEN total_extras
		WHEN total_exclusions != 0 AND total_extras != 0
		THEN 1
	ELSE 0 
	END) AS atleast_1_change
FROM 
(
SELECT
	mv_customer_orders.customer_id,
	mv_customer_orders.order_id,
	mv_customer_orders.pizza_id,
	COUNT( mv_customer_orders.exclusions) AS total_exclusions,
	COUNT( mv_customer_orders.extras) AS total_extras
FROM pizza_runner.mv_customer_orders
INNER JOIN pizza_runner.runner_orders
	ON mv_customer_orders.order_id = runner_orders.order_id
WHERE 
	runner_orders.cancellation IS NULL 
	OR 
	runner_orders.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY 
	mv_customer_orders.customer_id,
	mv_customer_orders.order_id, 
	mv_customer_orders.pizza_id
) AS V1
GROUP BY 1
ORDER BY 1;


/*
	8) How many pizzas were delivered that had both exclusions and extras?
*/
SELECT
	COUNT(*) AS total_orders
FROM pizza_runner.mv_customer_orders
INNER JOIN pizza_runner.runner_orders
	ON mv_customer_orders.order_id = runner_orders.order_id
WHERE 
	runner_orders.cancellation IS NOT NULL  
	AND 
	mv_customer_orders.exclusions IS NOT NULL 
	AND
	mv_customer_orders.extras IS NOT NULL;

/*
Answer provided by Danny is different (Count: 2),
It is not clear how he got 2 since There are only
two orders with both 'Exclusions' and 'Extras', one of which,
i.e order number 9 was cancelled by customer.
However, I could be wrong here or I might have
missed something.
*/


/*
	9) What was the total volume of pizzas ordered for each hour of the day?
*/
SELECT 
	DATE_PART('HOUR', mv_customer_orders.order_time) AS day_hours,
	COUNT(*) AS orders_placed
FROM pizza_runner.mv_customer_orders
GROUP BY 1
ORDER BY 1;


/*
	10) What was the volume of orders for each day of the week?
*/
SELECT 
	TO_CHAR(mv_customer_orders.order_time, 'DAY') AS day_hours,
	COUNT(order_id) AS orders_placed
FROM pizza_runner.mv_customer_orders
GROUP BY 1, DATE_PART('DOW', mv_customer_orders.order_time)
ORDER BY DATE_PART('DOW', mv_customer_orders.order_time);