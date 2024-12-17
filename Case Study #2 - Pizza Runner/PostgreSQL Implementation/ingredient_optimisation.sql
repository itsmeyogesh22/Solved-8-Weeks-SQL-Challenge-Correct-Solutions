/*
	1) What are the standard ingredients for each pizza?
*/
WITH cte_split_pizza_names AS (
SELECT 
	pizza_recipes.pizza_id,
	REGEXP_SPLIT_TO_TABLE(pizza_recipes.toppings, '[,\s]+ ')::INT 
	AS topping_id
FROM pizza_runner.pizza_recipes
) 
SELECT 
	cte_split_pizza_names.pizza_id,
	STRING_AGG(pizza_toppings.topping_name, ', ') AS standard_ingredients
FROM pizza_runner.pizza_toppings
INNER JOIN cte_split_pizza_names
	ON pizza_toppings.topping_id = cte_split_pizza_names.topping_id
GROUP BY 1
ORDER BY 1;


/*
	2) What was the most commonly added extra?
*/
WITH extras_cte AS (
SELECT 
	mv_customer_orders.order_id,
	REGEXP_SPLIT_TO_TABLE(mv_customer_orders.extras, '[,\s]+')::INT AS extras
FROM pizza_runner.mv_customer_orders
)
SELECT 
	pizza_toppings.topping_name,
	COUNT(*)
FROM extras_cte
INNER JOIN pizza_runner.pizza_toppings
	ON extras_cte.extras = pizza_toppings.topping_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


/*
	3) What was the most common exclusion?
*/
WITH exclusions_cte AS (
SELECT 
	mv_customer_orders.order_id, 
	REGEXP_SPLIT_TO_TABLE(mv_customer_orders.exclusions, '[,\s]+')::INT AS exclusions
FROM pizza_runner.mv_customer_orders
)
SELECT 
	pizza_toppings.topping_name,
	COUNT(*)
FROM exclusions_cte
INNER JOIN pizza_runner.pizza_toppings
	ON exclusions_cte.exclusions = pizza_toppings.topping_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


