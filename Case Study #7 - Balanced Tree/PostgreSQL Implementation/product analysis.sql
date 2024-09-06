/*
	1) What are the top 3 products by total revenue before discount?
*/
SELECT 
	V1.product_id,
	V1.product_name,
	SUM(V1.total_revenue) AS total_revenue
FROM
(
SELECT
  product_details.product_id,
  product_details.product_name,
  sales.qty * sales.price AS total_revenue
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
) AS V1
GROUP BY 
	V1.product_id,
	V1.product_name
ORDER BY 3 DESC 
LIMIT 3;


/*
	2) What is the total quantity, revenue and discount for each segment?
*/
SELECT
  product_details.segment_name,
  SUM(sales.qty) AS total_quantity,
  SUM(sales.qty * sales.price) AS total_revenue,
  ROUND(
    SUM(sales.qty * sales.price * sales.discount)::NUMERIC/100::NUMERIC,
    2
  ) AS total_discount
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY product_details.segment_name
ORDER BY total_revenue DESC;


/*
	3) What is the top selling product for each segment?
*/
WITH cte_ranked_segment_product_quantity AS (
SELECT
  product_details.segment_id,
  product_details.segment_name,
  product_details.product_id,
  product_details.product_name,
  SUM(sales.qty) AS product_quantity,
  RANK() OVER (
    PARTITION BY product_details.segment_id, product_details.segment_name
    ORDER BY SUM(sales.qty) DESC
  ) AS segment_quantity_rank
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY
  product_details.segment_id,
  product_details.segment_name,
  product_details.product_id,
  product_details.product_name
)
SELECT
  segment_id,
  segment_name,
  product_id,
  product_name,
  product_quantity
FROM cte_ranked_segment_product_quantity
WHERE segment_quantity_rank = 1
ORDER BY product_quantity DESC;


/*
	4) What is the total quantity, revenue and discount for each category?
*/
SELECT
  category_id,
  category_name,
  SUM(sales.qty) AS total_quantity,
  SUM(sales.qty * sales.price) AS total_revenue,
  ROUND(
    SUM(sales.qty * sales.price * sales.discount),
    2
  ) AS total_discount
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY   
	category_id,
	category_name
ORDER BY total_revenue DESC;


/*
	5) What is the top selling product for each category?
*/
WITH cte_ranked_category_product_quantity AS (
SELECT
	category_id,
	category_name,
	product_id,
	product_name,
	SUM(sales.qty) AS product_quantity
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
 GROUP BY 
 	category_id,
	category_name,
	product_id,
	product_name
)
SELECT *
FROM
(
SELECT 
	category_id,
	category_name,	
	product_id,
	product_name,
	product_quantity,
	RANK() OVER (PARTITION BY category_id ORDER BY product_quantity DESC) AS row_id
FROM cte_ranked_category_product_quantity  
) AS V5
WHERE V5.row_id = 1;


/*
	6) What is the percentage split of revenue by product for each segment?
*/
WITH cte_product_revenue AS (
  SELECT
    product_details.segment_id,
    product_details.segment_name,
    product_details.product_id,
    product_details.product_name,
    SUM(sales.qty * sales.price) AS product_revenue
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
	ON sales.prod_id = product_details.product_id
GROUP BY
	product_details.segment_id,
    product_details.segment_name,
    product_details.product_id,
    product_details.product_name
)
SELECT
  *,
  ROUND(
    100 * product_revenue /
      SUM(product_revenue) OVER (
        PARTITION BY segment_id
      ),
    2
  ) AS segment_product_percentage
FROM cte_product_revenue
ORDER BY segment_id, segment_product_percentage DESC;


/*
	7) What is the percentage split of revenue by segment for each category?
*/
WITH cte_product_revenue AS (
  SELECT
    product_details.category_id,
    product_details.category_name,

    SUM(sales.qty * sales.price)::NUMERIC AS product_revenue
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.category_id,
    product_details.category_name,
    product_details.segment_id,
    product_details.segment_name
)
SELECT
  *,
  ROUND(
	100*(product_revenue/
	(SUM(product_revenue) 
		OVER (
			PARTITION BY category_id
			))::NUMERIC)
	, 2)AS category_segment_percentage
FROM cte_product_revenue
ORDER BY category_id, category_segment_percentage DESC;


