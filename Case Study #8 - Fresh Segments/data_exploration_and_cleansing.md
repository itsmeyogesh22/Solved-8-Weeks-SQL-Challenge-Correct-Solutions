<h1 align ="left">Case Study #8 - Fresh Segments</h1>
<br></br>
<img src="https://github.com/user-attachments/assets/cbc60e1d-cded-4657-9d9d-52c6a0c49b01" height = 150 width="120" align = "left" >  <div id="box-shadow-object"  
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
<h1 align = "left" style="list-style: none;"> Context</h1>
As stated by Danny himself:<br>
"Danny created Fresh Segments, a digital marketing agency that helps other businesses analyse 
trends in online ad click behaviour for their unique customer base.
Clients share their customer lists with the Fresh Segments team who then aggregate 
interest metrics and generate a single dataset worth of metrics for further analysis.
In particular - the composition and rankings for different interests are provided for 
each client showing the proportion of their customer list who interacted with online 
assets related to each interest for each month.
Danny has asked for your assistance to analyse aggregated metrics for an example client 
and provide some high level insights about the customer list and their interests."
<br>
    </pre>
</div>
</div>
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
    <h1 align = "left" style="list-style: none;"> Approach</h1>
    Given the nature of data -AND- the nature of problem at hand, An Exploratory Analysis is required to make amends. 
    This section describes the Dataset which has been specifically provided for this case study, 
    Covering a range of steps to be followed while performing basic Exploratory data analysis, while at the same time 
    making amends in data values.
<br></br>
    </pre>
    <br>
    </div>
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
<h1 align = "left" style="list-style: none;"> Data Exploration And Cleansing</h1>
</pre>
</div>

1) Update the fresh_segments.interest_metrics table by modifying the month_year
column to be a date data type with the start of the month. 
```sql
DROP TABLE fresh_segments.interest_metrics
UPDATE fresh_segments.interest_metrics
SET month_year = TO_DATE(CONCAT_WS('-', '01', _month, _year), 'DD-MM-YYYY');

ALTER TABLE fresh_segments.interest_metrics
	ALTER month_year TYPE DATE USING month_year::DATE;
```
<br></br>
2) What is count of records in the fresh_segments.interest_metrics for each month_year value sorted 
in chronological order (earliest to latest) with the null values appearing first?
```sql
SELECT 
  interest_metrics.month_year,
  COUNT(*) AS total_records
FROM fresh_segments.interest_metrics
GROUP BY 1
ORDER BY 1;
```

| month_year   | total_records |
|--------------|---------------|
| "2018-07-01" | 729           |
| "2018-08-01" | 767           |
| "2018-09-01" | 780           |
| "2018-10-01" | 857           |
| "2018-11-01" | 928           |
| "2018-12-01" | 995           |
| "2019-01-01" | 973           |
| "2019-02-01" | 1121          |
| "2019-03-01" | 1136          |
| "2019-04-01" | 1099          |
| "2019-05-01" | 857           |
| "2019-06-01" | 824           |
| "2019-07-01" | 864           |
| "2019-08-01" | 1149          |

<br></br>
<br></br>
3) What do you think we should do with these null values in the fresh_segments.interest_metrics?
```sql
DELETE FROM  fresh_segments.interest_metrics
WHERE interest_metrics.interest_id IS NULL OR interest_metrics._month IS NULL;

SELECT *
FROM fresh_segments.interest_metrics
WHERE interest_metrics.interest_id IS NULL;
```
<br></br>
<br></br>
4) How many interest_id values exist in the fresh_segments.interest_metrics table but not in the 
fresh_segments.interest_map table? What about the other way around?
```sql
SELECT
  COUNT(DISTINCT interest_metrics.interest_id) AS all_interest_metric,
  COUNT(DISTINCT interest_map.id) AS all_interest_map,
  COUNT(CASE WHEN interest_map.id IS NULL THEN interest_metrics.interest_id ELSE NULL END) AS not_in_map,
  COUNT(CASE WHEN interest_metrics.interest_id IS NULL THEN interest_map.id ELSE NULL END)  AS not_in_metrics
FROM fresh_segments.interest_metrics
FULL OUTER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id;
```


| all_interest_metric| all_interest_map | not_in_map | not_in_metrics |
|--------------------|------------------|------------|----------------|
| 1202               | 1209             | 0          | 7              |

<br></br>
<br></br>
5) Summarise the id values in the fresh_segments.interest_map by its total record count in this table.
```sql
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
GROUP BY 1;
```
| record_count | id_count |
|--------------|----------|
| 1            | 1209     |

<br></br>
<br></br>
6) What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where 
interest_id = 21246 in your joined output 
and include all columns from fresh_segments.interest_metrics and all columns 
from fresh_segments.interest_map except from the id column.
```sql
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
WHERE interest_metrics.interest_id = 21246;
```
</div>
