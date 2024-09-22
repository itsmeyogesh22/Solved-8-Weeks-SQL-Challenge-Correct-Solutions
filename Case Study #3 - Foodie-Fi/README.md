<h1 align = "left" style="list-style: none;"><img width = "75" height = "75" align = "center" src = https://github.com/user-attachments/assets/b74f8efd-c35a-4512-8fc8-16fba8d6c05b> Case Study: Foodie-Fi</h1>
<h3 align = "left">For Serious SQL Course visit:  <a href = "https://www.datawithdanny.com/courses/serious-sql"><img width = 60 height = 60 align = "center" src = https://github.com/user-attachments/assets/6c37b5cc-b73b-4a3f-8227-adc5bbf43e5d></a></h3>
<h3 align = "left">Solutions Implemented using following DB's:  
<br><br>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/391298319d5ab5fcc0909e69d68fb23bdf4d4b57/Case%20Study%20%233%20-%20Foodie-Fi/PostgreSQL%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/707ade4e-37a6-4c6f-a9d3-25ee6e6153f1"></a> <a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/391298319d5ab5fcc0909e69d68fb23bdf4d4b57/Case%20Study%20%233%20-%20Foodie-Fi/SQL%20Server%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/04fcb916-7003-4eb5-8403-63cec20ce761"></a></h3>
</h3>
<br></br>
<br></br>
<img src= "https://github.com/user-attachments/assets/772ec585-3a34-4ff1-98ba-4b210f13241f" height = 150 width="120" align = "left" >  <div id="box-shadow-object"  
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
<h1 align = "left" style="list-style: none;"> Context</h1><h3>Subscription based businesses are super popular and Danny realised that there 
was a large gap in the market 
<br>
1) he wanted to create a new streaming service that only had food 
related content <br>
2) something like Netflix but with only cooking shows!</h3>
<h4>
Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly 
and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos 
from around the world!
<br>
Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions 
and new features were decided using data. This case study focuses on using subscription style digital 
data to answer important business questions.
</h4>
</pre>
</div>
</div>
<br></br>
<br></br>
<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/391298319d5ab5fcc0909e69d68fb23bdf4d4b57/Case%20Study%20%233%20-%20Foodie-Fi/PostgreSQL%20Implementation/data_analysis_questions.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/45be6f00-349b-4690-a696-babcb9fe7e33"></a>  Data Analysis Questions</h3>
</h3>
</p>


<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/391298319d5ab5fcc0909e69d68fb23bdf4d4b57/Case%20Study%20%233%20-%20Foodie-Fi/PostgreSQL%20Implementation/challenge_payment_question.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/cb97005b-8cca-47e5-8232-d9501509891e"></a> Challenge Payment Questions</h3>
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
<h1 align = "left" style="list-style: none;">Available Data | Table 1: plans</h1><h3>For this case study there are two tables.<br><br>Customers can choose which plans to join Foodie-Fi when they first sign up.
1. Basic plan customers have limited access and can only stream their videos and is 
   only available monthly at $9.90.

2) Pro plan customers have no watch time limits and are able to download videos for
  offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.
3) Customers can sign up to an initial 7 day free trial will automatically continue with
   the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to
   an annual pro plan at any point during the trial.
4) When customers cancel their Foodie-Fi service - they will have a churn plan record with
   a null price but their plan will continue until the end of the billing period.
</h3>
</pre>

| plan_id | plan_name     | price |
|---------|---------------|-------|
| 0       | trial         | 0     |
| 1       | basic monthly | 9.90  |
| 2       | pro monthly   | 19.90 |
| 3       | pro annual    | 199   |
| 4       | churn         | null  |


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
<h1 align = "left" style="list-style: none;">Table 2: subscriptions</h1><h3>Customer subscriptions show the exact date where their specific plan_id starts.
If customers downgrade from a pro plan or cancel their subscription:
  
1. the higher plan will remain in place until the period is over 
2. the start_date in the subscriptions table will reflect the date that the actual
   plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan 
then the higher plan will take effect straightaway.

When customers churn - they will keep their access until the end of their current 
billing period but the start_date will be technically the day they decided to cancel 
their service.
</h3>
</pre>

| customer_id | plan_id | start_date |
|-------------|---------|------------|
| 1           | 0       | 2020-08-01 |
| 1           | 1       | 2020-08-08 |
| 2           | 0       | 2020-09-20 |
| 2           | 3       | 2020-09-27 |
| 11          | 0       | 2020-11-19 |
| 11          | 4       | 2020-11-26 |
| 13          | 0       | 2020-12-15 |
| 13          | 1       | 2020-12-22 |
| 13          | 2       | 2021-03-29 |
| 15          | 0       | 2020-03-17 |
| 15          | 2       | 2020-03-24 |
| 15          | 4       | 2020-04-29 |
| 16          | 0       | 2020-05-31 |
| 16          | 1       | 2020-06-07 |
| 16          | 3       | 2020-10-21 |
| 18          | 0       | 2020-07-06 |
| 18          | 2       | 2020-07-13 |
| 19          | 0       | 2020-06-22 |
| 19          | 2       | 2020-06-29 |
| 19          | 3       | 2020-08-29 |

</div>
</div>
<br></br>
