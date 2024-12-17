<br></br>
<h1 align = "left" style="list-style: none;"><img width = "75" height = "75" align = "center" src = https://github.com/user-attachments/assets/b74f8efd-c35a-4512-8fc8-16fba8d6c05b> Case Study: Danny's Diner</h1>
<h3 align = "left">For Serious SQL Course visit:  <a href = "https://www.datawithdanny.com/courses/serious-sql"><img width = 60 height = 60 align = "center" src = https://github.com/user-attachments/assets/6c37b5cc-b73b-4a3f-8227-adc5bbf43e5d></a></h3>
<h3 align = "left">Solutions Implemented using following DB's:  
<br><br>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/68e161ff3fa4d67e89d96ec46160ac7f026e39ae/Case%20Study%20%231%20-%20Danny's%20Diner/PostgreSQL%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/707ade4e-37a6-4c6f-a9d3-25ee6e6153f1"></a> <a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/68e161ff3fa4d67e89d96ec46160ac7f026e39ae/Case%20Study%20%231%20-%20Danny's%20Diner/SQL%20Server%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/04fcb916-7003-4eb5-8403-63cec20ce761"></a></h3>
</h3>
<br></br>
<br></br>
<img src= "https://github.com/user-attachments/assets/4e033411-f16f-49e3-8199-0892fd983e62" height = 150 width="120" align = "left" >  <div id="box-shadow-object"  
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
<h1 align = "left" style="list-style: none;"> Context</h1><h2>Danny seriously loves Japanese food so in the beginning of 2021, 
he decides to embark upon a risky venture and opens up a cute 
little restaurant that sells his 3 favourite foods: sushi, 
curry and ramen.</h2>
<h4>Danny’s Diner is in need of your assistance to help the restaurant stay afloat 
- the restaurant has captured some very basic data from their few months of operation 
but have no idea how to use their data to help them run the business.<br>
Danny wants to use the data to answer a few simple questions about his customers, 
especially about their visiting patterns, how much money they’ve spent and also which 
menu items are their favourite. Having this deeper connection with his customers will 
help him deliver a better and more personalised experience for his loyal customers.<br>
He plans on using these insights to help him decide whether he should expand the existing 
customer loyalty program - additionally he needs help to generate some basic datasets so 
his team can easily inspect the data without needing to use SQL.
</h4>
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
<h1 align = "left" style="list-style: none;">Available Data</h1>
<h3>Table 1: sales The sales table captures all customer_id level purchases with an 
corresponding order_date and product_id information for when and what menu items were 
ordered.
</h3>
</pre>

| A | 2021-01-01 | 1 |
|---|------------|---|
| A | 2021-01-01 | 2 |
| A | 2021-01-07 | 2 |
| A | 2021-01-10 | 3 |
| A | 2021-01-11 | 3 |
| A | 2021-01-11 | 3 |
| B | 2021-01-01 | 2 |
| B | 2021-01-02 | 2 |
| B | 2021-01-04 | 1 |
| B | 2021-01-11 | 1 |
| B | 2021-01-16 | 3 |
| B | 2021-02-01 | 3 |
| C | 2021-01-01 | 3 |
| C | 2021-01-01 | 3 |
| C | 2021-01-07 | 3 |

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
<h3>Table 2: menu The menu table maps the product_id to the actual product_name and 
price of each menu item.
</h3>
</pre>

| product_id | product_name | price |
|------------|--------------|-------|
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |

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
<h3>Table 3: members The final members table captures the join_date when a customer_id joined 
the beta version of the Danny’s Diner loyalty program.
</h3>
</pre>
  
| customer_id | join_date  |
|-------------|------------|
| A           | 2021-01-07 |
| B           | 2021-01-09 |

</div>
</div>
<br></br>
