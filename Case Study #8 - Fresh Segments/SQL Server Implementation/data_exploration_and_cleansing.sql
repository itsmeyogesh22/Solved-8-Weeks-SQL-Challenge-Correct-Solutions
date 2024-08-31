USE [8 Weeks SQL Challenge];

/*
	1) Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data 
	   type with the start of the month.
*/
UPDATE fresh_segments.interest_metrics
SET month_year = DATEFROMPARTS(_year, _month, CAST(1 AS INT));

ALTER TABLE fresh_segments.interest_metrics
	ALTER COLUMN month_year DATETIME2;

DELETE FROM fresh_segments.interest_metrics
WHERE 
	month_year IS NULL 
	OR 
	interest_id IS NULL;



/*
	2) What is count of records in the fresh_segments.interest_metrics for each month_year value sorted 
	   in chronological order (earliest to latest) with the null values appearing first?
*/
SELECT 
	CAST(interest_metrics.month_year AS DATE) AS month_year,
	COUNT(*) AS total_records
FROM fresh_segments.interest_metrics
GROUP BY interest_metrics.month_year
ORDER BY 1;


/*
	3) What do you think we should do with these null values in the fresh_segments.interest_metrics
*/
DELETE FROM fresh_segments.interest_metrics
WHERE 
	month_year IS NULL 
	OR 
	interest_id IS NULL;

SELECT *
FROM fresh_segments.interest_metrics
WHERE interest_metrics.interest_id IS NULL;



/*
	4) How many interest_id values exist in the fresh_segments.interest_metrics table but not in the 
	   fresh_segments.interest_map table? What about the other way around?
*/
SELECT
  COUNT(DISTINCT interest_metrics.interest_id) AS all_interest_metric,
  COUNT(DISTINCT interest_map.id) AS all_interest_map,
  COUNT(CASE WHEN interest_map.id IS NULL THEN interest_metrics.interest_id ELSE NULL END) AS not_in_map,
  COUNT(CASE WHEN interest_metrics.interest_id IS NULL THEN interest_map.id ELSE NULL END)  AS not_in_metrics
FROM fresh_segments.interest_metrics
FULL OUTER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id;


/*
	5) Summarise the id values in the fresh_segments.interest_map by its total record count in this table.
*/
WITH cte_id_records AS (
SELECT
  id,
  COUNT(*) AS record_count
FROM fresh_segments.interest_map
GROUP BY id
)
SELECT
  record_count,
  COUNT(DISTINCT id) AS id_count
FROM cte_id_records
GROUP BY record_count;



/*
	6) What sort of table join should we perform for our analysis and why? 
	   Check your logic by checking the rows where interest_id = 21246 in your joined output 
	   and include all columns from fresh_segments.interest_metrics and all columns 
	   from fresh_segments.interest_map except from the id column.
*/
SELECT 
	interest_metrics._month,
	interest_metrics._year,
	CAST(interest_metrics.month_year AS DATE) AS month_year,
	interest_metrics.interest_id,
	interest_metrics.composition,
	interest_metrics.index_value,
	interest_metrics.ranking,
	interest_metrics.percentile_ranking,
	interest_map.interest_name,
	interest_map.interest_summary,
	interest_map.created_at,
	interest_map.last_modified
FROM fresh_segments.interest_map
LEFT JOIN fresh_segments.interest_metrics
	ON interest_map.id = interest_metrics.interest_id
WHERE interest_metrics.interest_id = 21246;



/*
	7) Are there any records in your joined table where the month_year value is 
	   before the created_at value from the fresh_segments.interest_map table? 
	   Do you think these values are valid and why?
*/
WITH combined_dataset AS (
SELECT 
	interest_metrics._month,
	interest_metrics._year,
	interest_metrics.month_year,
	interest_metrics.interest_id,
	interest_metrics.composition,
	interest_metrics.index_value,
	interest_metrics.ranking,
	interest_metrics.percentile_ranking,
	interest_map.interest_name,
	interest_map.interest_summary,
	interest_map.created_at,
	interest_map.last_modified
FROM fresh_segments.interest_map
LEFT JOIN fresh_segments.interest_metrics
	ON interest_map.id = interest_metrics.interest_id
)
SELECT 
	COUNT(*)
FROM combined_dataset
WHERE combined_dataset.month_year < combined_dataset.created_at;

/*
	Explanation: 'month_year' of each interest metric was created using only month and year,
	therefore actual day of the month for each interest_metric value is unknown. However,
	month value in both month_year and created_at is same.
	month_year < created_at does not imply that records in interest_metrics were created beofre
	created_at in interest_map table on 'day of month' basis, but rather on the basis of 'month'
	and 'year'.
	Hence, we can say that these dates are valid.
*/

