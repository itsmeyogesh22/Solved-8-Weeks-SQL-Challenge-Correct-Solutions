/*
	1) Using our filtered dataset by removing the interests with less than 6 months worth of data, 
	   which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
	   Only use the maximum composition value for each interest but you must keep the corresponding month_year.
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
SELECT
  month_year,
  interest_name,
  composition
FROM cte_ranked_interest
WHERE interest_rank = 1
ORDER BY composition DESC
LIMIT 10
),
cte_bottom_10 AS (
SELECT
  month_year,
  interest_name,
  composition
FROM cte_ranked_interest
WHERE interest_rank = 1
ORDER BY composition
LIMIT 10
),
final_output AS (
  SELECT * FROM cte_top_10
  UNION
  SELECT * FROM cte_bottom_10
)
SELECT * FROM final_output
ORDER BY composition DESC;


/*
	2) Which 5 interests had the lowest average ranking value?
*/
SELECT
  interest_map.interest_name,
  ROUND(AVG(interest_metrics.ranking), 1) AS average_ranking,
  COUNT(interest_map.interest_name) AS record_count
FROM fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id
WHERE interest_metrics.month_year IS NOT NULL
GROUP BY
  interest_map.interest_name
ORDER BY average_ranking
LIMIT 5;


/*
	3) Which 5 interests had the largest standard deviation in their percentile_ranking value?
*/
SELECT
  interest_metrics.interest_id,
  interest_map.interest_name,
  ROUND(STDDEV(interest_metrics.percentile_ranking::NUMERIC), 1) AS stddev_pc_ranking,
  MAX(interest_metrics.percentile_ranking) AS max_pc_ranking,
  MIN(interest_metrics.percentile_ranking) AS min_pc_ranking,
  COUNT(*) AS record_count
FROM fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id
WHERE interest_metrics.month_year IS NOT NULL
GROUP BY
  interest_metrics.interest_id,
  interest_map.interest_name
HAVING STDDEV(interest_metrics.percentile_ranking) IS NOT NULL
ORDER BY 3 DESC
LIMIT 5;


/*
	4) For the 5 interests found in the previous question 
	   - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? 
	   Can you describe what is happening for these 5 interests?
*/
SELECT
  interest_map.interest_name,
  interest_metrics.month_year,
  interest_metrics.ranking,
  interest_metrics.percentile_ranking,
  interest_metrics.composition
FROM fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id
  WHERE interest_metrics.interest_id IN (6260, 131, 150, 23, 20764)
ORDER BY
  ARRAY_POSITION(ARRAY[6260, 131, 150, 23, 20764]::INTEGER[], interest_metrics.interest_id),
  interest_metrics.month_year;
/*
	Popularity of these interests is decreasing from month to month. 
	For example, there were 93.28% of customers interested in TV Junkies in July 2018, 
	and observed 10.01% by August, 2019. A decline of around 80% in one year.
*/



/*
	5) How would you describe our customers in this segment based off their composition and ranking values? 
	   What sort of products or services should we show to these customers and what should we avoid?
*/
