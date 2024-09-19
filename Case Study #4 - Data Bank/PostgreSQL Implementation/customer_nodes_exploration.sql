/*
	1)How many unique nodes are there on the Data Bank system?
*/
--Method-1: Sum of Unique Node count in each region 
WITH nodes_by_region AS (
SELECT 
	regions.region_name,
	COUNT(DISTINCT customer_nodes.node_id) AS total_nodes
FROM data_bank.customer_nodes
INNER JOIN data_bank.regions
	ON customer_nodes.region_id = regions.region_id
GROUP BY 1
)
SELECT 
	SUM(nodes_by_region.total_nodes) AS total_nodes
FROM nodes_by_region;


--Method-2: Unique Node count in entire table
SELECT 
	COUNT(DISTINCT customer_nodes.node_id) AS total_nodes
FROM data_bank.customer_nodes
WHERE  customer_nodes.end_date != '9999-12-31';

/*
	Personally I fail to understand how possibly can count of
	unique nodes be 25, unless we are aggregating the count of
	unique node operating in each region that would sum to exactly
	25 nodes. But that itself goes against the question asked here. 
	Therefore, This question is solved using two different methods.

	Question could have been framed more precisely, something such
	as: "How many unique nodes are operating by each region in 
	the Data Bank System?
	But who am I to say that, since I'm no Industry expert, I don't
	even have a job lmao."
*/




/*
	2) What is the number of nodes per region?
*/
SELECT 
	regions.region_name,
	COUNT(DISTINCT customer_nodes.node_id) AS total_nodes
FROM data_bank.customer_nodes
INNER JOIN data_bank.regions
	ON customer_nodes.region_id = regions.region_id
GROUP BY 1;


/*
	3) How many customers are allocated to each region?
*/
SELECT 
	regions.region_name,
	COUNT(DISTINCT customer_nodes.customer_id) AS total_unique_customers
FROM data_bank.customer_nodes
INNER JOIN data_bank.regions
	ON customer_nodes.region_id = regions.region_id
GROUP BY 1
ORDER BY 2 DESC;


/*
	4) How many days on average are customers reallocated to a different node?
*/
--Method-1: Directly calculating median, since it is ALSO close to average duration
SELECT 
	PERCENTILE_CONT(0.5) 
		WITHIN GROUP (ORDER BY V2.day_diff) AS average_node_duration
FROM
(
SELECT
	DISTINCT
  customer_nodes.customer_id,
  customer_nodes.node_id,
  customer_nodes.region_id,
  customer_nodes.start_date,
  customer_nodes.end_date,
  customer_nodes.end_date - customer_nodes.start_date AS day_diff
FROM data_bank.customer_nodes
) AS V2;

--Method-2: Danny's way
--Including the arbitrary dates '9999-12-31'
DROP TABLE IF EXISTS ranked_customer_nodes;
CREATE TEMP TABLE ranked_customer_nodes AS
SELECT
  customer_id,
  node_id,
  region_id,
  start_date,
  end_date,
  DATE_PART('day', AGE(end_date, start_date))::INTEGER AS duration,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rn
FROM data_bank.customer_nodes;

WITH RECURSIVE output_table AS (
SELECT
	customer_id,
    node_id,
	region_id,
    duration,
    rn,
	start_date,
    1 AS run_id
FROM ranked_customer_nodes
WHERE rn = 1
    
UNION ALL

SELECT
    t1.customer_id,
    t2.node_id,
	t1.region_id,
    t2.duration,
    t2.rn,
	t1.start_date,
CASE
	WHEN t1.node_id != t2.node_id 
	THEN t1.run_id + 1
    ELSE t1.run_id
END AS run_id
FROM output_table t1
INNER JOIN ranked_customer_nodes t2
	ON t1.rn + 1 = t2.rn
	AND t1.customer_id = t2.customer_id
    And t2.rn > 1
)
SELECT 
	ROUND(AVG(V5.total_duration)) AS average_duration
FROM
(
SELECT 
	region_id,
	run_id,
	customer_id,
	SUM(duration) AS total_duration
FROM output_table
GROUP BY 1, 2, 3
) AS V5;


/*
	5) What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
*/	
--Including the arbitrary dates '9999-12-31'
DROP TABLE IF EXISTS ranked_customer_nodes;
CREATE TEMP TABLE ranked_customer_nodes AS
SELECT
  customer_id,
  node_id,
  region_id,
  start_date,
  end_date,
  DATE_PART('day', AGE(end_date, start_date))::INTEGER AS duration,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rn
FROM data_bank.customer_nodes;


WITH RECURSIVE output_table AS (
SELECT
	customer_id,
    node_id,
	region_id,
    duration,
    rn,
	start_date,
    1 AS run_id
FROM ranked_customer_nodes
WHERE rn = 1
    
UNION ALL

SELECT
    t1.customer_id,
    t2.node_id,
	t1.region_id,
    t2.duration,
    t2.rn,
	t1.start_date,
CASE
	WHEN t1.node_id != t2.node_id 
	THEN t1.run_id + 1
    ELSE t1.run_id
END AS run_id
FROM output_table t1
INNER JOIN ranked_customer_nodes t2
	ON t1.rn + 1 = t2.rn
	AND t1.customer_id = t2.customer_id
    And t2.rn > 1
)
SELECT 
	V5.region_id,
	regions.region_name,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY V5.total_duration ASC)) AS median_duration,
	ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY V5.total_duration ASC)) AS "80th_percentile",
	ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY V5.total_duration ASC)) AS "95th_percentile"
FROM
(
SELECT 
	region_id,
	run_id,
	customer_id,
	SUM(duration) AS total_duration
FROM output_table
GROUP BY 
	region_id,
	run_id,
	customer_id
) AS V5
INNER JOIN data_bank.regions
	ON V5.region_id = regions.region_id
GROUP BY 1, 2;