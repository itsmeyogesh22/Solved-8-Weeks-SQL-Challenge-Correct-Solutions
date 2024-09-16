<br></br>
<h1 align = "left" style="list-style: none;"><img width = "75" height = "75" align = "center" src = https://github.com/user-attachments/assets/b74f8efd-c35a-4512-8fc8-16fba8d6c05b> Case Study: Clique Bait</h1>
<h3 align = "left">For Serious SQL Course visit:  <a href = "https://www.datawithdanny.com/courses/serious-sql"><img width = 60 height = 60 align = "center" src = https://github.com/user-attachments/assets/6c37b5cc-b73b-4a3f-8227-adc5bbf43e5d></a></h3>
<h3 align = "left">Solutions Implemented using following DB's:  
<br><br>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/78742be78ec92815af1f5f751bec1684d0ed95fa/Case%20Study%20%236%20-%20Clique%20Bait/PostgreSQL%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/707ade4e-37a6-4c6f-a9d3-25ee6e6153f1"></a> <a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/34d1a105bbb7891f95b9999fdef74e16af2fbaec/Case%20Study%20%236%20-%20Clique%20Bait/SQL%20Server%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/04fcb916-7003-4eb5-8403-63cec20ce761"></a></h3>
</h3>
<br></br>
<br></br>
<img src= "https://github.com/user-attachments/assets/dfc24f31-1738-4658-a5e0-b302fbe6953f" height = 150 width="120" align = "left" >  <div id="box-shadow-object"  
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
<h2>"Clique Bait is not like your regular online seafood store - 
the founder and CEO Danny, was also a part of a digital data 
analytics team and wanted to expand his knowledge into the 
seafood industry!"</h2>
<h4>In this case study - We are required to support Danny’s vision and analyse his dataset 
and come up with creative solutions to calculate funnel fallout rates for the Clique Bait 
online store.</h4>
</pre>
</div>
</div>
<br></br>
<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/34d1a105bbb7891f95b9999fdef74e16af2fbaec/Case%20Study%20%236%20-%20Clique%20Bait/PostgreSQL%20Implementation/campaigns_analysis.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/45be6f00-349b-4690-a696-babcb9fe7e33"></a> Campaign Analysis</h3>
</h3>
</p>

<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/34d1a105bbb7891f95b9999fdef74e16af2fbaec/Case%20Study%20%236%20-%20Clique%20Bait/PostgreSQL%20Implementation/digital_analysis.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/5fc2382e-695b-4823-8bfa-f8e0825cc513"></a> Digital Analysis</h3>
</h3>
</p>

<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/34d1a105bbb7891f95b9999fdef74e16af2fbaec/Case%20Study%20%236%20-%20Clique%20Bait/PostgreSQL%20Implementation/product_funnel_analysis.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/cb97005b-8cca-47e5-8232-d9501509891e"></a> Product Funnel Analysis</h3>
</h3>
</p>


<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/34d1a105bbb7891f95b9999fdef74e16af2fbaec/Case%20Study%20%236%20-%20Clique%20Bait/Enterprise%20Relationship%20Diagram"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/e08703f9-75c6-4fd5-b012-ac3c6038916f"></a> ERD
</h3>
</p>
<br></br>
<br></br>
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
<h1 align = "left" style="list-style: none;">Available Data</h1>
<h3>Users: Customers who visit the Clique Bait website are tagged via their cookie_id.
</h3>
</pre>
     
| user_id | cookie_id | start_date          |
|---------|-----------|---------------------|
| 397     | 3759ff    | 2020-03-30 00:00:00 |
| 215     | 863329    | 2020-01-26 00:00:00 |
| 191     | eefca9    | 2020-03-15 00:00:00 |
| 89      | 764796    | 2020-01-07 00:00:00 |
| 127     | 17ccc5    | 2020-01-22 00:00:00 |
| 81      | b0b666    | 2020-03-01 00:00:00 |
| 260     | a4f236    | 2020-01-08 00:00:00 |
| 203     | d1182f    | 2020-04-18 00:00:00 |
| 23      | 12dbc8    | 2020-01-18 00:00:00 |
| 375     | f61d69    | 2020-01-03 00:00:00 |
</div>
</div>
<br></br>
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
<h3>Events: Customer visits are logged in this events table at a cookie_id level and the event_type and page_id 
values can be used to join onto relevant satellite tables to obtain further information about each event.
The sequence_number is used to order the events within each visit.</h3>
</pre>
     
