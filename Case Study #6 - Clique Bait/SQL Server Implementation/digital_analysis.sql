USE [8 Weeks SQL Challenge];

/*
	1) How many users are there?
*/
SELECT 
	COUNT(DISTINCT users.user_id) AS unique_user_count
FROM clique_bait.users;


/*
	2) How many cookies does each user have on average?
*/
SELECT 
	CAST(AVG(V1.cookie_cnt) AS DECIMAL(5, 2)) AS average_cookie_usage
FROM
(
SELECT 
	users.user_id,
	CAST(COUNT(DISTINCT users.cookie_id) AS NUMERIC) AS cookie_cnt
FROM clique_bait.users
GROUP BY users.user_id
) AS V1;


/*
	3) What is the unique number of visits by all users per month?
*/
SELECT 
	DATEPART(MONTH, events.event_time) AS mmonth_number,
	DATENAME(MONTH, events.event_time) AS month_name,
	COUNT(DISTINCT events.visit_id) AS  visit_count
FROM clique_bait.events
GROUP BY 
	DATEPART(MONTH, events.event_time),
	DATENAME(MONTH, events.event_time)
ORDER BY 1;


/*
	4) What is the number of events for each event type?
*/
SELECT 
	event_identifier.event_type,
	event_identifier.event_name,
	COUNT(events.event_type) AS total_events
FROM clique_bait.event_identifier
INNER JOIN clique_bait.events
	ON event_identifier.event_type = events.event_type
GROUP BY 
	event_identifier.event_type,
	event_identifier.event_name
ORDER BY 1 ASC;



/*
	5) What is the percentage of visits which have a purchase event?
*/
WITH cte_visits_with_purchase_flag AS (
  SELECT
    visit_id,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase_flag
  FROM clique_bait.events
  GROUP BY visit_id
)
SELECT
  CAST(CAST((100 * SUM(purchase_flag)) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS DECIMAL(5, 2)) AS purchase_percentage
FROM cte_visits_with_purchase_flag;



/*
	6) What is the percentage of visits which view the checkout page but do not have a purchase event?
*/
WITH cte_visits_with_checkout_and_purchase_flags AS (
  SELECT
    visit_id,
    (CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS checkout_flag,
	(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase_flag
  FROM clique_bait.events
)
SELECT
	CAST(
  100*(CAST((SUM(checkout_flag)-SUM(purchase_flag))AS NUMERIC)
  /CAST(SUM(checkout_flag) AS NUMERIC))
  AS DECIMAL(5, 2)) AS checkout_without_purchase_percentage
FROM cte_visits_with_checkout_and_purchase_flags;



/*
	7) What are the top 3 pages by number of views?
*/
SELECT TOP 3
  page_hierarchy.page_name,
  COUNT(*) AS page_views  
FROM clique_bait.events
INNER JOIN clique_bait.page_hierarchy
  ON events.page_id = page_hierarchy.page_id
WHERE event_type = 1 
GROUP BY page_hierarchy.page_name
ORDER BY page_views DESC;


/*
	8) What is the number of views and cart adds for each product category?
*/
SELECT
  page_hierarchy.product_category,
  SUM(CASE WHEN event_type = 2 THEN 0 ELSE 1 END) AS page_views,
  SUM(CASE WHEN event_type = 1 THEN 0 ELSE 1 END) AS cart_adds
FROM clique_bait.events
INNER JOIN clique_bait.page_hierarchy
  ON events.page_id = page_hierarchy.page_id
WHERE page_hierarchy.product_category IS NOT NULL
GROUP BY page_hierarchy.product_category
ORDER BY page_views DESC;



/*
	9) What are the top 3 products by purchases?
*/
WITH cte_purchase_visits AS (
  SELECT
    visit_id
  FROM clique_bait.events
  WHERE event_type = 3 
)
SELECT
  page_hierarchy.product_id,
  page_hierarchy.page_name AS product_name,
  SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS purchases
FROM clique_bait.events
INNER JOIN clique_bait.page_hierarchy
  ON events.page_id = page_hierarchy.page_id
WHERE EXISTS (
  SELECT 1
  FROM cte_purchase_visits
  WHERE events.visit_id = cte_purchase_visits.visit_id
)
AND page_hierarchy.product_id IS NOT NULL
GROUP BY page_hierarchy.product_id, page_hierarchy.page_name
ORDER BY page_hierarchy.product_id;