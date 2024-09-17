USE [8 Weeks SQL Challenge];

/*
	In a single query, perform the following operations and generate a new table in the data_mart schema named
	clean_weekly_sales:
	
		1) Convert the week_date to a DATE format.
		2) Add a week_number as the second column for each week_date value, 
		   for example any value from the 1st of January to 7th of January will be 1, 
		   8th to 14th will be 2 etc.
		3) Add a month_number with the calendar month for each week_date value as the 3rd column.
		4) Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values.
		5) Add a new column called age_band after the original segment column using the following 
		   mapping on the number inside the segment value.
		6) Add a new demographic column using the following mapping for the first letter in the segment values:
			
			+---------+-------------+
			| segment | demographic |
			+---------+-------------+
			| C       | Couples     |
			| F       | Families    |
			+---------+-------------+
		7) Ensure all null string values with an "unknown" string value in the original segment column as well as 
		   the new age_band and demographic columns.
		8) Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal 
		   places for each record.


			Table: clean_weekly_sales
			+-----------------+-----------+
			| column_name     | data_type |
			+-----------------+-----------+
			| week_date       | date      |
			| week_number     | int       |
			| month_number    | int       |
			| calendar_year   | int       |
			| region          | varchar   |
			| platform        | varchar   |
			| segment         | varvhar   |
			| age_band        | varvhar   |
			| demographic     | varvhar   |
			| customer_type   | varvhar   |
			| transactions    | numeric   |
			| sales           | numeric   |
			| avg_transaction | numeric   |
			+-----------------+-----------+


*/
DROP VIEW IF EXISTS data_mart.mv_clean_weekly_sales;
CREATE VIEW data_mart.mv_clean_weekly_sales
AS
WITH date_cte AS (
SELECT *,
	CAST(REPLACE(LEFT(CONVERT(VARCHAR, week_date, 20), 2), '/', '') AS INT) AS week_day,
	CAST(REPLACE(LEFT(RIGHT(CONVERT(VARCHAR, week_date, 20), 4), 2), '/', '') AS INT) AS week_month,
	CAST(REPLACE(REPLACE(RIGHT(CONVERT(VARCHAR, week_date, 20), 2), '/', ''), '00', '20') AS INT) + 2000 AS week_year
FROM data_mart.weekly_sales
WHERE CONVERT(VARCHAR, week_date, 20) IS NOT NULL
)
SELECT 
	DATEFROMPARTS(week_year, date_cte.week_month, (date_cte.week_day)) AS week_date,
	DATEPART(WEEK, DATEFROMPARTS(week_year, date_cte.week_month, (date_cte.week_day))) AS week_number,
	DATEPART(MONTH, DATEFROMPARTS(week_year, date_cte.week_month, (date_cte.week_day))) AS month_number,
	DATEPART(YEAR, DATEFROMPARTS(week_year, date_cte.week_month, (date_cte.week_day))) AS calendar_year,
	date_cte.region,
	date_cte.platform,
	CASE
		WHEN date_cte.segment IN (NULL, 'null', '') THEN 'unknown'
		ELSE date_cte.segment
		END AS segment,
	CASE 
		WHEN RIGHT(date_cte.segment, 1) = '1' THEN CONCAT_WS(' ', 'Young', 'Adults')
		WHEN RIGHT(date_cte.segment, 1) = '2' THEN CONCAT_WS(' ', 'Middle', 'Aged')
		WHEN RIGHT(date_cte.segment, 1) = '3' OR RIGHT(date_cte.segment, 1) = '4' THEN CONCAT_WS('', 'Retirees', '')
		ELSE CONCAT('unknown', '')
	END AS age_band,
	CASE 
		WHEN LEFT(date_cte.segment, 1) = 'C' THEN CONCAT('', 'Couples')
		WHEN LEFT(date_cte.segment, 1) = 'F' THEN CONCAT('', 'Families')
		ELSE CONCAT('unknown', '')
	END AS demographic,
	date_cte.customer_type,
	date_cte.transactions,
	date_cte.sales,
	CAST(
		(date_cte.sales/date_cte.transactions) 
		AS DECIMAL(10, 2)
		) AS avg_transaction
FROM date_cte;