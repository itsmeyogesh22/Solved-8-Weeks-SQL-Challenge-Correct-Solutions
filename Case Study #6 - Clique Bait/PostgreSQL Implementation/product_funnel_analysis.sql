/*
	Using a single SQL query - create a new output table which has the following details:
		
		1) How many times was each product viewed?
		2) How many times was each product added to cart?
		3) How many times was each product added to a cart but not purchased (abandoned)?
		4) How many times was each product purchased?

		+------------+----------+------------------+------------+-----------+-----------+-----------+
		| product_id | product  | product_category | page_views | cart_adds | abandoned | purchases |
		+------------+----------+------------------+------------+-----------+-----------+-----------+
		| 1          | Salmon   | Fish             | 1559       | 938       | 227       | 711       |
		| 2          | Kingfish | Fish             | 1559       | 920       | 213       | 707       |
		+------------+----------+------------------+------------+-----------+-----------+-----------+





	
	Additionally, create another table which further aggregates the data for the above points 
	but this time for each product category instead of individual products:

		+------------------+------------+-----------+-----------+-----------+
		| product_category | page_views | cart_adds | abandoned | purchases |
		+------------------+------------+-----------+-----------+-----------+
		| Fish             | 4633       | 2789      | 674       | 2115      |
		| Luxury           | 3032       | 1870      | 466       | 1404      |
		+------------------+------------+-----------+-----------+-----------+


*/

DROP TABLE IF EXISTS product_info;
CREATE TEMP TABLE product_info AS
WITH cte_product_page_events AS (
  SELECT
    events.visit_id,
    page_hierarchy.product_id,
    page_hierarchy.page_name,
    page_hierarchy.product_category,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS page_view,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_add
FROM clique_bait.events
INNER JOIN clique_bait.page_hierarchy
	ON events.page_id = page_hierarchy.page_id
WHERE page_hierarchy.product_id IS NOT NULL
GROUP BY
	events.visit_id,
    page_hierarchy.product_id,
    page_hierarchy.page_name,
    page_hierarchy.product_category
),
cte_visit_purchase AS (
SELECT DISTINCT
    visit_id
FROM clique_bait.events
WHERE event_type = 3  
),
cte_combined_product_events AS (
SELECT
    t1.visit_id,
    t1.product_id,
    t1.page_name,
    t1.product_category,
    t1.page_view,
    t1.cart_add,
    CASE WHEN t2.visit_id IS NOT NULL THEN 1 ELSE 0 END as purchase
FROM cte_product_page_events AS t1
LEFT JOIN cte_visit_purchase AS t2
	ON t1.visit_id = t2.visit_id
)
SELECT
  product_id,
  page_name AS product,
  product_category,
  SUM(page_view) AS page_views,
  SUM(cart_add) AS cart_adds,
  SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
  SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM cte_combined_product_events
GROUP BY product_id, product_category, product
ORDER BY 1 ASC;



DROP TABLE IF EXISTS product_category_info;
CREATE TEMP TABLE product_category_info AS
SELECT
  product_category,
  SUM(page_views) AS page_views,
  SUM(cart_adds) AS cart_adds,
  SUM(abandoned) AS abandoned,
  SUM(purchases) AS purchases
FROM product_info
GROUP BY product_category;

SELECT * FROM product_info ORDER BY product_id LIMIT 4;
SELECT * FROM product_category_info ORDER BY product_category LIMIT 4;



SELECT  * 
FROM product_info
ORDER BY page_views DESC LIMIT 1;

SELECT  * 
FROM product_info
ORDER BY cart_adds DESC LIMIT 1;

SELECT  * 
FROM product_info
ORDER BY purchases DESC LIMIT 1;

/*
	2) Which product was most likely to be abandoned?
*/
SELECT 
  product,
  CAST(CAST(abandoned AS NUMERIC)/ CAST(cart_adds AS NUMERIC) AS DECIMAL(5, 2)) AS abandoned_likelihood
FROM product_info
ORDER BY 2 DESC
LIMIT 1;


/*
	3) Which product had the highest view to purchase percentage?
*/
SELECT 
  product,
  ROUND(100*(purchases::NUMERIC/page_views::NUMERIC)::NUMERIC, 2) AS view_to_purchase_percentage
FROM product_info
ORDER BY 2 DESC
LIMIT 1;


/*
	4) What is the average conversion rate from view to cart add?
*/
SELECT
  ROUND(100*(AVG(cart_adds::NUMERIC/page_views::NUMERIC))::NUMERIC, 2) AS avg_view_to_cart_add
FROM product_info;


/*
	5) What is the average conversion rate from cart add to purchase?
*/
SELECT
  ROUND(100*(AVG(purchases::NUMERIC/cart_adds::NUMERIC))::NUMERIC, 2) AS avg_cart_add_to_purchase
FROM product_info;