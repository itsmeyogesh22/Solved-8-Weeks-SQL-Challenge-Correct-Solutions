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
DROP MATERIALIZED VIEW IF EXISTS data_mart.mv_clean_weekly_sales;
CREATE MATERIALIZED VIEW data_mart.mv_clean_weekly_sales
AS
SELECT 
	TO_DATE(weekly_sales.week_date, 'dd/mm/yy') AS week_date,
	DATE_PART('WEEK', TO_DATE(weekly_sales.week_date, 'dd/mm/yy')) AS week_number,
	DATE_PART('MONTH', TO_DATE(weekly_sales.week_date, 'dd/mm/yy')) AS month_number,
	DATE_PART('YEAR', TO_DATE(weekly_sales.week_date, 'dd/mm/yy')) AS calendar_year,
	weekly_sales.region,
	weekly_sales.platform,
	CASE
		WHEN weekly_sales.segment IS NULL OR weekly_sales.segment = 'null' THEN 'unknown'
		ELSE weekly_sales.segment
		END AS segment,
	CASE 
		WHEN RIGHT(weekly_sales.segment, 1) = '1' THEN CONCAT_WS(' ', 'Young', 'Adults')
		WHEN RIGHT(weekly_sales.segment, 1) = '2' THEN CONCAT_WS(' ', 'Middle', 'Aged')
		WHEN RIGHT(weekly_sales.segment, 1) = '3'  OR RIGHT(weekly_sales.segment, 1) = '4' THEN CONCAT_WS('', 'Retirees', '')
		ELSE CONCAT('unknown', '')::TEXT
	END AS age_band,
	CASE 
		WHEN LEFT(weekly_sales.segment, 1) = 'C' THEN CONCAT('', 'Couples')
		WHEN LEFT(weekly_sales.segment, 1) = 'F' THEN CONCAT('', 'Families')
		ELSE CONCAT('unknown', '')::TEXT
	END AS demographic,
	weekly_sales.customer_type,
	weekly_sales.transactions,
	weekly_sales.sales,
	CAST(
		(weekly_sales.sales::NUMERIC/weekly_sales.transactions::NUMERIC) 
		AS DECIMAL(10, 2)
		) AS avg_transaction
FROM data_mart.weekly_sales;