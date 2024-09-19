<h1 align = "left" style="list-style: none;"><img width = "75" height = "75" align = "center" src = https://github.com/user-attachments/assets/b74f8efd-c35a-4512-8fc8-16fba8d6c05b> Case Study: Data Bank</h1>
<h3 align = "left">For Serious SQL Course visit:  <a href = "https://www.datawithdanny.com/courses/serious-sql"><img width = 60 height = 60 align = "center" src = https://github.com/user-attachments/assets/6c37b5cc-b73b-4a3f-8227-adc5bbf43e5d></a></h3>
<h3 align = "left">Solutions Implemented using following DB's:  
<br><br>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/96c2104733f3c80a6c62d43786acef24b2ef3f0f/Case%20Study%20%234%20-%20Data%20Bank/PostgreSQL%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/707ade4e-37a6-4c6f-a9d3-25ee6e6153f1"></a> <a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/96c2104733f3c80a6c62d43786acef24b2ef3f0f/Case%20Study%20%234%20-%20Data%20Bank/SQL%20Server%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/04fcb916-7003-4eb5-8403-63cec20ce761"></a></h3>
</h3>
<br></br>
<br></br>
<img src= "https://github.com/user-attachments/assets/d162814b-af82-4ae4-b3eb-3a2469819617" height = 150 width="120" align = "left" >  <div id="box-shadow-object"  
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
<h1 align = "left" style="list-style: none;"> Context</h1><h3>There is a new innovation in the financial industry called Neo-Banks: new-aged 
digital only banks without physical branches.<br>
Danny thought that there should be some sort of intersection between these new 
age banks, cryptocurrency and the data world…so he decides to launch a 
new initiative - Data Bank!</h3>
<h2>Tasks at hand:</h2><h4>Data Bank runs just like any other digital bank - but it isn’t only for banking 
activities, they also have the world’s most secure distributed data storage platform!<br>
Customers are allocated cloud data storage limits which are directly linked to how much 
money they have in their accounts. There are a few interesting caveats that go with this 
business model, and this is where the Data Bank team need our help!<br>
The management team at Data Bank want to increase their total customer base 
- but also need some help tracking just how much data storage their customers will need.<br>
This case study is all about calculating metrics, growth and helping the business analyse 
their data in a smart way to better forecast and plan for their future developments!</h4>
</pre>
</div>
</div>
<br></br>
<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/96c2104733f3c80a6c62d43786acef24b2ef3f0f/Case%20Study%20%234%20-%20Data%20Bank/PostgreSQL%20Implementation/customer_nodes_exploration.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/45be6f00-349b-4690-a696-babcb9fe7e33"></a>  Customer Nodes Exploration</h3>
</h3>
</p>

<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/96c2104733f3c80a6c62d43786acef24b2ef3f0f/Case%20Study%20%234%20-%20Data%20Bank/PostgreSQL%20Implementation/customer_transactions.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/cb97005b-8cca-47e5-8232-d9501509891e"></a> Customer Transactions</h3>
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
<h1 align = "left" style="list-style: none;">Available Data | Table 1: Regions</h1><h3>For this case study there are three tables.<br><br>Table 1: Regions 
Just like popular cryptocurrency platforms - Data Bank is also run off a 
network of nodes where both money and data is stored across the globe.
</h3>
</pre>

| region_id | region_name |
|-----------|-------------|
| 1         | Africa      |
| 2         | America     |
| 3         | Asia        |
| 4         | Europe      |
| 5         | Oceania     |

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
<h1 align = "left" style="list-style: none;">Table 2: Customer Nodes</h1><h3>Customers are randomly distributed across the nodes according to their region 
- this also specifies exactly which node contains both their cash and data.</h3>
</pre>

| customer_id | region_id | node_id | start_date | end_date   |
|-------------|-----------|---------|------------|------------|
| 1           | 3         | 4       | 2020-01-02 | 2020-01-03 |
| 2           | 3         | 5       | 2020-01-03 | 2020-01-17 |
| 3           | 5         | 4       | 2020-01-27 | 2020-02-18 |
| 4           | 5         | 4       | 2020-01-07 | 2020-01-19 |
| 5           | 3         | 3       | 2020-01-15 | 2020-01-23 |
| 6           | 1         | 1       | 2020-01-11 | 2020-02-06 |
| 7           | 2         | 5       | 2020-01-20 | 2020-02-04 |
| 8           | 1         | 2       | 2020-01-15 | 2020-01-28 |
| 9           | 4         | 5       | 2020-01-21 | 2020-01-25 |
| 10          | 3         | 4       | 2020-01-13 | 2020-01-14 |

</div>
</div>
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
<h1 align = "left" style="list-style: none;">Table 3: Customer Transactions</h1><h3>This table stores all customer deposits, withdrawals and purchases made using 
their Data Bank debit card.
</h3>
</pre>
  
| customer_id | txn_date   | txn_type | txn_amount |
|-------------|------------|----------|------------|
| 429         | 2020-01-21 | deposit  | 82         |
| 155         | 2020-01-10 | deposit  | 712        |
| 398         | 2020-01-01 | deposit  | 196        |
| 255         | 2020-01-14 | deposit  | 563        |
| 185         | 2020-01-29 | deposit  | 626        |
| 309         | 2020-01-13 | deposit  | 995        |
| 312         | 2020-01-20 | deposit  | 485        |
| 376         | 2020-01-03 | deposit  | 706        |
| 188         | 2020-01-13 | deposit  | 601        |
| 138         | 2020-01-11 | deposit  | 520        |

</div>
</div>
<br></br>