/*
	4) Generate an order item for each record in the customers_orders table in 
	the format of one of the following: + Meat Lovers + 
	Meat Lovers - Exclude Beef + Meat Lovers - Extra Bacon + 
	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
*/
WITH order_customs AS ( 
SELECT
	mv_customer_orders.order_id,
	mv_customer_orders.customer_id,
	mv_customer_orders.pizza_id,
	mv_customer_orders.order_time,
	pizza_names.pizza_name AS order_item, 
	REGEXP_SPLIT_TO_TABLE(mv_customer_orders.exclusions, '[,\s]+')::INT AS exclusions,
	REGEXP_SPLIT_TO_TABLE(mv_customer_orders.extras, '[,\s]+')::INT AS extras
FROM pizza_runner.mv_customer_orders
INNER JOIN pizza_runner.pizza_names
	ON mv_customer_orders.pizza_id = pizza_names.pizza_id
	WHERE mv_customer_orders.exclusions IS NOT NULL 
	OR
	mv_customer_orders.extras IS NOT NULL
),
excluded_toppings AS (
SELECT 
	V1.order_id,
	V1.customer_id,
	V1.pizza_id,
	V1.order_time,
	V1.order_item,
	CASE 
		WHEN V1.lead_exclusion IS NULL THEN V1.topping_name 
		ELSE CONCAT(V1.topping_name, ', ', V1.lead_exclusion)
	END AS exclusions
FROM
(
SELECT 
	order_customs.order_id,
	order_customs.customer_id,
	order_customs.pizza_id,
	order_customs.order_time,
	order_customs.order_item,
	order_customs.exclusions,
	pizza_toppings.topping_name,
	CASE 
		WHEN pizza_toppings.topping_name != LEAD(pizza_toppings.topping_name) OVER (PARTITION BY order_customs.customer_id ORDER BY (SELECT NULL))
		THEN LEAD(pizza_toppings.topping_name) OVER (PARTITION BY order_customs.customer_id ORDER BY (SELECT NULL))
		ELSE NULL
	END AS lead_exclusion,
	ROW_NUMBER() OVER (PARTITION BY order_customs.customer_id,order_customs.order_id, order_customs.order_item ORDER BY order_customs.order_id
	
	) AS rn
FROM order_customs
LEFT JOIN pizza_runner.pizza_toppings
	ON order_customs.exclusions = pizza_toppings.topping_id
) AS V1
WHERE V1.rn = 1
),
extra_toppings AS (
SELECT 
	 V2.order_id,
	 V2.customer_id,
	 V2.pizza_id,
	 V2.order_time,
	 V2.order_item,
	CASE 
		WHEN  V2. lead_extra IS NULL THEN  V2.topping_name 
		ELSE CONCAT( V2.topping_name, ', ',  V2. lead_extra)
	END AS  extras
FROM
(
SELECT 
	order_customs.order_id,
	order_customs.customer_id,
	order_customs.pizza_id,
	order_customs.order_time,
	order_customs.order_item,
	order_customs. extras,
	pizza_toppings.topping_name,
	CASE 
		WHEN pizza_toppings.topping_name != LEAD(pizza_toppings.topping_name) OVER (PARTITION BY order_customs.customer_id ORDER BY (SELECT NULL))
		THEN LEAD(pizza_toppings.topping_name) OVER (PARTITION BY order_customs.customer_id ORDER BY (SELECT NULL))
		ELSE NULL
	END AS  lead_extra,
	ROW_NUMBER() OVER (PARTITION BY order_customs.customer_id,order_customs.order_id, order_customs.order_item ORDER BY order_customs.order_id
	
	) AS rn
FROM order_customs
LEFT JOIN pizza_runner.pizza_toppings
	ON order_customs. extras = pizza_toppings.topping_id
) AS  V2
WHERE  V2.rn = 1
)
SELECT 
	V3.order_id,
	V3.customer_id,
	V3.pizza_id,
	V3.order_time,
	CASE 
		WHEN V3.exclusions IS NOT NULL AND V3.extras IS NULL 
		THEN CONCAT(V3.order_item, V3.exclusions) 
		WHEN V3.exclusions IS NULL AND V3.extras IS NOT NULL 
		THEN CONCAT(V3.order_item, V3.extras) 
		WHEN V3.exclusions IS NOT NULL AND V3.extras IS NOT NULL 
		THEN CONCAT(V3.order_item, V3.exclusions, V3.extras)
		ELSE V3.order_item
	END AS order_item
FROM
(
SELECT 
	extra_toppings.order_id,
	extra_toppings.customer_id,
	extra_toppings.pizza_id,
	extra_toppings.order_time,
	extra_toppings.order_item, 
	CASE WHEN excluded_toppings.exclusions IS NULL THEN NULL ELSE CONCAT(' - Exclude ', excluded_toppings.exclusions) END AS exclusions,
	CASE WHEN extra_toppings.extras IS NULL THEN NULL ELSE CONCAT(' - Extra ', extra_toppings.extras) END AS extras
FROM extra_toppings 
FULL JOIN excluded_toppings 
	ON extra_toppings.order_id = excluded_toppings.order_id
) AS V3
UNION
SELECT 
	mv_customer_orders.order_id,
	mv_customer_orders.customer_id,
	mv_customer_orders.pizza_id,
	mv_customer_orders.order_time,
	pizza_names.pizza_name AS order_item
FROM pizza_runner.mv_customer_orders
INNER JOIN pizza_runner.pizza_names
	ON mv_customer_orders.pizza_id = pizza_names.pizza_id
WHERE 
	mv_customer_orders.exclusions IS NULL
	AND
	mv_customer_orders.extras IS NULL
ORDER BY 1;