| visit_id | cookie_id | page_id | event_type | sequence_number | event_time                 |
|----------|-----------|---------|------------|-----------------|----------------------------|
| 719fd3   | 3d83d3    | 5       | 1          | 4               | 2020-03-02 00:29:09.975502 |
| fb1eb1   | c5ff25    | 5       | 2          | 8               | 2020-01-22 07:59:16.761931 |
| 23fe81   | 1e8c2d    | 10      | 1          | 9               | 2020-03-21 13:14:11.745667 |
| ad91aa   | 648115    | 6       | 1          | 3               | 2020-04-27 16:28:09.824606 |
| 5576d7   | ac418c    | 6       | 1          | 4               | 2020-01-18 04:55:10.149236 |
| 48308b   | c686c1    | 8       | 1          | 5               | 2020-01-29 06:10:38.702163 |
| 46b17d   | 78f9b3    | 7       | 1          | 12              | 2020-02-16 09:45:31.926407 |
| 9fd196   | ccf057    | 4       | 1          | 5               | 2020-02-14 08:29:12.922164 |
| edf853   | f85454    | 1       | 1          | 1               | 2020-02-22 12:59:07.652207 |
| 3c6716   | 02e74f    | 3       | 2          | 5               | 2020-01-31 17:56:20.777383 |
</div>
</div>
<br></br>
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
<h3>Event Identifier: The event_identifier table shows the types of events which are captured 
by Clique Bait’s digital data systems.
</h3>
</pre>
<br></br>
     
| event_type | event_name    |
|------------|---------------|
| 1          | Page View     |
| 2          | Add to Cart   |
| 3          | Purchase      |
| 4          | Ad Impression |
| 5          | Ad Click      |

<br></br>
</div>
</div>
<br></br>
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
<h3>Campaign Identifier: This table shows information for the 3 campaigns that Clique Bait has ran 
on their website so far in 2020.
</h3>
</pre>
<br></br>
     
| campaign_id | products | campaign_name                     | start_date          | end_date            |
|-------------|----------|-----------------------------------|---------------------|---------------------|
| 1           | 1-3      | BOGOF - Fishing For Compliments   | 2020-01-01 00:00:00 | 2020-01-14 00:00:00 |
| 2           | 4-5      | 25% Off - Living The Lux Life     | 2020-01-15 00:00:00 | 2020-01-28 00:00:00 |
| 3           | 6-8      | Half Off - Treat Your Shellf(ish) | 2020-02-01 00:00:00 | 2020-03-31 00:00:00 |

<br></br>
</div>
<br></br>
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
<h3>Page Hierarchy: This table lists all of the pages on the Clique Bait website which are tagged 
and have data passing through from user interaction events.</h3>
</pre>
<br></br>
     
| page_id | page_name      | product_category | product_id |
|---------|----------------|------------------|------------|
| 1       | Home Page      | null             | null       |
| 2       | All Products   | null             | null       |
| 3       | Salmon         | Fish             | 1          |
| 4       | Kingfish       | Fish             | 2          |
| 5       | Tuna           | Fish             | 3          |
| 6       | Russian Caviar | Luxury           | 4          |
| 7       | Black Truffle  | Luxury           | 5          |
| 8       | Abalone        | Shellfish        | 6          |
| 9       | Lobster        | Shellfish        | 7          |
| 10      | Crab           | Shellfish        | 8          |
| 11      | Oyster         | Shellfish        | 9          |
| 12      | Checkout       | null             | null       |
| 13      | Confirmation   | null             | null       |

<br></br>
</div>
