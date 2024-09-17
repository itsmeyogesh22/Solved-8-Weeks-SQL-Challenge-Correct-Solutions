/*
	1) What day of the week is used for each week_date value?
*/
SELECT 
	TO_CHAR(mv_clean_weekly_sales.week_date, 'DAY') AS day_of_week,
	COUNT(*)
FROM data_mart.mv_clean_weekly_sales
GROUP BY 1;


/*
	2) What range of week numbers are missing from the dataset?
*/
WITH week_range AS (
SELECT
	GENERATE_SERIES(
		DATE_PART('WEEK', '2020-01-01'::DATE)::INT,
		DATE_PART('WEEK', '2020-12-31'::DATE)::INT,
		1
		) AS all_weeks
)
SELECT *
FROM week_range
WHERE 
	NOT EXISTS
		(
		SELECT 1
		FROM data_mart.mv_clean_weekly_sales
		WHERE week_range.all_weeks = mv_clean_weekly_sales.week_number
		);


/*
	3) How many total transactions were there for each year in the dataset?
*/
SELECT 
	mv_clean_weekly_sales.calendar_year,
	SUM(mv_clean_weekly_sales.transactions) AS txn_cnt
FROM data_mart.mv_clean_weekly_sales
GROUP BY 1
ORDER BY 1 ASC;


/*
	4) What is the total sales for each region for each month?
*/
CREATE EXTENSION IF NOT EXISTS tablefunc;
DROP TABLE IF EXISTS sales_pivot;
CREATE TEMP TABLE sales_pivot AS
SELECT 
	ROW_NUMBER() 
		OVER (
			PARTITION BY mv_clean_weekly_sales.calendar_year, TO_CHAR(mv_clean_weekly_sales.week_date, 'MONTH')
			ORDER BY mv_clean_weekly_sales.month_number ASC) AS row_id,
	mv_clean_weekly_sales.calendar_year,
	TO_CHAR(mv_clean_weekly_sales.week_date, 'MONTH') AS month_name,
	mv_clean_weekly_sales.region,
	SUM(mv_clean_weekly_sales.sales) AS total_sales
FROM data_mart.mv_clean_weekly_sales
GROUP BY 
	mv_clean_weekly_sales.calendar_year, 
	mv_clean_weekly_sales.week_date,
	mv_clean_weekly_sales.month_number, 
	mv_clean_weekly_sales.region;

WITH pivot_view AS (
SELECT 
	*
FROM 
crosstab(
$$SELECT 
	CONCAT_WS(' | ', calendar_year, region) AS calendar_year,
	month_name,
	total_sales
FROM sales_pivot
ORDER BY 1;$$
) AS pivot_1( 
	calendar_year TEXT, 
	MARCH BIGINT, APRIL BIGINT, MAY BIGINT, JUNE BIGINT, JULY BIGINT, AUGUST BIGINT, SEPTEMBER BIGINT)
)
SELECT
	SUBSTRING(
		pivot_view.calendar_year, 
		0,
		POSITION(' |' IN pivot_view.calendar_year)+1) AS calendar_year,
	SUBSTRING(
		pivot_view.calendar_year, 
		POSITION('| ' IN pivot_view.calendar_year)+1,
		LENGTH(pivot_view.calendar_year)) AS region,
	pivot_view.MARCH,
	pivot_view.APRIL,
	pivot_view.MAY,
	pivot_view.JUNE,
	pivot_view.JULY,
	pivot_view.AUGUST,
	pivot_view.SEPTEMBER
FROM pivot_view;


/*
	5) What is the total count of transactions for each platform
*/
SELECT 
	mv_clean_weekly_sales.platform,
	SUM(mv_clean_weekly_sales.transactions) AS total_txn
FROM data_mart.mv_clean_weekly_sales
GROUP BY 1;


/*
	6) What is the percentage of sales for Retail vs Shopify for each month?
*/
WITH aggregated_sales AS (
SELECT 
	mv_clean_weekly_sales.platform,
	mv_clean_weekly_sales.calendar_year,
	TO_CHAR(mv_clean_weekly_sales.week_date, 'MONTH') AS month_name,
	SUM(mv_clean_weekly_sales.sales) AS total_sales
FROM data_mart.mv_clean_weekly_sales
GROUP BY 
	mv_clean_weekly_sales.platform, 
	mv_clean_weekly_sales.calendar_year, 
	3
),
shopify_sales AS (
SELECT 
	aggregated_sales.calendar_year,
	aggregated_sales.month_name,
	aggregated_sales.total_sales AS Shopify
FROM aggregated_sales
WHERE aggregated_sales.platform = 'Shopify'
),
retail_sales AS (
SELECT 
	aggregated_sales.calendar_year,
	aggregated_sales.month_name,
	aggregated_sales.total_sales AS Retail
FROM aggregated_sales
WHERE aggregated_sales.platform = 'Retail'
)
SELECT 
	shopify_sales.calendar_year,
	shopify_sales.month_name,
	ROUND(100*(shopify_sales.shopify)::NUMERIC/
		(shopify_sales.shopify + retail_sales.retail)::NUMERIC, 2) AS shopify_percentage,
	ROUND(100*(retail_sales.retail)::NUMERIC/
		(shopify_sales.shopify + retail_sales.retail)::NUMERIC, 2) AS retail_percentage
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
  calendar_year,
  demographic,
  SUM(SALES) AS yearly_sales,
  ROUND(
  100*(SUM(SALES))::NUMERIC/
  (SUM(SUM(SALES)) OVER (PARTITION BY calendar_year))::NUMERIC, 2) AS percentage
FROM data_mart.mv_clean_weekly_sales
GROUP BY
  calendar_year,
  demographic
ORDER BY
  calendar_year,
  demographic;

  
/*
	8) Which age_band and demographic values contribute the most to Retail sales?
*/
-- age band only
SELECT
  age_band,
  SUM(sales) AS total_sales,
  ROUND((100 * SUM(sales))::NUMERIC / (SUM(SUM(sales)) OVER (PARTITION BY platform)))::NUMERIC AS sales_percentage
FROM data_mart.mv_clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY platform, age_band
ORDER BY sales_percentage DESC;

-- demographic only
SELECT
  demographic,
  SUM(sales) AS total_sales,
  ROUND((100 * SUM(sales))::NUMERIC / 
  	(SELECT SUM(sales) FROM data_mart.mv_clean_weekly_sales WHERE platform = 'Retail')::NUMERIC) AS sales_percentage
FROM data_mart.mv_clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY demographic
ORDER BY sales_percentage DESC;


-- both age and demographic
SELECT
  age_band,
  demographic,
  SUM(sales) AS total_sales,
  ROUND((100 * SUM(sales))::NUMERIC /(SUM(SUM(sales)) OVER (PARTITION BY platform)))::NUMERIC AS sales_percentage
FROM data_mart.mv_clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY platform, demographic, age_band
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
  CAST(ROUND(AVG(sales)/AVG(transactions), 2) AS NUMERIC) AS avg_annual_transaction
FROM data_mart.mv_clean_weekly_sales
GROUP BY
  calendar_year,
  platform
ORDER BY
  calendar_year,
  platform;