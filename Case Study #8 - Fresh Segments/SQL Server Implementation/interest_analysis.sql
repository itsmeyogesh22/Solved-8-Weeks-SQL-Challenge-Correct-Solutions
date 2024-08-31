USE [8 Weeks SQL Challenge];


/*
	1) Which interests have been present in all month_year dates in our dataset?
*/
WITH month_level_agg AS (
SELECT 
	interest_metrics.interest_id,
	COUNT(interest_metrics._month) AS total_months
FROM fresh_segments.interest_metrics
GROUP BY interest_metrics.interest_id
)
SELECT 
	month_level_agg.total_months,
	COUNT(month_level_agg.interest_id) AS interest_count
FROM month_level_agg
GROUP BY month_level_agg.total_months
ORDER BY 1 DESC;


/*
	2) Using this same total_months measure
	   - calculate the cumulative percentage of all records starting at 14 months 
	   - which total_months value passes the 90% cumulative percentage value?
*/
WITH month_level_agg AS (
SELECT 
	interest_metrics.interest_id,
	COUNT(interest_metrics._month) AS total_months
FROM fresh_segments.interest_metrics
GROUP BY interest_metrics.interest_id
),
cte_interest_counts AS (
SELECT 
	month_level_agg.total_months,
	COUNT(month_level_agg.interest_id) AS interest_count
FROM month_level_agg
GROUP BY month_level_agg.total_months
)
SELECT 
	cte_interest_counts.total_months,
	ROUND(
	(100*SUM(cte_interest_counts.interest_count) OVER (ORDER BY cte_interest_counts.total_months DESC))/
	(SUM(cte_interest_counts.interest_count) OVER ()), 
	2) AS cumulative_percentage
FROM cte_interest_counts;


/*
	3) If we were to remove all interest_id values which are lower than the total_months value we found in the 
	   previous question - how many total data points would we be removing?
*/
WITH cte_removed_interests AS (
SELECT
  interest_id
FROM fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) >= 6
)
SELECT
  COUNT(*) AS removed_rows
FROM fresh_segments.interest_metrics 
WHERE NOT EXISTS (
  SELECT 1
  FROM cte_removed_interests
  WHERE interest_metrics.interest_id = cte_removed_interests.interest_id
);


/*
	4) Does this decision make sense to remove these data points from a business perspective? 
	   Use an example where there are all 14 months present to a removed interest example for your arguments 
	   - think about what it means to have less months present from a segment perspective.
*/
SELECT
  CAST(T1.month_year AS DATE) AS month_year,
  COUNT(interest_id) AS number_of_excluded_interests,
  number_of_included_interests,
  CAST(
    (100*CAST(COUNT(interest_id) AS NUMERIC) / CAST(number_of_included_interests AS NUMERIC)) AS DECIMAL(5, 2)) AS percent_of_excluded
FROM
  fresh_segments.interest_metrics AS T1
  JOIN (
    SELECT
      month_year,
      COUNT(interest_id) AS number_of_included_interests
    FROM
      fresh_segments.interest_metrics AS T1
    WHERE
      month_year IS NOT NULL
      AND interest_id IN (
        SELECT
          interest_id
        FROM
          fresh_segments.interest_metrics
        GROUP BY
          interest_id
        HAVING
          COUNT(interest_id) > 5
      )
    GROUP BY
      month_year
  ) i ON T1.month_year = i.month_year
WHERE
  T1.month_year IS NOT NULL
  AND interest_id IN (
    SELECT
      interest_id 
    FROM
      fresh_segments.interest_metrics
    GROUP BY
      interest_id
    having
      COUNT(interest_id) < 6
  )
GROUP BY 
	T1.month_year, 
	number_of_included_interests
ORDER BY 1;



/*
	5) If we include all of our interests regardless of their counts 
	   - how many unique interests are there for each month?
*/
WITH cte_ranked_interest AS (
SELECT
  interest_metrics.month_year,
  interest_map.interest_name,
  interest_metrics.composition,
  RANK() OVER (
    PARTITION BY interest_map.interest_name
    ORDER BY composition DESC
  ) AS interest_rank
FROM fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id
WHERE interest_metrics.month_year IS NOT NULL
),
cte_top_10 AS (
SELECT TOP 10
  CAST(month_year AS DATE) AS month_year,
  interest_name,
  CAST(composition AS DECIMAL(5, 2)) AS composition
FROM cte_ranked_interest
WHERE interest_rank = 1
ORDER BY composition DESC
),
cte_bottom_10 AS (
SELECT
  TOP 10
  CAST(month_year AS DATE) AS month_year,
  interest_name,
  CAST(composition AS DECIMAL(5, 2)) AS composition
FROM cte_ranked_interest
WHERE interest_rank = 1
ORDER BY composition ASC
),
final_output AS (
  SELECT * FROM cte_top_10
  UNION
  SELECT * FROM cte_bottom_10
)
SELECT * 
FROM final_output
ORDER BY composition DESC;