USE [8 Weeks SQL Challenge];

/*
	If Danny wants to expand his range of pizzas 
	- how would this impact the existing data design? 
	  Write an INSERT statement to demonstrate what 
	  would happen if a new Supreme pizza with all the 
	  toppings was added to the Pizza Runner menu?
*/
DROP TABLE IF EXISTS #updated_menu;
CREATE TABLE #updated_menu
	(
	pizza_id INT,
	pizza_name TEXT,
	toppings TEXT
	);
INSERT INTO #updated_menu
	(
	pizza_id,
	pizza_name,
	toppings
	)
SELECT 
	pizza_recipes.pizza_id,
	pizza_names.pizza_name,
	pizza_recipes.toppings
FROM pizza_runner.pizza_recipes
INNER JOIN pizza_runner.pizza_names
	ON pizza_recipes.pizza_id = pizza_names.pizza_id;


INSERT INTO #updated_menu
SELECT TOP 1
	3 AS pizza_id,
	'Supreme' AS pizza_name,
	CONCAT(
		pizza_recipes.toppings, 
		', ',
		LEAD(pizza_recipes.toppings) 
			OVER (
				ORDER BY pizza_recipes.pizza_id
				)) AS toppings
FROM pizza_runner.pizza_recipes;


DROP TABLE IF EXISTS pizza_runner.updates_pizza_menu;
CREATE TABLE pizza_runner.updates_pizza_menu 
	(
	pizza_id INT,
	pizza_name TEXT,
	ingredients TEXT
	);

WITH split_toppings_cte AS (
SELECT 
	#updated_menu.pizza_id,
	#updated_menu.pizza_name,
	CAST(TRIM(V1.value) AS INT) AS topping_id
FROM #updated_menu
CROSS APPLY STRING_SPLIT(CAST(#updated_menu.toppings AS VARCHAR), ',') AS V1
),
topping_maping AS (
SELECT 
	split_toppings_cte.pizza_id,
	split_toppings_cte.pizza_name,
	pizza_toppings.topping_name,
	split_toppings_cte.topping_id
FROM split_toppings_cte
INNER JOIN pizza_runner.pizza_toppings
	ON split_toppings_cte.topping_id = pizza_toppings.topping_id
),
toppings_qty AS (
SELECT
	topping_maping.pizza_id,
	CAST(topping_maping.pizza_name AS NVARCHAR(100)) AS pizza_name,
	CAST(topping_maping.topping_name AS NVARCHAR(100)) AS topping_name ,
	COUNT(topping_maping.topping_id) AS qty
FROM topping_maping
GROUP BY 
	topping_maping.pizza_id,
	CAST(topping_maping.pizza_name AS NVARCHAR(100)),
	CAST(topping_maping.topping_name AS NVARCHAR(100))
),
final_cte AS (
SELECT 
	toppings_qty.pizza_id,
	toppings_qty.pizza_name,
	CASE 
		WHEN toppings_qty.qty > 1 
		THEN CONCAT(toppings_qty.qty, 'X ', toppings_qty.topping_name)
		ELSE toppings_qty.topping_name
	END AS ingredients
FROM toppings_qty
)
INSERT INTO pizza_runner.updates_pizza_menu
	(
	pizza_id,
	pizza_name,
	ingredients
	)
SELECT 
	final_cte.pizza_id,
	final_cte.pizza_name,
	STRING_AGG(final_cte.ingredients, ', ') AS ingredients
FROM final_cte
GROUP BY 	
	final_cte.pizza_id,
	final_cte.pizza_name;


SELECT * 
FROM pizza_runner.updates_pizza_menu;