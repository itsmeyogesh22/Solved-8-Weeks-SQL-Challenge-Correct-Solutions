UPDATE pizza_runner.customer_orders
SET exclusions = NULL
WHERE customer_orders.exclusions = 'null';

UPDATE pizza_runner.customer_orders
SET extras = NULL
WHERE customer_orders.extras = 'null';


UPDATE pizza_runner.runner_orders
SET pickup_time = NULL
WHERE runner_orders.pickup_time = 'null';

UPDATE pizza_runner.runner_orders
SET cancellation = NULL
WHERE runner_orders.cancellation = 'null';

UPDATE pizza_runner.runner_orders
SET cancellation = NULL
WHERE runner_orders.cancellation = '';


UPDATE pizza_runner.runner_orders
SET duration = NULL
WHERE runner_orders.duration = 'null';

UPDATE pizza_runner.runner_orders
SET duration = SUBSTRING(duration, 
							0, 
							(CASE 
								WHEN POSITION('min' IN duration) = 0 
								THEN LENGTH(duration)+1
								ELSE POSITION('min' IN duration)
							END)); 

ALTER TABLE pizza_runner.runner_orders
	ALTER COLUMN duration TYPE NUMERIC USING duration::NUMERIC;


UPDATE pizza_runner.runner_orders
SET distance = NULL
WHERE runner_orders.distance = 'null';

UPDATE pizza_runner.runner_orders
SET distance = SUBSTRING(distance, 
							0, 
							(CASE 
								WHEN POSITION('km' IN distance) = 0 
								THEN LENGTH(distance)+1 ELSE POSITION('km' IN distance)
							END));


ALTER TABLE pizza_runner.runner_orders
	ALTER COLUMN distance TYPE NUMERIC USING distance::NUMERIC;


ALTER TABLE pizza_runner.runner_orders
	ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time::TIMESTAMP;

SELECT *
FROM pizza_runner.runner_orders;

SELECT *
FROM pizza_runner.customer_orders;