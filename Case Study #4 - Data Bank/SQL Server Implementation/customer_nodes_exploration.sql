USE [8 Weeks SQL Challenge];

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
GROUP BY regions.region_name
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
	unique nodes operating in each region that would sum to exactly
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
GROUP BY regions.region_name;



/*
	3) How many customers are allocated to each region?
*/
SELECT 
	regions.region_name,
	COUNT(DISTINCT customer_nodes.customer_id) AS total_unique_customers
FROM data_bank.customer_nodes
INNER JOIN data_bank.regions
	ON customer_nodes.region_id = regions.region_id
GROUP BY regions.region_name
ORDER BY 2 DESC;


/*
	4) How many days on average are customers reallocated to a different node?
*/
--Method-1: Directly calculating median, since it is ALSO close to average duration
SELECT 
	TOP 1
	PERCENTILE_CONT(0.5) 
		WITHIN GROUP (ORDER BY V2.day_diff) 
		OVER ()
		AS average_node_duration
FROM
(
SELECT
	DISTINCT
  customer_nodes.customer_id,
  customer_nodes.node_id,
  customer_nodes.region_id,
  customer_nodes.[start_date],
  customer_nodes.end_date,
  DATEDIFF(DAY, customer_nodes.[start_date], customer_nodes.end_date) AS day_diff
FROM data_bank.customer_nodes
) AS V2;


--Method-2: Danny's way
--Including the arbitrary dates '9999-12-31'
DROP TABLE IF EXISTS #ranked_customer_nodes;
CREATE TABLE #ranked_customer_nodes 
	(
	customer_id INT,
	node_id INT,
	region_id INT,
	[start_date] DATE,
	end_date DATE,
	duration BIGINT,
	rn BIGINT
	);
INSERT INTO #ranked_customer_nodes
	(
	customer_id,
	node_id,
	region_id,
	[start_date],
	end_date,
	duration,
	rn
	)
SELECT
  customer_id,
  node_id,
  region_id,
  [start_date],
  end_date,
  DATEPART(DAY, DATEDIFF(DAY, customer_nodes.[start_date], customer_nodes.end_date)) AS duration,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rn
FROM data_bank.customer_nodes;


WITH output_table(customer_id, node_id, region_id, duration, rn, [start_date], run_id) AS (
SELECT
	customer_id,
    node_id,
	region_id,
    duration,
    rn,
	[start_date],
    1 AS run_id
FROM #ranked_customer_nodes
WHERE rn = 1
    
UNION ALL

SELECT
    t1.customer_id,
    t2.node_id,
	t1.region_id,
    t2.duration,
    t2.rn,
	t1.[start_date],
CASE
	WHEN t1.node_id != t2.node_id 
	THEN t1.run_id + 1
    ELSE t1.run_id
END AS run_id
FROM output_table t1
INNER JOIN #ranked_customer_nodes t2
	ON t1.rn + 1 = t2.rn
	AND t1.customer_id = t2.customer_id
    And t2.rn > 1
)
SELECT 
	AVG(V5.total_duration) AS average_duration
FROM
(
SELECT 
	region_id,
	run_id,
	customer_id,
	--DATEDIFF() returned 1 extra day
	SUM(duration)-1 AS total_duration
FROM output_table
GROUP BY 
	region_id,
	run_id,
	customer_id
) AS V5
OPTION (MAXRECURSION 100);


/*
	5) What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
*/	
--Including the arbitrary dates '9999-12-31'
DROP TABLE IF EXISTS #ranked_customer_nodes;
CREATE TABLE #ranked_customer_nodes 
	(
	customer_id INT,
	node_id INT,
	region_id INT,
	[start_date] DATE,
	end_date DATE,
	duration BIGINT,
	rn BIGINT
	);
INSERT INTO #ranked_customer_nodes
	(
	customer_id,
	node_id,
	region_id,
	[start_date],
	end_date,
	duration,
	rn
	)
SELECT DISTINCT
	V1.customer_id,
	V1.node_id,
	V1.region_id,
	V1.[start_date],
	TRY_PARSE(CONCAT_WS('-', V1.end_date_year, V1.end_date_month, V1.end_date_day) AS DATE) AS [end_date],
	DATEDIFF(DAY, V1.[start_date], TRY_PARSE(CONCAT_WS('-', V1.end_date_year, V1.end_date_month, V1.end_date_day) AS DATE)) AS duration,
	V1.rn
FROM
(
SELECT
  customer_nodes.customer_id,
  customer_nodes.node_id,
  customer_nodes.region_id,
  customer_nodes.[start_date],
  customer_nodes.end_date,
  YEAR(
  CASE 
	WHEN LEFT(CAST(customer_nodes.end_date AS VARCHAR(50)), 4) = '9999'
	THEN customer_nodes.[start_date]
	ELSE customer_nodes.end_date
	END) AS end_date_year,
  MONTH(
  CASE 
	WHEN LEFT(CAST(customer_nodes.end_date AS VARCHAR(50)), 4) = '9999'
	THEN customer_nodes.[start_date]
	ELSE customer_nodes.end_date
	END) AS end_date_month,
  DAY(customer_nodes.end_date) AS end_date_day,
  ROW_NUMBER() OVER (PARTITION BY customer_nodes.customer_id ORDER BY start_date) AS rn
FROM data_bank.customer_nodes
) AS V1;


WITH output_table
	(
	customer_id, 
	node_id, 
	region_id, 
	duration, 
	rn, 
	[start_date], 
	run_id
	) AS (
SELECT
	customer_id,
    node_id,
	region_id,
    duration,
    rn,
	start_date,
    1 AS run_id
FROM #ranked_customer_nodes
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
INNER JOIN #ranked_customer_nodes t2
	ON t1.rn + 1 = t2.rn
	AND t1.customer_id = t2.customer_id
    And t2.rn > 1
)
SELECT DISTINCT
	V5.region_id, regions.region_name,
	PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY V5.duration_date ASC) OVER ()  AS median_duration,
	PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY V5.duration_date ASC) OVER (PARTITION BY V5.region_id, regions.region_name)  AS [80th_percentile],
	PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY V5.duration_date ASC) OVER (PARTITION BY V5.region_id, regions.region_name) AS [95th_percentile]
FROM
(
SELECT 
	region_id,
	run_id,
	customer_id,
	SUM(duration) AS duration_date
FROM output_table
GROUP BY 
	region_id,
	run_id,
	customer_id
) AS V5
INNER JOIN data_bank.regions
	ON V5.region_id = regions.region_id
AND V5.duration_date IS NOT NULL
AND V5.duration_date != 0
OPTION (MAXRECURSION 360);