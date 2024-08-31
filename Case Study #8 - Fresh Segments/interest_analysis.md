 <div id="box-shadow-object"  
     align="left"
     style="
            webkit-box-shadow: 10px 10px 0px 0px rgba(0,0,0,0.52);
            moz-box-shadow: 10px 10px 0px 0px rgba(0,0,0,0.52);
            box-shadow: rgba(0, 0, 0, 0.69) 10px 10px 0px 3px; 
            background-color: rgb(243, 116, 99);">
<div id="box-shadow-panel">
    <pre align = "left" class = 'w-para' 
       style = "
                font-family: Consolas,monaco,monospace; 
                padding: 16px 17px;
                border: 4px solid #000;
                background-color: rgb(232, 219, 217);
                color: #000;
                font-size: 2rem;
                font-weight: 60;
                margin-left: 15px;
                margin-right: 15px;
                margin-bottom: 10px; 
               ">
<h1 align = "left" style="list-style: none;"> Interest Analysis</h1>
</pre>
</div>
<div id="box-shadow-object"  
     align="left"
     style="
            webkit-box-shadow: 10px 10px 0px 0px rgba(0,0,0,0.52);
            moz-box-shadow: 10px 10px 0px 0px rgba(0,0,0,0.52);
            box-shadow: rgba(0, 0, 0, 0.69) 10px 10px 0px 3px; 
            background-color: rgb(243, 116, 99);">
<div id="box-shadow-panel">
    <pre align = "left" class = 'w-para' 
       style = "
                font-family: Consolas,monaco,monospace; 
                padding: 16px 17px 15px 15px;
                border: 4px solid #000;
                background-color: rgb(232, 219, 217);
                color: #000;
                font-size: 2rem;
                font-weight: 60;
                margin-left: 15px;
                margin-right: 15px;
                margin-bottom: 10px; 
               ">
<br>
<b>1) Which interests have been present in all month_year dates in our dataset?</b>
<br>
<b>2) Using this same total_months measure
-calculate the cumulative percentage of all records starting at 14 months 
-which total_months value passes the 90% cumulative percentage value?</b>
<br>
<b>3) If we were to remove all interest_id values which are lower than the total_months value we found in the 
previous question - how many total data points would we be removing?</b>
<br>
<b>4) Does this decision make sense to remove these data points from a business perspective? 
Use an example where there are all 14 months present to a removed interest example for your arguments 
-think about what it means to have less months present from a segment perspective.</b>
<br>
<b>5) If we include all of our interests regardless of their counts 
-how many unique interests are there for each month?</b>
<br>
</pre>
</div>
  
<h4>1) Which interests have been present in all month_year dates in our dataset?</h4>

```sql
WITH month_level_agg AS (
SELECT 
  interest_metrics.interest_id,
  COUNT(interest_metrics._month) AS total_months
FROM fresh_segments.interest_metrics
GROUP BY 1
)
SELECT 
  month_level_agg.total_months,
  COUNT(month_level_agg.interest_id) AS interest_count
FROM month_level_agg
GROUP BY 1
ORDER BY 1 DESC;
```
| total_months | interest_count |
|--------------|----------------|
| 14           | 480            |
| 13           | 82             |
| 12           | 65             |
| 11           | 94             |
| 10           | 86             |
| 9            | 95             |
| 8            | 67             |
| 7            | 90             |
| 6            | 33             |
| 5            | 38             |
| 4            | 32             |
| 3            | 15             |
| 2            | 12             |
| 1            | 13             |

<br></br>
<h4>2) Using this same total_months measure<br>
-calculate the cumulative percentage of all records starting at 14 months<br> 
-which total_months value passes the 90% cumulative percentage value?</h4>

```sql
WITH month_level_agg AS (
SELECT 
  interest_metrics.interest_id,
  COUNT(interest_metrics._month) AS total_months
FROM fresh_segments.interest_metrics
GROUP BY 1
),
cte_interest_counts AS (
SELECT 
  month_level_agg.total_months,
  COUNT(month_level_agg.interest_id) AS interest_count
FROM month_level_agg
GROUP BY 1
ORDER BY 1 DESC
)
SELECT 
  cte_interest_counts.total_months,
  ROUND(
  (100*SUM(cte_interest_counts.interest_count) OVER (ORDER BY cte_interest_counts.total_months DESC))::NUMERIC/
  (SUM(cte_interest_counts.interest_count) OVER ())::NUMERIC, 
  2) AS cumulative_percentage
FROM cte_interest_counts;
```
| total_months | cumulative_percentage |
|--------------|-----------------------|
| 14           | 39.93                 |
| 13           | 46.76                 |
| 12           | 52.16                 |
| 11           | 59.98                 |
| 10           | 67.14                 |
| 9            | 75.04                 |
| 8            | 80.62                 |
| 7            | 88.10                 |
| 6            | 90.85                 |
| 5            | 94.01                 |
| 4            | 96.67                 |
| 3            | 97.92                 |
| 2            | 98.92                 |
| 1            | 100.00                |

