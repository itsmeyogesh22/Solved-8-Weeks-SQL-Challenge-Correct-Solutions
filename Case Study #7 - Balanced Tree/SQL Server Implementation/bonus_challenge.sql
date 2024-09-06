USE [8 Weeks SQL Challenge];


/*
	Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.
*/
--Method-1: Using INNER JOINS
SELECT 
	product_prices.product_id,
	product_prices.price,
	CONCAT_WS(
	' - ',
	CONCAT(product_hierarchy.level_text, ' ', T2.level_text),
	T3.level_text
	) AS product_name,
	T3.id AS category_id,
	T2.id AS segment_id,
	product_hierarchy.id AS style_id,
	T3.level_text AS category_name,
	T2.level_text AS segement_name,
	product_hierarchy.level_text AS style_name
FROM balanced_tree.product_hierarchy
INNER JOIN balanced_tree.product_hierarchy AS T2
	ON product_hierarchy.parent_id = T2.id
INNER JOIN balanced_tree.product_hierarchy AS T3
	ON T2.parent_id = T3.id
INNER JOIN balanced_tree.product_prices
	ON  product_prices.id = product_hierarchy.id;


--Method-2: Using Recursive CTE's
WITH output_table
(id, category_id, segment_id, style_id, category_name, segment_name, style_name)
AS (

  SELECT 
    id,
    id  AS category_id,
    CAST(NULL AS INT) AS segment_id,
    CAST(NULL AS INT) AS style_id,
    level_text AS category_name,
    CAST(NULL AS VARCHAR(MAX)) AS segment_name,
    CAST(NULL AS VARCHAR(MAX)) AS style_name
  FROM balanced_tree.product_hierarchy
  WHERE parent_id IS NULL

  UNION ALL

  SELECT
    product_hierarchy.id,
    output_table.category_id,
    CASE
      WHEN output_table.segment_id IS NULL
      THEN product_hierarchy.id
      ELSE output_table.segment_id
      END AS segment_id,
    CASE
      WHEN output_table.segment_id != product_hierarchy.id
      THEN product_hierarchy.id
      ELSE output_table.style_id
      END AS style_id,
    output_table.category_name,
    CASE
      WHEN output_table.segment_id IS NULL
      THEN product_hierarchy.level_text
      ELSE output_table.segment_name 
      END AS segment_name,
    CASE
      WHEN output_table.id != product_hierarchy.id
      THEN product_hierarchy.level_text
      ELSE output_table.style_name
      END AS style_name
  FROM output_table
  INNER JOIN balanced_tree.product_hierarchy
    ON output_table.id = product_hierarchy.parent_id
    AND product_hierarchy.parent_id IS NOT NULL
)
SELECT 
  product_prices.product_id,
  product_prices.price,
  CONCAT_WS(' - ', CONCAT(style_name, ' ', segment_name), category_name) AS product_name,
  category_id,
  segment_id,
  style_id,
  category_name,
  segment_name,
  style_name
FROM output_table
INNER JOIN balanced_tree.product_prices
  ON output_table.id = product_prices.id
WHERE style_name IS NOT NULL
OPTION (MAXRECURSION 360);