/*
	1) What is the total sales for the 4 weeks before and after 2020-06-15? What is the 
	growth or reduction rate in actual values and percentage of sales?
*/
SELECT
  DISTINCT week_number
FROM data_mart.mv_clean_weekly_sales
WHERE week_date <= '2020-06-16';

SELECT DATE_PART('WEEK', '2020-06-16'::DATE)-12


WITH cte_2020 AS (
  SELECT
    CASE
      WHEN week_number BETWEEN 21 AND 24 THEN '2. After'
      WHEN week_number BETWEEN 25 AND 28 THEN '1. Before'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales) / SUM(transactions) AS avg_transaction_size
  FROM data_mart.mv_clean_weekly_sales
  WHERE week_number BETWEEN 21 and 28
    AND calendar_year = '2020'
  GROUP BY
    period_name
),
cte_calculations AS (
  SELECT
    period_name,
    LAG(total_sales) OVER (ORDER BY period_name) - total_sales  AS sales_diff,
    ROUND(
		100*(LAG(total_sales) OVER (ORDER BY period_name) - total_sales)::NUMERIC/
		((LAG(total_sales) OVER (ORDER BY period_name) + total_sales)/2)::NUMERIC,
		2) AS sales_change
  FROM cte_2020
)
SELECT
  sales_diff,
  sales_change
FROM cte_calculations
WHERE sales_diff IS NOT NULL;

--SELECT 100*(2318994169-2345878357)::NUMERIC/((2318994169+2345878357)/2)::NUMERIC


/*
	2) What about the entire 12 weeks before and after?
*/
WITH cte_2020 AS (
  SELECT
    CASE
      WHEN week_number BETWEEN 25 AND 36 THEN '12. After'
      WHEN week_number BETWEEN 13 AND 24 THEN '12. Before'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales) / SUM(transactions) AS avg_transaction_size
  FROM data_mart.mv_clean_weekly_sales
  WHERE week_number BETWEEN 13 and 36
    AND calendar_year = '2020'
  GROUP BY
    period_name
),
cte_calculations AS (
  SELECT
    period_name,
    LAG(total_sales) OVER (ORDER BY period_name) - total_sales  AS sales_diff,
    ROUND(
		100*(LAG(total_sales) OVER (ORDER BY period_name) - total_sales)::NUMERIC/
		((LAG(total_sales) OVER (ORDER BY period_name) + total_sales)/2)::NUMERIC,
		2) AS sales_change
  FROM cte_2020
)
SELECT
  sales_diff,
  sales_change
FROM cte_calculations
WHERE sales_diff IS NOT NULL;


/*
	3) How do the sale metrics for these 2 periods before and after compare with the 
	previous years in 2018 and 2019?
*/
--4 Weeks before and after given date
WITH cte_2020 AS (
  SELECT
  	calendar_year,
    CASE
      WHEN week_number BETWEEN 21 AND 24 THEN '2. After'
      WHEN week_number BETWEEN 25 AND 28 THEN '1. Before'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales) / SUM(transactions) AS avg_transaction_size
  FROM data_mart.mv_clean_weekly_sales
  WHERE week_number BETWEEN 21 and 28
  GROUP BY
  	calendar_year,
    period_name
),
cte_calculations AS (
  SELECT
  	calendar_year,
    period_name,
    LAG(total_sales) OVER (PARTITION BY calendar_year ORDER BY period_name) - total_sales  AS sales_diff,
    ROUND(
		100*(LAG(total_sales) OVER (PARTITION BY calendar_year ORDER BY period_name) - total_sales)::NUMERIC/
		((LAG(total_sales) OVER (PARTITION BY calendar_year ORDER BY period_name) + total_sales)/2)::NUMERIC,
		2) AS sales_change
  FROM cte_2020
)
SELECT
  calendar_year,
  sales_diff,
  sales_change
FROM cte_calculations
WHERE sales_diff IS NOT NULL;


--12 Weeks before and after given date
WITH cte_2020 AS (
  SELECT
  	calendar_year,
    CASE
		WHEN week_number BETWEEN 25 AND 36 THEN '12. After'
		WHEN week_number BETWEEN 13 AND 24 THEN '12. Before'
    END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales) / SUM(transactions) AS avg_transaction_size
  FROM data_mart.mv_clean_weekly_sales
  WHERE week_number BETWEEN 13 and 36
  GROUP BY
  	calendar_year,
    period_name
),
cte_calculations AS (
  SELECT
  	calendar_year,
    period_name,
    LAG(total_sales) OVER (PARTITION BY calendar_year ORDER BY period_name) - total_sales  AS sales_diff,
    ROUND(
		100*(LAG(total_sales) OVER (PARTITION BY calendar_year ORDER BY period_name) - total_sales)::NUMERIC/
		((LAG(total_sales) OVER (PARTITION BY calendar_year ORDER BY period_name) + total_sales)/2)::NUMERIC,
		2) AS sales_change
  FROM cte_2020
)
SELECT
  calendar_year,
  sales_diff,
  sales_change
FROM cte_calculations
WHERE sales_diff IS NOT NULL;