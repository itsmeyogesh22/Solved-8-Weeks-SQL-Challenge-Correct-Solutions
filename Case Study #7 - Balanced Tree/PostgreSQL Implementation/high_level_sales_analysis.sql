/*
	1) What was the total quantity sold for all products?
*/
SELECT 
	product_details.product_name,
	SUM(sales.qty) AS total_sales
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
 ON sales.prod_id = product_details.product_id
GROUP BY 1
ORDER BY 2 DESC;


/*
	2) What is the total generated revenue for all products before discounts?
*/
SELECT 
	SUM(V1.total_revenue) AS total_revenue
FROM
(
SELECT
  price * SUM(qty) AS total_revenue
FROM balanced_tree.sales
GROUP BY price
) AS V1;


/*
	3) What was the total discount amount for all products?
*/
/*
 "This is one of my favourite things to look out for - can you remember which concept this question is testing?"
 -Asks Danny

  "Basic Mathematics" - I replied
*/
SELECT
	ROUND(SUM(V3.total_discount), 2) AS total_discount
FROM 
(
SELECT 
  product.product_name, 
  SUM((sales.qty::NUMERIC*(sales.discount*sales.price)::NUMERIC/100)::NUMERIC) AS total_discount
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details AS product
	ON sales.prod_id = product.product_id
GROUP BY product.product_name, sales.qty
) AS V3;


