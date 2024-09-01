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
<h1 align = "left" style="list-style: none;"> Index Analysis</h1>
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
<b>1) What is the top 10 interests by the average composition for each month?</b>
<br>
<b>2) For all of these top 10 interests - which interest appears the most often?</b>
<br>
<b>3) What is the average of the average composition for the top 10 interests for each month?</b>
<br>
<b>4) What is the 3 month rolling average of the max average composition value from September 
2018 to August 2019 and include the previous top ranking?</b>
<br>
<b>5) Provide a possible reason why the max average composition might change from month to month? 
Could it signal something is not quite right with the overall business model for Fresh Segments?</b>
<br>
</pre>
</div>

<h4>1) What is the top 10 interests by the average composition for each month?</h4>

```sql
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
```
| month_year | interest_name                                        | index_composition | index_rank |
|------------|------------------------------------------------------|-------------------|------------|
| 2018-07-01 | Las Vegas Trip Planners                              | 7.35714285714286  | 1          |
| 2018-07-01 | Gym Equipment Owners                                 | 6.94464944649447  | 2          |
| 2018-07-01 | Cosmetics and Beauty Shoppers                        | 6.77619047619048  | 3          |
| 2018-07-01 | Luxury Retail Shoppers                               | 6.61153846153846  | 4          |
| 2018-07-01 | Furniture Shoppers                                   | 6.50746268656716  | 5          |
| 2018-07-01 | Asian Food Enthusiasts                               | 6.1               | 6          |
| 2018-07-01 | Recently Retired Individuals                         | 5.72189349112426  | 7          |
| 2018-07-01 | Family Adventures Travelers                          | 4.84745762711864  | 8          |
| 2018-07-01 | Work Comes First Travelers                           | 4.80263157894737  | 9          |
| 2018-07-01 | HDTV Researchers                                     | 4.7122641509434   | 10         |
| 2018-08-01 | Las Vegas Trip Planners                              | 7.20512820512821  | 1          |
| 2018-08-01 | Gym Equipment Owners                                 | 6.61904761904762  | 2          |
| 2018-08-01 | Luxury Retail Shoppers                               | 6.52820512820513  | 3          |
| 2018-08-01 | Furniture Shoppers                                   | 6.29842931937173  | 4          |
| 2018-08-01 | Cosmetics and Beauty Shoppers                        | 6.28346456692913  | 5          |
| 2018-08-01 | Work Comes First Travelers                           | 5.69724770642202  | 6          |
| 2018-08-01 | Asian Food Enthusiasts                               | 5.68103448275862  | 7          |
| 2018-08-01 | Recently Retired Individuals                         | 5.58474576271186  | 8          |
| 2018-08-01 | Alabama Trip Planners                                | 4.83333333333333  | 9          |
| 2018-08-01 | Luxury Bedding Shoppers                              | 4.71739130434783  | 10         |
| 2018-09-01 | Work Comes First Travelers                           | 8.26363636363636  | 1          |
| 2018-09-01 | Readers of Honduran Content                          | 7.59615384615385  | 2          |
| 2018-09-01 | Alabama Trip Planners                                | 7.26771653543307  | 3          |
| 2018-09-01 | Luxury Bedding Shoppers                              | 7.03940886699507  | 4          |
| 2018-09-01 | Nursing and Physicians Assistant Journal Researchers | 6.7007874015748   | 5          |
| 2018-09-01 | New Years Eve Party Ticket Purchasers                | 6.59398496240601  | 6          |
| 2018-09-01 | Teen Girl Clothing Shoppers                          | 6.53237410071942  | 7          |
| 2018-09-01 | Christmas Celebration Researchers                    | 6.46951219512195  | 8          |
| 2018-09-01 | Restaurant Supply Shoppers                           | 6.24615384615385  | 9          |
| 2018-09-01 | Solar Energy Researchers                             | 6.23529411764706  | 10         |
| 2018-10-01 | Work Comes First Travelers                           | 9.13513513513514  | 1          |
| 2018-10-01 | Alabama Trip Planners                                | 7.09923664122137  | 2          |
| 2018-10-01 | Nursing and Physicians Assistant Journal Researchers | 7.02142857142857  | 3          |
| 2018-10-01 | Readers of Honduran Content                          | 7.02127659574468  | 4          |
| 2018-10-01 | Luxury Bedding Shoppers                              | 6.93627450980392  | 5          |
| 2018-10-01 | New Years Eve Party Ticket Purchasers                | 6.91095890410959  | 6          |
| 2018-10-01 | Teen Girl Clothing Shoppers                          | 6.78378378378378  | 7          |
| 2018-10-01 | Christmas Celebration Researchers                    | 6.71823204419889  | 8          |
| 2018-10-01 | Luxury Boutique Hotel Researchers                    | 6.5301724137931   | 9          |
| 2018-10-01 | Solar Energy Researchers                             | 6.5               | 10         |
| 2018-11-01 | Work Comes First Travelers                           | 8.27659574468085  | 1          |
| 2018-11-01 | Readers of Honduran Content                          | 7.09259259259259  | 2          |
| 2018-11-01 | Solar Energy Researchers                             | 7.05357142857143  | 3          |
| 2018-11-01 | Alabama Trip Planners                                | 6.69047619047619  | 4          |
| 2018-11-01 | Nursing and Physicians Assistant Journal Researchers | 6.64705882352941  | 5          |
| 2018-11-01 | Luxury Bedding Shoppers                              | 6.54385964912281  | 6          |
| 2018-11-01 | New Years Eve Party Ticket Purchasers                | 6.31410256410256  | 7          |
| 2018-11-01 | Christmas Celebration Researchers                    | 6.07821229050279  | 8          |
| 2018-11-01 | Teen Girl Clothing Shoppers                          | 5.94904458598726  | 9          |
| 2018-11-01 | Restaurant Supply Shoppers                           | 5.58620689655172  | 10         |
| 2018-12-01 | Work Comes First Travelers                           | 8.31372549019608  | 1          |
| 2018-12-01 | Nursing and Physicians Assistant Journal Researchers | 6.95652173913044  | 2          |
| 2018-12-01 | Alabama Trip Planners                                | 6.68055555555556  | 3          |
| 2018-12-01 | Luxury Bedding Shoppers                              | 6.62995594713656  | 4          |
| 2018-12-01 | Readers of Honduran Content                          | 6.58490566037736  | 5          |
| 2018-12-01 | Solar Energy Researchers                             | 6.54716981132075  | 6          |
| 2018-12-01 | New Years Eve Party Ticket Purchasers                | 6.47560975609756  | 7          |
| 2018-12-01 | Teen Girl Clothing Shoppers                          | 6.38068181818182  | 8          |
| 2018-12-01 | Christmas Celebration Researchers                    | 6.08947368421053  | 9          |
| 2018-12-01 | Chelsea Fans                                         | 5.85542168674699  | 10         |
| 2019-01-01 | Work Comes First Travelers                           | 7.65725806451613  | 1          |
| 2019-01-01 | Solar Energy Researchers                             | 7.05263157894737  | 2          |
| 2019-01-01 | Readers of Honduran Content                          | 6.66666666666667  | 3          |
| 2019-01-01 | Luxury Bedding Shoppers                              | 6.45887445887446  | 4          |
| 2019-01-01 | Nursing and Physicians Assistant Journal Researchers | 6.45714285714286  | 5          |
| 2019-01-01 | Alabama Trip Planners                                | 6.44295302013423  | 6          |
| 2019-01-01 | New Years Eve Party Ticket Purchasers                | 6.15527950310559  | 7          |
| 2019-01-01 | Teen Girl Clothing Shoppers                          | 5.9585798816568   | 8          |
| 2019-01-01 | Christmas Celebration Researchers                    | 5.64948453608247  | 9          |
| 2019-01-01 | Readers of Catholic News                             | 5.48275862068965  | 10         |
| 2019-02-01 | Work Comes First Travelers                           | 7.6625            | 1          |
| 2019-02-01 | Nursing and Physicians Assistant Journal Researchers | 6.84297520661157  | 2          |
| 2019-02-01 | Luxury Bedding Shoppers                              | 6.75586854460094  | 3          |
| 2019-02-01 | Alabama Trip Planners                                | 6.65333333333333  | 4          |
| 2019-02-01 | Solar Energy Researchers                             | 6.58333333333333  | 5          |
| 2019-02-01 | New Years Eve Party Ticket Purchasers                | 6.56462585034014  | 6          |
| 2019-02-01 | Teen Girl Clothing Shoppers                          | 6.28571428571429  | 7          |
| 2019-02-01 | Readers of Honduran Content                          | 6.23529411764706  | 8          |
| 2019-02-01 | PlayStation Enthusiasts                              | 6.234375          | 9          |
| 2019-02-01 | Christmas Celebration Researchers                    | 5.97727272727273  | 10         |
| 2019-03-01 | Alabama Trip Planners                                | 6.54304635761589  | 1          |
| 2019-03-01 | Nursing and Physicians Assistant Journal Researchers | 6.52205882352941  | 2          |
| 2019-03-01 | Luxury Bedding Shoppers                              | 6.47368421052632  | 3          |
| 2019-03-01 | Solar Energy Researchers                             | 6.4               | 4          |
| 2019-03-01 | Readers of Honduran Content                          | 6.20833333333333  | 5          |
| 2019-03-01 | New Years Eve Party Ticket Purchasers                | 6.20547945205479  | 6          |
| 2019-03-01 | PlayStation Enthusiasts                              | 6.05714285714286  | 7          |
| 2019-03-01 | Teen Girl Clothing Shoppers                          | 6.01418439716312  | 8          |
| 2019-03-01 | Readers of Catholic News                             | 5.65432098765432  | 9          |
| 2019-03-01 | Christmas Celebration Researchers                    | 5.61497326203208  | 10         |
| 2019-04-01 | Solar Energy Researchers                             | 6.27586206896552  | 1          |
| 2019-04-01 | Alabama Trip Planners                                | 6.20833333333333  | 2          |
| 2019-04-01 | Luxury Bedding Shoppers                              | 6.04945054945055  | 3          |
| 2019-04-01 | Readers of Honduran Content                          | 6.0188679245283   | 4          |
| 2019-04-01 | Nursing and Physicians Assistant Journal Researchers | 6.00763358778626  | 5          |
| 2019-04-01 | New Years Eve Party Ticket Purchasers                | 5.64864864864865  | 6          |
| 2019-04-01 | PlayStation Enthusiasts                              | 5.52112676056338  | 7          |
| 2019-04-01 | Teen Girl Clothing Shoppers                          | 5.39041095890411  | 8          |
| 2019-04-01 | Readers of Catholic News                             | 5.2987012987013   | 9          |
| 2019-04-01 | Restaurant Supply Shoppers                           | 5.07482993197279  | 10         |
| 2019-05-01 | Readers of Honduran Content                          | 4.40909090909091  | 1          |
| 2019-05-01 | Readers of Catholic News                             | 4.08108108108108  | 2          |
| 2019-05-01 | Solar Energy Researchers                             | 3.91549295774648  | 3          |
| 2019-05-01 | PlayStation Enthusiasts                              | 3.54794520547945  | 4          |
| 2019-05-01 | Alabama Trip Planners                                | 3.33962264150943  | 5          |
| 2019-05-01 | Gamers                                               | 3.28985507246377  | 6          |
| 2019-05-01 | Luxury Bedding Shoppers                              | 3.24568965517241  | 7          |
| 2019-05-01 | Video Gamers                                         | 3.18571428571429  | 8          |
| 2019-05-01 | New Years Eve Party Ticket Purchasers                | 3.18518518518519  | 9          |
| 2019-05-01 | Nursing and Physicians Assistant Journal Researchers | 3.15172413793103  | 10         |
| 2019-06-01 | Las Vegas Trip Planners                              | 2.76506024096386  | 1          |
| 2019-06-01 | Gym Equipment Owners                                 | 2.55147058823529  | 2          |
| 2019-06-01 | Cosmetics and Beauty Shoppers                        | 2.54676258992806  | 3          |
| 2019-06-01 | Asian Food Enthusiasts                               | 2.51515151515151  | 4          |
| 2019-06-01 | Luxury Retail Shoppers                               | 2.45777777777778  | 5          |
| 2019-06-01 | Furniture Shoppers                                   | 2.39285714285714  | 6          |
| 2019-06-01 | Medicare Researchers                                 | 2.34756097560976  | 7          |
| 2019-06-01 | Recently Retired Individuals                         | 2.26737967914439  | 8          |
| 2019-06-01 | Medicare Provider Researchers                        | 2.21327014218009  | 9          |
| 2019-06-01 | Cruise Travel Intenders                              | 2.1957671957672   | 10         |
| 2019-07-01 | Las Vegas Trip Planners                              | 2.81756756756757  | 1          |
| 2019-07-01 | Luxury Retail Shoppers                               | 2.81034482758621  | 2          |
| 2019-07-01 | Gym Equipment Owners                                 | 2.78682170542636  | 3          |
| 2019-07-01 | Furniture Shoppers                                   | 2.78599221789883  | 4          |
| 2019-07-01 | Cosmetics and Beauty Shoppers                        | 2.78321678321678  | 5          |
| 2019-07-01 | Asian Food Enthusiasts                               | 2.78195488721805  | 6          |
| 2019-07-01 | Medicare Researchers                                 | 2.77456647398844  | 7          |
| 2019-07-01 | Medicare Provider Researchers                        | 2.72596153846154  | 8          |
| 2019-07-01 | Recently Retired Individuals                         | 2.72131147540984  | 9          |
| 2019-07-01 | Medicare Price Shoppers                              | 2.66091954022989  | 10         |
| 2019-08-01 | Cosmetics and Beauty Shoppers                        | 2.72847682119205  | 1          |
| 2019-08-01 | Gym Equipment Owners                                 | 2.72030651340996  | 2          |
| 2019-08-01 | Las Vegas Trip Planners                              | 2.7027027027027   | 3          |
| 2019-08-01 | Asian Food Enthusiasts                               | 2.67883211678832  | 4          |
| 2019-08-01 | Solar Energy Researchers                             | 2.6625            | 5          |
| 2019-08-01 | Luxury Retail Shoppers                               | 2.592             | 6          |
| 2019-08-01 | Furniture Shoppers                                   | 2.59003831417625  | 7          |
| 2019-08-01 | Marijuana Legalization Advocates                     | 2.5625            | 8          |
| 2019-08-01 | Medicare Researchers                                 | 2.54761904761905  | 9          |
| 2019-08-01 | Recently Retired Individuals                         | 2.53448275862069  | 10         |

