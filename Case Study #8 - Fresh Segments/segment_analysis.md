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
<h1 align = "left" style="list-style: none;"> Segment Analysis</h1>
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
<b>1) Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 
and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition 
value for each interest but you must keep the corresponding month_year.</b>
<br>
<b>2) Which 5 interests had the lowest average ranking value?</b>
<br>
<b>3) Which 5 interests had the largest standard deviation in their percentile_ranking value?</b>
<br>
<b>4) For the 5 interests found in the previous question 
- what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? 
Can you describe what is happening for these 5 interests?</b>
<br>
</pre>
</div>


<h4>1) Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 
and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition 
value for each interest but you must keep the corresponding month_year.</h4>

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

| month_year | interest_name                        | composition |
|------------|--------------------------------------|-------------|
| 2018-12-01 | Work Comes First Travelers           | 21.2        |
| 2018-07-01 | Gym Equipment Owners                 | 18.82       |
| 2018-07-01 | Furniture Shoppers                   | 17.44       |
| 2018-07-01 | Luxury Retail Shoppers               | 17.19       |
| 2018-10-01 | Luxury Boutique Hotel Researchers    | 15.15       |
| 2018-12-01 | Luxury Bedding Shoppers              | 15.05       |
| 2018-07-01 | Shoe Shoppers                        | 14.91       |
| 2018-07-01 | Cosmetics and Beauty Shoppers        | 14.23       |
| 2018-07-01 | Luxury Hotel Guests                  | 14.1        |
| 2018-07-01 | Luxury Retail Researchers            | 13.97       |
| 2018-07-01 | Readers of Jamaican Content          | 1.86        |
| 2019-02-01 | Automotive News Readers              | 1.84        |
| 2018-07-01 | Comedy Fans                          | 1.83        |
| 2019-08-01 | World of Warcraft Enthusiasts        | 1.82        |
| 2018-08-01 | Miami Heat Fans                      | 1.81        |
| 2018-07-01 | Online Role Playing Game Enthusiasts | 1.73        |
| 2019-08-01 | Hearthstone Video Game Fans          | 1.66        |
| 2018-09-01 | Scifi Movie and TV Enthusiasts       | 1.61        |
| 2018-09-01 | Action Movie and TV Enthusiasts      | 1.59        |
| 2019-03-01 | The Sims Video Game Fans             | 1.57        |

<br></br>
<h4>2) Which 5 interests had the lowest average ranking value?</h4>

```sql
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
```

| interest_name                  | average_ranking | record_count |
|--------------------------------|-----------------|--------------|
| Winter Apparel Shoppers        | 1.0             | 9            |
| Fitness Activity Tracker Users | 4.1             | 9            |
| Men's Shoe Shoppers            | 5.9             | 14           |
| Elite Cycling Gear Shoppers    | 7.8             | 5            |
| Shoe Shoppers                  | 9.4             | 14           |

<br></br>
<h4>3) Which 5 interests had the largest standard deviation in their percentile_ranking value?</h4>

```sql
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
```

| interest_id | interest_name                          | stddev_pc_ranking | max_pc_ranking | min_pc_ranking | record_count |
|-------------|----------------------------------------|-------------------|----------------|----------------|--------------|
| 6260        | Blockbuster Movie Fans                 | 41.3              | 60.63          | 2.26           | 2            |
| 131         | Android Fans                           | 30.7              | 75.03          | 4.84           | 5            |
| 150         | TV Junkies                             | 30.4              | 93.28          | 10.01          | 5            |
| 23          | Techies                                | 30.2              | 86.69          | 7.92           | 6            |
| 20764       | Entertainment Industry Decision Makers | 29.0              | 86.15          | 11.23          | 6            |

<br></br>
<h4>4) For the 5 interests found in the previous question 
- what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? 
Can you describe what is happening for these 5 interests?</h4>

```sql
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
```
| interest_name                          | month_year | ranking | percentile_ranking | composition |
|----------------------------------------|------------|---------|--------------------|-------------|
| Blockbuster Movie Fans                 | 2018-07-01 | 287     | 60.63              | 5.27        |
| Blockbuster Movie Fans                 | 2019-08-01 | 1123    | 2.26               | 1.83        |
| Android Fans                           | 2018-07-01 | 182     | 75.03              | 5.09        |
| Android Fans                           | 2018-08-01 | 684     | 10.82              | 1.77        |
| Android Fans                           | 2019-02-01 | 1058    | 5.62               | 1.85        |
| Android Fans                           | 2019-03-01 | 1081    | 4.84               | 1.72        |
| Android Fans                           | 2019-08-01 | 1092    | 4.96               | 1.91        |
| TV Junkies                             | 2018-07-01 | 49      | 93.28              | 5.3         |
| TV Junkies                             | 2018-08-01 | 481     | 37.29              | 1.7         |
| TV Junkies                             | 2018-10-01 | 430     | 49.82              | 2.34        |
| TV Junkies                             | 2018-12-01 | 619     | 37.79              | 1.72        |
| TV Junkies                             | 2019-08-01 | 1034    | 10.01              | 1.94        |
| Techies                                | 2018-07-01 | 97      | 86.69              | 5.41        |
| Techies                                | 2018-08-01 | 530     | 30.9               | 1.9         |
| Techies                                | 2018-09-01 | 594     | 23.85              | 1.6         |
| Techies                                | 2019-02-01 | 1015    | 9.46               | 1.89        |
| Techies                                | 2019-03-01 | 1026    | 9.68               | 1.91        |
| Techies                                | 2019-08-01 | 1058    | 7.92               | 1.9         |
| Entertainment Industry Decision Makers | 2018-07-01 | 101     | 86.15              | 5.85        |
| Entertainment Industry Decision Makers | 2018-08-01 | 644     | 16.04              | 1.78        |
| Entertainment Industry Decision Makers | 2018-10-01 | 697     | 18.67              | 2.01        |
| Entertainment Industry Decision Makers | 2019-02-01 | 873     | 22.12              | 2.11        |
| Entertainment Industry Decision Makers | 2019-03-01 | 1005    | 11.53              | 1.97        |
| Entertainment Industry Decision Makers | 2019-08-01 | 1020    | 11.23              | 1.91        |

<br></br>
<div id="box-shadow-object"  
     align="right"
     style="
            webkit-box-shadow: 10px 10px 0px 0px rgba(0,0,0,0.52);
            moz-box-shadow: 10px 10px 0px 0px rgba(0,0,0,0.52);
            box-shadow: rgba(0, 0, 0, 0.69) 10px 10px 0px 3px; 
            background-color: rgb(243, 116, 99);
            padding-right: -5px;">
<div align="right" id="box-shadow-panel">
    <pre align = "left" class = 'w-para' 
       style = "
                font-family: Consolas,monaco,monospace; 
                padding: 16px 17px;
                padding-right: 0px;
                border: 4px solid #000;
                background-color: rgb(232, 219, 217);
                color: #000;
                font-size: 2rem;
                font-weight: 60;
                margin-left: 15px;
                margin-right: 0px;
                margin-bottom: 10px; 
               ">
    <h1 align = "left" style="list-style: none;"> Further Insights:</h1>
Popularity of these interests is decreasing from month to month. For example, there were 93.28% of customers interested 
in TV Junkies in July 2018, and observed 10.01% by August, 2019. A decline of around 80% in one year.
<br></br>
    </pre>
    <br>
    </div>
</div>
