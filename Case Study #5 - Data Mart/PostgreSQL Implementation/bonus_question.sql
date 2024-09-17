/*
	Which areas of the business have the highest negative impact in sales metrics performance in
	2020 for the 12 week before and after period?
*/
--By regions
WITH cte_12weeks AS (
  SELECT
    calendar_year,
    region,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales) / SUM(transactions) AS avg_transaction_size
  FROM data_mart.mv_clean_weekly_sales
  WHERE week_number BETWEEN 13 AND 36
    AND calendar_year = '2020'
  GROUP BY
    calendar_year,
    region,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    region,
    total_sales,
    LAG(total_sales) OVER (
      PARTITION BY region
      ORDER BY period_name DESC
    ) - total_sales AS sales_diff,
	ROUND(
	100*(LAG(total_sales) OVER (
      PARTITION BY region
      ORDER BY period_name DESC
    )-total_sales)::NUMERIC/(total_sales)::NUMERIC, 2) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_change;


--By platforms
WITH cte_12weeks AS (
  SELECT
    calendar_year,
    platform,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales) / SUM(transactions) AS avg_transaction_size
  FROM data_mart.mv_clean_weekly_sales
  WHERE week_number BETWEEN 13 AND 36
    AND calendar_year = '2020'
  GROUP BY
    calendar_year,
    platform,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    platform,
    total_sales,
    LAG(total_sales) OVER (
      PARTITION BY platform
      ORDER BY period_name DESC
    ) - total_sales AS sales_diff,
	ROUND(
	100*(LAG(total_sales) OVER (
      PARTITION BY platform
      ORDER BY period_name DESC
    )-total_sales)::NUMERIC/(total_sales)::NUMERIC, 2) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_change;


--By Age Bands
WITH cte_12weeks AS (
  SELECT
    calendar_year,
    age_band,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales) / SUM(transactions) AS avg_transaction_size
  FROM data_mart.mv_clean_weekly_sales
  WHERE week_number BETWEEN 13 AND 36
    AND calendar_year = '2020'
  GROUP BY
    calendar_year,
    age_band,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    age_band,
    total_sales,
    LAG(total_sales) OVER (
      PARTITION BY age_band
      ORDER BY period_name DESC
    ) - total_sales AS sales_diff,
	ROUND(
	100*(LAG(total_sales) OVER (
      PARTITION BY age_band
      ORDER BY period_name DESC
    )-total_sales)::NUMERIC/(total_sales)::NUMERIC, 2) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_change;


--By Demographic
WITH cte_12weeks AS (
  SELECT
    calendar_year,
    demographic,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales) / SUM(transactions) AS avg_transaction_size
  FROM data_mart.mv_clean_weekly_sales
  WHERE week_number BETWEEN 13 AND 36
    AND calendar_year = '2020'
  GROUP BY
    calendar_year,
    demographic,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    demographic,
    total_sales,
    LAG(total_sales) OVER (
      PARTITION BY demographic
      ORDER BY period_name DESC
    ) - total_sales AS sales_diff,
	ROUND(
	100*(LAG(total_sales) OVER (
      PARTITION BY demographic
      ORDER BY period_name DESC
    )-total_sales)::NUMERIC/(total_sales)::NUMERIC, 2) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_change;



--By Customer Type
WITH cte_12weeks AS (
  SELECT
    calendar_year,
    customer_type,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales) / SUM(transactions) AS avg_transaction_size
  FROM data_mart.mv_clean_weekly_sales
  WHERE week_number BETWEEN 13 AND 36
    AND calendar_year = '2020'
  GROUP BY
    calendar_year,
    customer_type,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    customer_type,
    total_sales,
    LAG(total_sales) OVER (
      PARTITION BY customer_type
      ORDER BY period_name DESC
    ) - total_sales AS sales_diff,
	ROUND(
	100*(LAG(total_sales) OVER (
      PARTITION BY customer_type
      ORDER BY period_name DESC
    )-total_sales)::NUMERIC/(total_sales)::NUMERIC, 2) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_change;