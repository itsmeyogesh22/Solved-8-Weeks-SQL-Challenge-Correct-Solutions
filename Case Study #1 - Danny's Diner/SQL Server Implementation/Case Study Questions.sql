USE [8 Weeks SQL Challenge];

/*
	1) What is the total amount each customer spent at the restaurant?
*/
SELECT 
	order_history.customer_id,
	SUM(order_history.price) AS amount_spent
FROM 
(
SELECT 
	sales.customer_id,
	sales.order_date,
	sales.product_id,
	menu.price
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
) AS order_history
GROUP BY order_history.customer_id
ORDER BY 2 DESC;


/*
	2) How many days has each customer visited the restaurant?
*/
SELECT 
	sales.customer_id,
	COUNT(DISTINCT sales.order_date) AS days_visited
FROM dannys_diner.sales
GROUP BY  sales.customer_id
ORDER BY 2 DESC;


/*
	3) What was the first item from the menu purchased by each customer?
*/
SELECT DISTINCT
	purchase_history.customer_id,
	purchase_history.product_name
FROM 
(
SELECT 
sales.customer_id,
sales.order_date,
sales.product_id,
menu.product_name,
DENSE_RANK()
	OVER (
		PARTITION BY sales.customer_id
		ORDER BY sales.order_date ASC
	) AS purchase_order
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
) AS purchase_history
WHERE purchase_history.purchase_order = 1


/*
	4) What is the most purchased item on the menu and how many times 
	was it purchased by all customers?
*/
SELECT TOP 1
	menu.product_name,
	COUNT(*) AS times_ordered
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY 2 DESC;


/*
	5) Which item was the most popular for each customer?
*/
SELECT 
	ranked_items.customer_id,
	ranked_items.product_name,
	ranked_items.total_sold
FROM 
(
SELECT 
	sales.customer_id,
	menu.product_name,
	COUNT(*) AS total_sold, 
	DENSE_RANK()
		OVER (
			PARTITION BY sales.customer_id
			ORDER BY COUNT(*) DESC
		) AS item_rank
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
GROUP BY 
	sales.customer_id,
	menu.product_name
) AS ranked_items
WHERE ranked_items.item_rank = 1;


/*
	6) Which item was purchased first by the customer after they became a member?
*/
SELECT 
	order_history2.customer_id,
	order_history2.order_date,
	order_history2.product_name
FROM 
(
SELECT 
	sales.customer_id,
	members.join_date,
	sales.order_date,
	menu.product_name,
	DENSE_RANK()
		OVER (
			PARTITION BY sales.customer_id
			ORDER BY sales.order_date ASC
		) AS purchase_order
FROM dannys_diner.sales
INNER JOIN dannys_diner.members
	ON sales.order_date >= members.join_date 
	AND
	sales.customer_id = members.customer_id	
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
) AS order_history2
WHERE order_history2.purchase_order = 1;


/*
	7) Which menu item(s) was purchased just before the customer became a member and when?	
*/
SELECT 
	order_history2.customer_id,
	order_history2.order_date,
	order_history2.product_name
FROM 
(
SELECT 
	sales.customer_id,
	members.join_date,
	sales.order_date,
	menu.product_name,
	DENSE_RANK()
		OVER (
			PARTITION BY sales.customer_id
			ORDER BY sales.order_date DESC
		) AS purchase_order
FROM dannys_diner.sales
INNER JOIN dannys_diner.members
	ON sales.order_date < members.join_date  
	AND
	sales.customer_id = members.customer_id	
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
) AS order_history2
WHERE order_history2.purchase_order = 1;


/*
	8) What is the number of unique menu items and total amount spent 
	for each member before they became a member?
*/
SELECT 
	sales.customer_id,
	COUNT(DISTINCT menu.product_name) AS unique_items,
	SUM(menu.price) AS total_amount_spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
INNER JOIN dannys_diner.members
	ON sales.customer_id = members.customer_id
	AND 
	sales.order_date < members.join_date
GROUP BY 
	sales.customer_id;


/*
	9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier
	- how many points would each customer have?
*/
SELECT 
	sales.customer_id,
	SUM(
	CASE 
		WHEN menu.product_name = 'sushi' THEN menu.price * 20
		ELSE menu.price * 10
		END 
	) AS points_earned 
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
GROUP BY 
	sales.customer_id
ORDER BY 2 DESC;


/*
	10) In the first week after a customer joins the program (including their join date) 
	they earn 2x points on all items, not just sushi 
	- how many points do customer A and B have at the end of January?
*/
SELECT 
	sales.customer_id,
	SUM(
		CASE 
			WHEN sales.order_date BETWEEN (members.join_date) AND DATEADD(DAY, 6, members.join_date)
			THEN menu.price * 20
			WHEN menu.product_name != 'sushi' 
			AND
			sales.order_date <= DATEADD(DAY, 7, members.join_date)
			THEN menu.price * 10
	
			WHEN menu.product_name = 'sushi' 
			AND
			sales.order_date <= DATEADD(DAY, 7, members.join_date)
			THEN menu.price * 20
			ELSE 0
		END
	) AS total_points_earned
FROM dannys_diner.sales
INNER JOIN dannys_diner.members
	ON sales.customer_id = members.customer_id 
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
WHERE sales.order_date <= '2021-01-31'
GROUP BY sales.customer_id;



/*
	11) Danny and his team can use to quickly derive insights without 
	needing to join the underlying tables using SQL Recreate the following 
	table output using the available data.
*/
SELECT 
	sales.customer_id,
	sales.order_date,
	menu.product_name,
	menu.price,
CASE 
	WHEN sales.order_date >= members.join_date
	AND	 members.customer_id = sales.customer_id
	THEN 'Y'
	ELSE 'N'
	END AS membership_status
FROM dannys_diner.sales
FULL JOIN dannys_diner.members
	ON sales.customer_id = members.customer_id
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id;



/*
	12) Danny also requires further information about the ranking of customer products, 
	but he purposely does not need the ranking for non-member purchases so he expects null 
	ranking values for the records when customers are not yet part of the loyalty program.
*/
SELECT 
	*,
	CASE 
		WHEN membership_stat.membership_status = 'N'
		THEN NULL
		ELSE 
			RANK() 
				OVER (
					PARTITION BY membership_stat.customer_id, membership_stat.membership_status
					ORDER BY membership_stat.order_date ASC
	)
	END
FROM
(
SELECT 
	sales.customer_id,
	sales.order_date,
	menu.product_name,
	menu.price,
CASE 
	WHEN sales.order_date >= members.join_date
	AND	 members.customer_id = sales.customer_id
	THEN 'Y'
	ELSE 'N'
	END AS membership_status
FROM dannys_diner.sales
FULL JOIN dannys_diner.members
	ON sales.customer_id = members.customer_id
INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
) AS membership_stat;