<br></br>
<h4>3) If we were to remove all interest_id values which are lower than the total_months value we found in the 
previous question - how many total data points would we be removing?</h4>

```sql
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
```
| removed_rows |
|--------------|
| 400          |

<br></br>
<h4>4) Does this decision make sense to remove these data points from a business perspective?<br>
Use an example where there are all 14 months present to a removed interest example for your arguments <br>
-think about what it means to have less months present from a segment perspective./h4>

```sql
SELECT
  T1.month_year,
  COUNT(interest_id) AS number_of_excluded_interests,
  number_of_included_interests,
  ROUND(
    100 *(
      COUNT(interest_id) / number_of_included_interests :: numeric
    ),
    1
  ) AS percent_of_excluded
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
      AND interest_id :: int IN (
        SELECT
          interest_id :: int
        FROM
          fresh_segments.interest_metrics
        GROUP BY
          1
        HAVING
          COUNT(interest_id) > 5
      )
    GROUP BY
      1
  ) i ON T1.month_year = i.month_year
WHERE
  T1.month_year IS NOT NULL
  AND interest_id :: int IN (
    SELECT
      interest_id :: int
    FROM
      fresh_segments.interest_metrics
    GROUP BY
      1
    having
      COUNT(interest_id) < 6
  )
GROUP BY 1, 3
ORDER BY 1;
```
| month_year   | number_of_excluded_interests | number_of_included_interests | percent_of_excluded |
|--------------|------------------------------|------------------------------|---------------------|
| "2018-07-01" | 20                           | 709                          | 2.8                 |
| "2018-08-01" | 15                           | 752                          | 2.0                 |
| "2018-09-01" | 6                            | 774                          | 0.8                 |
| "2018-10-01" | 4                            | 853                          | 0.5                 |
| "2018-11-01" | 3                            | 925                          | 0.3                 |
| "2018-12-01" | 9                            | 986                          | 0.9                 |
| "2019-01-01" | 7                            | 966                          | 0.7                 |
| "2019-02-01" | 49                           | 1072                         | 4.6                 |
| "2019-03-01" | 58                           | 1078                         | 5.4                 |
| "2019-04-01" | 64                           | 1035                         | 6.2                 |
| "2019-05-01" | 30                           | 827                          | 3.6                 |
| "2019-06-01" | 20                           | 804                          | 2.5                 |
| "2019-07-01" | 28                           | 836                          | 3.3                 |
| "2019-08-01" | 87                           | 1062                         | 8.2                 |

<br></br>
<h4>5) If we include all of our interests regardless of their counts<br>
-how many unique interests are there for each month?</h4>

```sql
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
```
| month_year   | interest_name                          | composition |
|--------------|----------------------------------------|-------------|
| "2018-12-01" | "Work Comes First Travelers"           | 21.2        |
| "2018-07-01" | "Gym Equipment Owners"                 | 18.82       |
| "2018-07-01" | "Furniture Shoppers"                   | 17.44       |
| "2018-07-01" | "Luxury Retail Shoppers"               | 17.19       |
| "2018-10-01" | "Luxury Boutique Hotel Researchers"    | 15.15       |
| "2018-12-01" | "Luxury Bedding Shoppers"              | 15.05       |
| "2018-07-01" | "Shoe Shoppers"                        | 14.91       |
| "2018-07-01" | "Cosmetics and Beauty Shoppers"        | 14.23       |
| "2018-07-01" | "Luxury Hotel Guests"                  | 14.1        |
| "2018-07-01" | "Luxury Retail Researchers"            | 13.97       |
| "2018-07-01" | "Readers of Jamaican Content"          | 1.86        |
| "2019-02-01" | "Automotive News Readers"              | 1.84        |
| "2018-07-01" | "Comedy Fans"                          | 1.83        |
| "2019-08-01" | "World of Warcraft Enthusiasts"        | 1.82        |
| "2018-08-01" | "Miami Heat Fans"                      | 1.81        |
| "2018-07-01" | "Online Role Playing Game Enthusiasts" | 1.73        |
| "2019-08-01" | "Hearthstone Video Game Fans"          | 1.66        |
| "2018-09-01" | "Scifi Movie and TV Enthusiasts"       | 1.61        |
| "2018-09-01" | "Action Movie and TV Enthusiasts"      | 1.59        |
