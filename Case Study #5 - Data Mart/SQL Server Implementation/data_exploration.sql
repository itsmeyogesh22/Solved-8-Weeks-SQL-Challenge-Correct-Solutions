USE [8 Weeks SQL Challenge];

/*
	1) What day of the week is used for each week_date value?
*/
SELECT 
	DATENAME(WEEKDAY, mv_clean_weekly_sales.week_date) AS day_of_week,
	COUNT(*) AS total_records
FROM data_mart.mv_clean_weekly_sales
WHERE week_date IS NOT NULL
GROUP BY DATENAME(WEEKDAY, mv_clean_weekly_sales.week_date);


/*
	2) What range of week numbers are missing from the dataset?
*/
WITH week_range AS (
SELECT
CAST(all_weeks.value AS INT) AS all_weeks
FROM
GENERATE_SERIES(
	DATEPART(WEEK, '2020-01-01'),
	DATEPART(WEEK, '2020-12-31'),
	1
	) AS all_weeks
)
SELECT *
FROM week_range AS T1
WHERE 
	NOT EXISTS
		(
		SELECT 1
		FROM data_mart.mv_clean_weekly_sales AS T2
		WHERE T1.all_weeks = T2.week_number
		AND T2.week_date IS NOT NULL
		);



/*
	3) How many total transactions were there for each year in the dataset?
*/
SELECT 
	mv_clean_weekly_sales.calendar_year,
	SUM(mv_clean_weekly_sales.transactions) AS txn_cnt
FROM data_mart.mv_clean_weekly_sales
GROUP BY mv_clean_weekly_sales.calendar_year
ORDER BY 1 ASC;


/*
	4) What is the total sales for each region for each month?
*/
WITH sales_agg_cte AS ( 
SELECT 
	CONCAT_WS(' | ', calendar_year, region) AS calendar_year,
	month_name,
	total_sales
FROM
(
SELECT 
	ROW_NUMBER() 
		OVER (
			PARTITION BY mv_clean_weekly_sales.calendar_year, DATENAME(MONTH, mv_clean_weekly_sales.week_date)
			ORDER BY mv_clean_weekly_sales.month_number ASC) AS row_id,
	mv_clean_weekly_sales.calendar_year,
	DATENAME(MONTH, mv_clean_weekly_sales.week_date) AS month_name,
	mv_clean_weekly_sales.region,
	mv_clean_weekly_sales.sales AS total_sales
FROM data_mart.mv_clean_weekly_sales
) AS V1
)
SELECT
	CAST(
	SUBSTRING(
		calendar_year, 
		0,
		CHARINDEX(' |', calendar_year)+1) AS INT) AS calendar_year,
	SUBSTRING(
		calendar_year, 
		CHARINDEX('| ', calendar_year)+1,
		LEN(calendar_year)) AS region,
	[March], [April], [May], [June], [July], [August], [September]
FROM 
sales_agg_cte
PIVOT
	(SUM(total_sales) FOR month_name IN ([March], [April], [May], [June], [July], [August], [September])) AS pivot_1
ORDER BY 1 ASC;




/*
	5) What is the total count of transactions for each platform
*/
SELECT 
	mv_clean_weekly_sales.platform,
	SUM(mv_clean_weekly_sales.transactions) AS total_txn
FROM data_mart.mv_clean_weekly_sales
GROUP BY mv_clean_weekly_sales.platform;


/*
	6) What is the percentage of sales for Retail vs Shopify for each month?
*/
WITH aggregated_sales AS (
SELECT 
	mv_clean_weekly_sales.platform,
	mv_clean_weekly_sales.calendar_year,
	DATENAME(MONTH, mv_clean_weekly_sales.week_date) AS month_name,
	SUM(CAST(mv_clean_weekly_sales.sales AS BIGINT)) AS total_sales
FROM data_mart.mv_clean_weekly_sales
GROUP BY 
	mv_clean_weekly_sales.platform, 
	mv_clean_weekly_sales.calendar_year, 
	DATENAME(MONTH, mv_clean_weekly_sales.week_date)
),
shopify_sales AS (
SELECT 
	aggregated_sales.calendar_year,
	aggregated_sales.month_name,
	CAST(aggregated_sales.total_sales AS BIGINT) AS Shopify
FROM aggregated_sales
WHERE aggregated_sales.platform = 'Shopify'
),
retail_sales AS (
SELECT 
	aggregated_sales.calendar_year,
	aggregated_sales.month_name,
	CAST(aggregated_sales.total_sales AS BIGINT) AS retail
FROM aggregated_sales
WHERE aggregated_sales.platform = 'Retail'
)
SELECT 
	shopify_sales.calendar_year,
	shopify_sales.month_name,
	CAST(100*CAST(shopify_sales.shopify AS DECIMAL(32, 10))/
		CAST((shopify_sales.shopify + retail_sales.retail) AS DECIMAL(32, 10)) AS DECIMAL(5, 2)) AS shopify_percentage,
	CAST(100*CAST(retail_sales.retail AS DECIMAL(32, 10))/
		CAST((shopify_sales.shopify + retail_sales.retail) AS DECIMAL(32, 10)) AS DECIMAL(5, 2)) AS retail_percentage
