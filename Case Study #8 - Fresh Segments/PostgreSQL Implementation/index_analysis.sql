/*
	1) What is the top 10 interests by the average composition for each month?
*/
WITH cte_index_composition AS (
  SELECT
    interest_metrics.month_year,
    interest_map.interest_name,
    ((interest_metrics.composition/interest_metrics.index_value)::NUMERIC) AS index_composition,
    RANK() OVER (
      PARTITION BY interest_metrics.month_year
      ORDER BY ((interest_metrics.composition/interest_metrics.index_value)::NUMERIC) DESC) AS index_rank
FROM fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
	ON interest_metrics.interest_id = interest_map.id
)
SELECT *
FROM cte_index_composition
WHERE index_rank <= 10
ORDER BY month_year;


/*
	2) For all of these top 10 interests - which interest appears the most often?
*/
WITH cte_index_composition AS (
  SELECT
    interest_metrics.month_year,
    interest_map.interest_name,
    ((interest_metrics.composition/interest_metrics.index_value)::NUMERIC) AS index_composition,
    RANK() OVER (
      PARTITION BY interest_metrics.month_year
      ORDER BY ((interest_metrics.composition/interest_metrics.index_value)::NUMERIC) DESC) AS index_rank
FROM fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
	ON interest_metrics.interest_id = interest_map.id
)
SELECT
  interest_name,
  COUNT(*) AS appearances
FROM cte_index_composition
WHERE index_rank <= 10
GROUP BY interest_name
ORDER BY appearances DESC
LIMIT 3;


/*
	3) What is the average of the average composition for the top 10 interests for each month?
*/
WITH cte_index_composition AS (
  SELECT
    interest_metrics.month_year,
    interest_map.interest_name,
    ((interest_metrics.composition/interest_metrics.index_value)::NUMERIC) AS index_composition,
    RANK() OVER (
      PARTITION BY interest_metrics.month_year
      ORDER BY ((interest_metrics.composition/interest_metrics.index_value)::NUMERIC) DESC) AS index_rank
FROM fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
	ON interest_metrics.interest_id = interest_map.id
)
SELECT
  month_year,
  ROUND(AVG(index_composition),2) AS avg_index_composition  -- you may need to fix this...
FROM cte_index_composition
WHERE index_rank <= 10
GROUP BY month_year
ORDER BY month_year;


/*
	4) What is the 3 month rolling average of the max average composition value 
	   from September 2018 to August 2019 and include the previous top ranking?
*/
WITH cte_index_composition AS (
  SELECT
    interest_metrics.month_year,
    interest_map.interest_name,
    ((interest_metrics.composition/interest_metrics.index_value)::NUMERIC) AS index_composition,
    RANK() OVER (
      PARTITION BY interest_metrics.month_year
      ORDER BY ((interest_metrics.composition/interest_metrics.index_value)::NUMERIC) DESC) AS index_rank
FROM fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
	ON interest_metrics.interest_id = interest_map.id
),
final_output AS (
SELECT
  month_year,
  interest_name,
  ROUND(index_composition, 2) AS max_index_composition,
  ROUND(
    AVG(index_composition) OVER (
      ORDER BY month_year
      RANGE BETWEEN '2 MONTHS' PRECEDING AND CURRENT ROW
    ),
    2
  ) AS "3_month_moving_avg",
  LAG(interest_name || ': ' || ROUND(index_composition, 2)) OVER (ORDER BY month_year) AS "1_month_ago",
  LAG(interest_name || ': ' || ROUND(index_composition, 2), 2) OVER (ORDER BY month_year) AS "2_months_ago"
FROM cte_index_composition
WHERE index_rank = 1
)
SELECT *
FROM final_output
WHERE "2_months_ago" IS NOT NULL
ORDER BY month_year;


/*
	5) Provide a possible reason why the max average composition might change from month to month? 
	   Could it signal something is not quite right with the overall business model for Fresh Segments?
*/
/*
Possible reason: seasonality
User's interests may have changed, and the users are less interested in few selected topics now. 
Users "burnt out", and the index composition value has decreased. 

Suggestion: some users (or interests) need to be transferred to another segment. 
Some interests keep high index_composition value, it possibly means that these topics are always in the users' interest area.
*/