<br></br>
<h4>2) For all of these top 10 interests - which interest appears the most often?</h4>

```sql
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
```
| interest_name            | appearances |
|--------------------------|-------------|
| Luxury Bedding Shoppers  | 10          |
| Solar Energy Researchers | 10          |
| Alabama Trip Planners    | 10          |

<br></br>
<h4>3) What is the average of the average composition for the top 10 interests for each month?</h4>

```sql
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
```
| month_year | avg_index_composition |
|------------|-----------------------|
| 2018-07-01 | 6.04                  |
| 2018-08-01 | 5.94                  |
| 2018-09-01 | 6.89                  |
| 2018-10-01 | 7.07                  |
| 2018-11-01 | 6.62                  |
| 2018-12-01 | 6.65                  |
| 2019-01-01 | 6.40                  |
| 2019-02-01 | 6.58                  |
| 2019-03-01 | 6.17                  |
| 2019-04-01 | 5.75                  |
| 2019-05-01 | 3.54                  |
| 2019-06-01 | 2.43                  |
| 2019-07-01 | 2.76                  |
| 2019-08-01 | 2.63                  |

<br></br>
<h4>4) What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking?</h4>

```sql
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
```

| month_year | interest_name                 | max_index_composition | 3_month_moving_avg | 1_month_ago                       | 2_months_ago                      |
|------------|-------------------------------|-----------------------|--------------------|-----------------------------------|-----------------------------------|
| 2018-09-01 | Work Comes First Travelers    | 8.26                  | 7.61               | Las Vegas Trip Planners: 7.21     | Las Vegas Trip Planners: 7.36     |
| 2018-10-01 | Work Comes First Travelers    | 9.14                  | 8.20               | Work Comes First Travelers: 8.26  | Las Vegas Trip Planners: 7.21     |
| 2018-11-01 | Work Comes First Travelers    | 8.28                  | 8.56               | Work Comes First Travelers: 9.14  | Work Comes First Travelers: 8.26  |
| 2018-12-01 | Work Comes First Travelers    | 8.31                  | 8.58               | Work Comes First Travelers: 8.28  | Work Comes First Travelers: 9.14  |
| 2019-01-01 | Work Comes First Travelers    | 7.66                  | 8.08               | Work Comes First Travelers: 8.31  | Work Comes First Travelers: 8.28  |
| 2019-02-01 | Work Comes First Travelers    | 7.66                  | 7.88               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 8.31  |
| 2019-03-01 | Alabama Trip Planners         | 6.54                  | 7.29               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 7.66  |
| 2019-04-01 | Solar Energy Researchers      | 6.28                  | 6.83               | Alabama Trip Planners: 6.54       | Work Comes First Travelers: 7.66  |
| 2019-05-01 | Readers of Honduran Content   | 4.41                  | 5.74               | Solar Energy Researchers: 6.28    | Alabama Trip Planners: 6.54       |
| 2019-06-01 | Las Vegas Trip Planners       | 2.77                  | 4.48               | Readers of Honduran Content: 4.41 | Solar Energy Researchers: 6.28    |
| 2019-07-01 | Las Vegas Trip Planners       | 2.82                  | 3.33               | Las Vegas Trip Planners: 2.77     | Readers of Honduran Content: 4.41 |
| 2019-08-01 | Cosmetics and Beauty Shoppers | 2.73                  | 2.77               | Las Vegas Trip Planners: 2.82     | Las Vegas Trip Planners: 2.77     |

<br></br>
<h4>5) Provide a possible reason why the max average composition might change from month to month? 
Could it signal something is not quite right with the overall business model for Fresh Segments?</h4>
<br></br>
<div id="box-shadow-object"  
     align="right"
     style="
            webkit-box-shadow: 10px 10px 0px 0px rgba(0,0,0,0.52);
            moz-box-shadow: 10px 10px 0px 0px rgba(0,0,0,0.52);
            box-shadow: rgba(0, 0, 0, 0.69) 10px 10px 0px 3px; 
            background-color: rgb(243, 116, 99);">
<div align="right" id="box-shadow-panel">
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
    <h1 align = "left" style="list-style: none;"> Possible reason: seasonality</h1>
    User's interests may have changed, and the users are less interested in few selected topics now. 
    Users "burnt out", and the index composition value has decreased. 
    Suggestion: some users (or interests) need to be transferred to another segment. 
    Some interests keep high index_composition value, it possibly means that these topics 
    are always in the users' interest area.<br></br>
    </pre>
    <br>
    </div>
</div>
