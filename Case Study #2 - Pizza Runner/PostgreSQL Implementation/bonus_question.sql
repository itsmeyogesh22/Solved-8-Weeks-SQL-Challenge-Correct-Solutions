/*
	If Danny wants to expand his range of pizzas 
	- how would this impact the existing data design? 
		Write an INSERT statement to demonstrate what 
		would happen if a new Supreme pizza with all the 
		toppings was added to the Pizza Runner menu?
*/

DROP TABLE IF EXISTS updated_menu;
CREATE TEMP TABLE updated_menu AS
SELECT 
	pizza_recipes.pizza_id,
	pizza_names.pizza_name,
	pizza_recipes.toppings
FROM pizza_runner.pizza_recipes
INNER JOIN pizza_runner.pizza_names
	ON pizza_recipes.pizza_id = pizza_names.pizza_id;

INSERT INTO updated_menu
	SELECT 
		3 AS pizza_id,
		'Supreme' AS pizza_name,
		CONCAT(
			pizza_recipes.toppings, 
			', ',
			LEAD(pizza_recipes.toppings) 
				OVER (
					ORDER BY pizza_recipes.pizza_id
				)) AS toppings
	FROM pizza_runner.pizza_recipes
	LIMIT 1;

DROP TABLE IF EXISTS pizza_runner.updates_pizza_menu;
CREATE TABLE pizza_runner.updates_pizza_menu 
	(
	pizza_id INT,
	pizza_name TEXT,
	ingredients TEXT
	);
INSERT INTO pizza_runner.updates_pizza_menu
WITH split_toppings_cte AS (
SELECT 
	updated_menu.pizza_id,
	updated_menu.pizza_name,
	REGEXP_SPLIT_TO_TABLE(updated_menu.toppings, ', ')::INT AS topping_id
FROM updated_menu
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
	topping_maping.pizza_name,
	topping_maping.topping_name,
	COUNT(topping_maping.topping_id) AS qty
FROM topping_maping
GROUP BY 
	topping_maping.pizza_id,
	topping_maping.pizza_name,
	topping_maping.topping_name
),
final_cte AS (
SELECT 
	toppings_qty.pizza_id,
	toppings_qty.pizza_name,
	CASE 
		WHEN toppings_qty.qty > 1 
		THEN toppings_qty.qty || 'X ' || toppings_qty.topping_name
		ELSE toppings_qty.topping_name
	END AS ingredients
FROM toppings_qty
)
SELECT 
	final_cte.pizza_id,
	final_cte.pizza_name,
	STRING_AGG(final_cte.ingredients, ', ' ORDER BY final_cte.ingredients ASC) AS ingredients
FROM final_cte
GROUP BY 	
	final_cte.pizza_id,
	final_cte.pizza_name;


SELECT * 
FROM pizza_runner.updates_pizza_menu;