USE [8 Weeks SQL Challenge];

/*
	1) What are the top 3 products by total revenue before discount?
*/
SELECT TOP 3
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
ORDER BY 3 DESC;


/*
	2) What is the total quantity, revenue and discount for each segment?
*/
SELECT
  product_details.segment_name,
  SUM(sales.qty) AS total_quantity,
  SUM(sales.qty * sales.price) AS total_revenue,
  CAST(
    CAST(SUM(sales.qty * sales.price * sales.discount) AS NUMERIC)/100
  AS DECIMAL(10, 2)) AS total_discount
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
  CAST(CAST(SUM(sales.qty * sales.price * sales.discount) AS NUMERIC)/100 AS DECIMAL(8, 2)) AS total_discount
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
  CAST(
    CAST(100 * product_revenue AS NUMERIC) /
      CAST(SUM(product_revenue) OVER (PARTITION BY segment_id) AS NUMERIC) 
	  AS DECIMAL(5, 2)) AS segment_product_percentage
FROM cte_product_revenue
ORDER BY segment_id, segment_product_percentage DESC;


/*
	7) What is the percentage split of revenue by segment for each category?
*/
WITH cte_product_revenue AS (
  SELECT
    product_details.category_id,
    product_details.category_name,
	product_details.segment_id,
	product_details.segment_name,
    CAST(SUM(sales.qty * sales.price) AS NUMERIC) AS product_revenue
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
  CAST(
	CAST(100*product_revenue AS NUMERIC)/
	CAST((SUM(product_revenue) OVER (PARTITION BY category_id)) AS NUMERIC)
	AS DECIMAL(5, 2)) AS category_segment_percentage
FROM cte_product_revenue
ORDER BY category_id, category_segment_percentage DESC;


/*
	8) What is the percentage split of total revenue by category?
*/
WITH cte_category_revenue AS (
SELECT
    product_details.category_id,
    product_details.category_name,
    CAST(SUM(sales.qty * sales.price) AS NUMERIC) AS category_revenue
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
GROUP BY
    product_details.category_id,
    product_details.category_name
)
SELECT
  *,
  CAST(
    CAST(100 * category_revenue AS NUMERIC) /
      CAST((SUM(category_revenue) OVER ()) AS NUMERIC) 
	AS DECIMAL(5, 2)) AS category_revenue_percentage
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
  CAST(
    CAST(100 * product_transactions.product_transactions AS NUMERIC)
      / CAST(total_transactions.total_transaction_count AS NUMERIC)
   AS DECIMAL(5, 2)) AS penetration_percentage
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
    with products AS(
      SELECT
	    pd.product_id,
        s.txn_id,
        pd.product_name,
		s.qty,
		pd.price,
		s.discount
      FROM 
        balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS pd 
			ON s.prod_id = pd.product_id
)
SELECT
	V10.product_id,
	V10.product_name,
	V10.combo_transaction_count,
	V10.quantity,
	V10.revenue,
	V10.discount,
	V10.net_revenue
FROM
(
SELECT
	  p.product_id,
	  p.product_name AS product_name,
      COUNT(DISTINCT p.txn_id) AS combo_transaction_count,
	  SUM(p.qty) AS quantity,
	  SUM(p.qty*p.price) AS revenue,
	  CAST(CAST(SUM(p.qty*p.price*p.discount) AS NUMERIC)/100 AS DECIMAL(10, 2)) AS discount, 
	  CAST(CAST(SUM(p.qty*p.price) AS NUMERIC)-(CAST(SUM(p.qty*p.price*p.discount) AS NUMERIC)/100) AS DECIMAL(10, 2)) AS net_revenue,
      ROW_NUMBER() OVER(
        ORDER BY
          COUNT(DISTINCT p.txn_id) DESC
      ) AS rank
    FROM
      products AS p
      JOIN products AS p1 ON p.txn_id = p1.txn_id
      AND p.product_name != p1.product_name
      AND p.product_name < p1.product_name
      JOIN products AS p2 ON p.txn_id = p2.txn_id
      AND p.product_name != p2.product_name
      AND p1.product_name != p2.product_name
      AND p.product_name < p2.product_name
      AND p1.product_name < p2.product_name
    GROUP BY
	  p.product_id,
      p.product_name,
	  p1.product_name,
	  p2.product_name
UNION
SELECT
	  p1.product_id,
      p1.product_name AS product_2,
      COUNT(DISTINCT p1.txn_id) AS combo_transaction_count,
	  SUM(p1.qty) AS quantity,
	  SUM(p1.qty*p1.price) AS revenue,
	  CAST(CAST(SUM(p1.qty*p1.price*p1.discount) AS NUMERIC)/100 AS DECIMAL(10, 2)) AS discount,
	  CAST(CAST(SUM(p1.qty*p1.price) AS NUMERIC)-(CAST(SUM(p1.qty*p1.price*p1.discount) AS NUMERIC)/100) AS DECIMAL(10, 2)) AS net_revenue,
      ROW_NUMBER() OVER(
        ORDER BY
          COUNT(DISTINCT p1.txn_id) DESC
      ) AS rank
    FROM
      products AS p
      JOIN products AS p1 ON p.txn_id = p1.txn_id
      AND p.product_name != p1.product_name
      AND p.product_name < p1.product_name
      JOIN products AS p2 ON p.txn_id = p2.txn_id
      AND p.product_name != p2.product_name
      AND p1.product_name != p2.product_name
      AND p.product_name < p2.product_name
      AND p1.product_name < p2.product_name
    GROUP BY
	  p1.product_id,
	  p.product_name,
      p1.product_name,
	  p2.product_name
UNION
SELECT
	  p2.product_id,
      p2.product_name AS product_3,
      COUNT(DISTINCT p2.txn_id) AS combo_transaction_count,
	  SUM(p2.qty) AS quantity,
	  SUM(p2.qty*p2.price) AS revenue,
	  CAST(CAST(SUM(p2.qty*p2.price*p2.discount) AS NUMERIC)/100 AS DECIMAL(10, 2)) AS discount, 
	  CAST(CAST(SUM(p2.qty*p2.price) AS NUMERIC)-(CAST(SUM(p2.qty*p2.price*p2.discount) AS NUMERIC)/100) AS DECIMAL(10, 2)) AS net_revenue,
      ROW_NUMBER() OVER(
        ORDER BY
          COUNT(DISTINCT p2.txn_id) DESC
      ) AS rank
    FROM
      products AS p
      JOIN products AS p1 ON p.txn_id = p1.txn_id
      AND p.product_name != p1.product_name
      AND p.product_name < p1.product_name
      JOIN products AS p2 ON p.txn_id = p2.txn_id
      AND p.product_name != p2.product_name
      AND p1.product_name != p2.product_name
      AND p.product_name < p2.product_name
      AND p1.product_name < p2.product_name
    GROUP BY
	  p2.product_id,
	  p.product_name,
      p1.product_name,
	  p2.product_name
) AS V10
WHERE V10.rank = 1;