FROM shopify_sales
INNER JOIN retail_sales
	ON shopify_sales.calendar_year = retail_sales.calendar_year
	AND
	shopify_sales.month_name = retail_sales.month_name
ORDER BY 1;



/*
	7) What is the amount and percentage of sales by demographic for each year in the dataset?
*/
SELECT
  mv_clean_weekly_sales.calendar_year,
  mv_clean_weekly_sales.demographic,
  SUM(CAST(mv_clean_weekly_sales.sales AS BIGINT)) AS annual_sales,
  CAST(
    (
      100 * CAST(SUM(CAST(mv_clean_weekly_sales.sales AS BIGINT)) AS DECIMAL(32, 10)) /
        CAST(SUM(SUM(CAST(mv_clean_weekly_sales.sales AS BIGINT))) OVER (PARTITION BY mv_clean_weekly_sales.calendar_year) AS DECIMAL(32, 10))
    )
  AS DECIMAL(5, 2)) AS percentage
FROM data_mart.mv_clean_weekly_sales
GROUP BY
  mv_clean_weekly_sales.calendar_year,
  mv_clean_weekly_sales.demographic
ORDER BY
  mv_clean_weekly_sales.calendar_year,
  mv_clean_weekly_sales.demographic;


/*
	8) Which age_band and demographic values contribute the most to Retail sales?
*/
-- age band only
--Method-1:
SELECT
  age_band,
  SUM(CAST(sales AS BIGINT)) AS total_sales,
  CEILING((100 * SUM(CAST(sales AS BIGINT)))/ 
  	(SELECT SUM(CAST(sales AS BIGINT)) FROM data_mart.mv_clean_weekly_sales WHERE platform = 'Retail')) AS sales_percentage
FROM data_mart.mv_clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band
ORDER BY sales_percentage DESC;

--Method-2:
SELECT
  age_band,
  SUM(CAST(sales AS BIGINT)) AS total_sales,
  CEILING((100 * SUM(CAST(sales AS NUMERIC))) / (SUM(SUM(CAST(sales AS NUMERIC))) OVER (PARTITION BY platform))) AS sales_percentage
FROM data_mart.mv_clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY platform, age_band
ORDER BY sales_percentage DESC;


-- demographic only
--Method-1:
SELECT
  demographic,
  SUM(CAST(sales AS BIGINT)) AS total_sales,
  ROUND((100 * SUM(CAST(sales AS BIGINT)))/ 
  	(SELECT SUM(CAST(sales AS BIGINT)) FROM data_mart.mv_clean_weekly_sales WHERE platform = 'Retail'), 2) AS sales_percentage
FROM data_mart.mv_clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY demographic
ORDER BY sales_percentage DESC;

--Method-2:
SELECT
  demographic,
  SUM(CAST(sales AS BIGINT)) AS total_sales,
  CEILING((100 * SUM(CAST(sales AS NUMERIC))) / (SUM(SUM(CAST(sales AS NUMERIC))) OVER (PARTITION BY platform))) AS sales_percentage
FROM data_mart.mv_clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY platform, demographic
ORDER BY sales_percentage DESC;



-- both age and demographic
SELECT
  age_band
  demographic,
  SUM(CAST(sales AS BIGINT)) AS total_sales,
  CAST((100 * SUM(CAST(sales AS NUMERIC))) / (SUM(SUM(CAST(sales AS NUMERIC))) OVER (PARTITION BY platform)) AS DECIMAL(5, 2)) AS sales_percentage
FROM data_mart.mv_clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY platform, age_band, demographic
ORDER BY sales_percentage DESC;


/*
	9) Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
	If not - how would you calculate it instead?
*/
--No, because 'avg_transaction' column is aggregated on each row.
SELECT
  calendar_year,
  platform,
  AVG(avg_transaction) AS avg_avg_transaction,
  CAST(AVG(CAST(sales AS NUMERIC))/AVG(CAST(transactions AS NUMERIC)) AS INT) AS avg_annual_transaction
FROM data_mart.mv_clean_weekly_sales
GROUP BY
  calendar_year,
  platform
ORDER BY
  calendar_year,
  platform;