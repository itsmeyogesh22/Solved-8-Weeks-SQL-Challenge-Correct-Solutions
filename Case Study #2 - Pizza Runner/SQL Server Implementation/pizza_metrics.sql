USE [8 Weeks SQL Challenge];

/*
	1) How many pizzas were ordered?
*/
SELECT COUNT(*)
FROM pizza_runner.customer_orders;


/*
	2) How many unique customer orders were made?

*/
SELECT 
	COUNT(DISTINCT customer_orders.order_id) 
FROM pizza_runner.customer_orders;

/*
	3) How many successful orders were delivered by each runner?
*/
SELECT 
	runner_orders.runner_id,
	COUNT(runner_orders.order_id)
FROM pizza_runner.runner_orders
WHERE runner_orders.cancellation IS NULL
GROUP BY runner_orders.runner_id;

/*
	4) How many of each type of pizza was delivered?
*/
SELECT 
	pizza_names.pizza_name,
	COUNT(runner_orders.order_id)
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
	ON customer_orders.order_id = runner_orders.order_id
INNER JOIN pizza_runner.pizza_names
	ON customer_orders.pizza_id = pizza_names.pizza_id
WHERE runner_orders.cancellation IS NULL
GROUP BY pizza_names.pizza_name;

/*
	5) How many Vegetarian and Meatlovers were ordered by each customer?
*/
SELECT 
	customer_orders.customer_id,
	SUM(CASE WHEN pizza_names.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS Vegetarian,
	SUM(CASE WHEN pizza_names.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS Meatlovers
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.pizza_names
	ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY customer_orders.customer_id
ORDER BY 1 ASC;


/*
	6) What was the maximum number of pizzas delivered in a single order?
*/
SELECT TOP 1
	customer_orders.customer_id,
	COUNT(DISTINCT customer_orders.order_id) AS orders_placed
FROM pizza_runner.customer_orders
GROUP BY customer_orders.customer_id
ORDER BY 2 DESC;


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
	customer_orders.customer_id,
	customer_orders.order_id,
	customer_orders.pizza_id,
	COUNT( customer_orders.exclusions) AS total_exclusions,
	COUNT( customer_orders.extras) AS total_extras
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
	ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY 
	customer_orders.customer_id,
	customer_orders.order_id, 
	customer_orders.pizza_id
) AS V1
GROUP BY customer_id;

/*
	8) How many pizzas were delivered that had both exclusions and extras?
*/
SELECT
	COUNT(DISTINCT runner_orders.order_id) AS total_orders
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
	ON customer_orders.order_id = runner_orders.order_id
WHERE 
	runner_orders.cancellation IS NULL  
	AND 
	customer_orders.exclusions IS NOT NULL 
	AND
	customer_orders.extras IS NOT NULL;

/*
Answer provided by Danny is different (Count: 2),
It is not clear how he got 2 since There are only
two orders with both 'Exclusions' and 'Extras', one of which,
i.e order number 9 was cancelled by customer.
However, I could be wrong here or I might have
missed something.
*/
--Query below returns Count: 2
SELECT
	COUNT(DISTINCT customer_orders.order_id) AS total_orders
FROM pizza_runner.customer_orders
WHERE 
	customer_orders.exclusions IS NOT NULL
	AND
	customer_orders.extras IS NOT NULL;

/*
	However, if we inspect pizza_runner.runner_orders table,
	we can observe out of two orders that were included in the 
	final result, one was cancelled by customer.
*/
SELECT *
FROM pizza_runner.runner_orders
WHERE runner_orders.order_id = 9;



/*
	9) What was the total volume of pizzas ordered for each hour of the day?
*/
SELECT 
	DATEPART(HOUR, CAST(customer_orders.order_time AS TIMESTAMP)) AS day_hours,
	COUNT(*) AS orders_placed
FROM pizza_runner.customer_orders
GROUP BY DATEPART(HOUR, CAST(customer_orders.order_time AS TIMESTAMP))
ORDER BY 1;


/*
	10) What was the volume of orders for each day of the week?
*/
SELECT 
	V1.days_of_week,
	SUM(V1.orders_placed) AS orders_placed
FROM 
(
SELECT 
	DATENAME(WEEKDAY, customer_orders.order_time) AS days_of_week,
	COUNT(*) AS orders_placed
FROM pizza_runner.customer_orders
GROUP BY customer_orders.order_time
) AS V1
GROUP BY V1.days_of_week;