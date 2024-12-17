USE [8 Weeks SQL Challenge];

UPDATE pizza_runner.customer_orders
SET exclusions = NULL
WHERE customer_orders.exclusions = '';

SELECT * FROM pizza_runner.customer_orders

UPDATE pizza_runner.customer_orders
SET extras = NULL
WHERE customer_orders.extras = '';

SELECT DISTINCT * FROM pizza_runner.customer_orders ORDER BY 1


UPDATE pizza_runner.runner_orders
SET pickup_time = NULL
WHERE runner_orders.pickup_time = 'null';

UPDATE pizza_runner.runner_orders
SET cancellation = NULL
WHERE runner_orders.cancellation IS NULL;


UPDATE pizza_runner.runner_orders
SET cancellation = NULL
WHERE runner_orders.cancellation LIKE '';


UPDATE pizza_runner.runner_orders
SET cancellation = NULL
WHERE runner_orders.cancellation = 'null';


UPDATE pizza_runner.runner_orders
SET distance = NULL
WHERE runner_orders.distance = '';


UPDATE pizza_runner.runner_orders
SET duration = NULL
WHERE runner_orders.duration = 'null';


UPDATE pizza_runner.runner_orders
SET distance = NULL
WHERE runner_orders.distance = 'null';


UPDATE pizza_runner.runner_orders
SET duration = SUBSTRING(duration, 
							0, 
							(CASE 
								WHEN CHARINDEX('min', duration) = 0 
								THEN LEN(duration)+1
								ELSE CHARINDEX('min', duration)
							END)); 

ALTER TABLE pizza_runner.runner_orders
	ALTER COLUMN duration INT;


UPDATE pizza_runner.runner_orders
SET distance = SUBSTRING(distance, 
							0, 
							(CASE 
								WHEN CHARINDEX('km', distance) = 0 
								THEN LEN(distance)+1 ELSE CHARINDEX('km', distance)
							END));


ALTER TABLE pizza_runner.runner_orders
	ALTER COLUMN distance DECIMAL(10, 2);


ALTER TABLE pizza_runner.runner_orders
	ALTER COLUMN pickup_time DATETIME;


SELECT * FROM  pizza_runner.runner_orders