/*
	5) Generate an alphabetically ordered comma separated ingredient 
	list for each pizza order from the customer_orders table and add 
	a 2x in front of any relevant ingredients
	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
*/
DROP MATERIALIZED VIEW IF EXISTS pizza_runner.sorted_orders;
CREATE MATERIALIZED VIEW pizza_runner.sorted_orders AS
WITH cte_cleaned_customer_orders AS(
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY customer_id, order_id ORDER BY order_id DESC) AS original_row_number
FROM pizza_runner.mv_customer_orders
),
cte_regular_toppings AS (
SELECT 
	pizza_recipes.pizza_id,
	REGEXP_SPLIT_TO_TABLE(pizza_recipes.toppings, '[,\s]+')::INT AS topping_id
FROM pizza_runner.pizza_recipes
),
cte_base_toppings AS (
SELECT
    cte_cleaned_customer_orders.order_id,
    cte_cleaned_customer_orders.customer_id,
    cte_cleaned_customer_orders.pizza_id,
    cte_cleaned_customer_orders.order_time,
    cte_cleaned_customer_orders.original_row_number,
    cte_regular_toppings.topping_id
FROM cte_cleaned_customer_orders
LEFT JOIN cte_regular_toppings
	ON cte_cleaned_customer_orders.pizza_id = cte_regular_toppings.pizza_id
),
cte_exclusions AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE exclusions IS NOT NULL
),
cte_extras AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE extras IS NOT NULL
),
cte_combined_orders AS (
SELECT * FROM cte_base_toppings
EXCEPT
SELECT * FROM cte_exclusions
UNION ALL
SELECT * FROM cte_extras
),
cte_joined_toppings AS (
SELECT
  t1.order_id,
  t1.customer_id,
  t1.pizza_id,
  t1.order_time,
  t1.original_row_number,
  t1.topping_id,
  t2.pizza_name,
  t3.topping_name,
  COUNT(t1.*) AS topping_count 
FROM cte_combined_orders AS t1
INNER JOIN pizza_runner.pizza_names AS t2
  ON t1.pizza_id = t2.pizza_id
INNER JOIN pizza_runner.pizza_toppings AS t3
  ON t1.topping_id = t3.topping_id
GROUP BY
  t1.order_id,
  t1.customer_id,
  t1.pizza_id,
  t1.order_time,
  t1.original_row_number,
  t1.topping_id,
  t2.pizza_name,
  t3.topping_name
)
SELECT
  order_id,
  customer_id,
  pizza_id,
  order_time,
  original_row_number,
  pizza_name || ': ' || STRING_AGG(
    CASE
      WHEN topping_count > 1 THEN topping_count || 'x ' || topping_name
      ELSE topping_name
      END,
    ', ' ORDER BY topping_name
  ) AS ingredients_list
FROM cte_joined_toppings
GROUP BY
  original_row_number,
  order_id,
  customer_id,
  pizza_id,
  order_time,
  pizza_name
ORDER BY 1 ASC, 5 ASC;


SELECT 
	sorted_orders.order_id,
	sorted_orders.customer_id,
	sorted_orders.pizza_id,
	sorted_orders.order_time,
	ROW_NUMBER() OVER (ORDER BY sorted_orders.order_id, sorted_orders.pizza_id, sorted_orders.original_row_number DESC) AS original_row_number,
	sorted_orders.ingredients_list
FROM pizza_runner.sorted_orders;




/*
	6) What is the total quantity of each ingredient used
	in all delivered pizzas sorted by most frequent first?
*/
WITH cte_cleaned_customer_orders AS(
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_id) AS original_row_number 
FROM pizza_runner.mv_customer_orders
),
cte_regular_toppings AS (
SELECT 
	pizza_recipes.pizza_id,
	REGEXP_SPLIT_TO_TABLE(pizza_recipes.toppings, '[,\s]+')::INT AS topping_id
FROM pizza_runner.pizza_recipes
),
cte_base_toppings AS (
SELECT
    cte_cleaned_customer_orders.order_id,
    cte_cleaned_customer_orders.customer_id,
    cte_cleaned_customer_orders.pizza_id,
    cte_cleaned_customer_orders.order_time,
    cte_cleaned_customer_orders.original_row_number,
    cte_regular_toppings.topping_id
FROM cte_cleaned_customer_orders
LEFT JOIN cte_regular_toppings
	ON cte_cleaned_customer_orders.pizza_id = cte_regular_toppings.pizza_id
),
cte_exclusions AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE exclusions IS NOT NULL
),
cte_extras AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE extras IS NOT NULL
),
cte_combined_orders AS (
SELECT * FROM cte_base_toppings
EXCEPT
SELECT * FROM cte_exclusions
UNION ALL
SELECT * FROM cte_extras
)
SELECT 
	t2.topping_name,
	COUNT(t2.topping_id) AS qty
FROM cte_combined_orders AS t1
INNER JOIN pizza_runner.pizza_toppings AS t2
	ON t1.topping_id = t2.topping_id
GROUP BY 1
ORDER BY 2 DESC;