/*
	8) What is the percentage split of total revenue by category?
*/
WITH cte_category_revenue AS (
SELECT
    product_details.category_id,
    product_details.category_name,
    SUM(sales.qty * sales.price) AS category_revenue
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
GROUP BY
    product_details.category_id,
    product_details.category_name
)
SELECT
  *,
  ROUND(
    100 * category_revenue /
      SUM(category_revenue) OVER (),
    2
  ) AS category_revenue_percentage
FROM cte_category_revenue
ORDER BY category_id;


/*
	9) What is the total transaction “penetration” for each product? 
	(hint: penetration = number of transactions 
	where at least 1 quantity of a product was purchased divided by total number of transactions)
*/
WITH product_transactions AS (
SELECT DISTINCT
	prod_id,
	COUNT(DISTINCT txn_id) AS product_transactions
FROM balanced_tree.sales
GROUP BY prod_id
),
total_transactions AS (
SELECT
	COUNT(DISTINCT txn_id) AS total_transaction_count
FROM balanced_tree.sales
)
SELECT
  product_details.product_id,
  product_details.product_name,
  ROUND(
    100 * product_transactions.product_transactions::NUMERIC
      / total_transactions.total_transaction_count,
    2
  ) AS penetration_percentage
FROM product_transactions
CROSS JOIN total_transactions
INNER JOIN balanced_tree.product_details
  ON product_transactions.prod_id = product_details.product_id
ORDER BY penetration_percentage DESC;


/*
	10) What is the most common combination of at least 1 quantity of any 3 products in a 
	1 single transaction? Super bonus - what are the quantity, revenue, discount and net 
	revenue from the top 3 products in the transactions where all 3 were purchased?
*/
DROP TABLE IF EXISTS temp_product_combos;
CREATE TEMP TABLE temp_product_combos AS
WITH RECURSIVE input(product) AS (
SELECT product_id::TEXT 
FROM balanced_tree.product_details
),
output_table AS (
SELECT 
    ARRAY[product] AS combo,
    product,
	1 AS product_counter
FROM input
  
UNION 

SELECT
    ARRAY_APPEND(output_table.combo, input.product),
    input.product,
    product_counter + 1
FROM output_table 
INNER JOIN input ON input.product > output_table.product
WHERE output_table.product_counter <= 2
)
SELECT * from output_table
WHERE product_counter = 3;


WITH cte_transaction_products AS (
SELECT
    txn_id,
    ARRAY_AGG(prod_id::TEXT ORDER BY prod_id) AS products
FROM balanced_tree.sales
GROUP BY txn_id
),
cte_combo_transactions AS (
SELECT
    txn_id,
    combo,
    products
FROM cte_transaction_products
CROSS JOIN temp_product_combos
WHERE combo <@ products
),
cte_ranked_combos AS (
SELECT
    combo,
    COUNT(DISTINCT txn_id) AS transaction_count,
    RANK() OVER (ORDER BY COUNT(DISTINCT txn_id) DESC) AS combo_rank,
    ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT txn_id) DESC) AS combo_id
FROM cte_combo_transactions
GROUP BY combo
),
cte_most_common_combo_product_transactions AS (
SELECT
    cte_combo_transactions.txn_id,
    cte_ranked_combos.combo_id,
    UNNEST(cte_ranked_combos.combo) AS prod_id
FROM cte_combo_transactions
INNER JOIN cte_ranked_combos
	ON cte_combo_transactions.combo = cte_ranked_combos.combo
WHERE cte_ranked_combos.combo_rank = 1
)
SELECT
  product_details.product_id,
  product_details.product_name,
  COUNT(DISTINCT sales.txn_id) AS combo_transaction_count,
  SUM(sales.qty) AS quantity,
  SUM(sales.qty * sales.price) AS revenue,
  ROUND(
    SUM(sales.qty * sales.price * sales.discount)::NUMERIC/100::NUMERIC,
    2
  ) AS discount,
  ROUND(
    SUM(sales.qty * sales.price)-(SUM(sales.qty * sales.price * sales.discount)::NUMERIC/100::NUMERIC) ,
    2
  ) AS net_revenue
FROM balanced_tree.sales
INNER JOIN cte_most_common_combo_product_transactions AS top_combo
  ON sales.txn_id = top_combo.txn_id
  AND sales.prod_id = top_combo.prod_id
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY product_details.product_id, product_details.product_name;