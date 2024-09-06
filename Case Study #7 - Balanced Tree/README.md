<br></br>
<h1 align = "left" style="list-style: none;"><img width = "75" height = "75" align = "center" src = https://github.com/user-attachments/assets/b74f8efd-c35a-4512-8fc8-16fba8d6c05b> Case Study: Balanced Tree</h1>
<h3 align = "left">For Serious SQL Course visit:  <a href = "https://www.datawithdanny.com/courses/serious-sql"><img width = 60 height = 60 align = "center" src = https://github.com/user-attachments/assets/6c37b5cc-b73b-4a3f-8227-adc5bbf43e5d></a></h3>
<h3 align = "left">Solutions Implemented using following DB's:  
<br><br>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/32cdfe4b7b41cf38e09ac36cc00607d2db6dbe96/Case%20Study%20%237%20-%20Balanced%20Tree/PostgreSQL%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/707ade4e-37a6-4c6f-a9d3-25ee6e6153f1"></a> <a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/tree/32cdfe4b7b41cf38e09ac36cc00607d2db6dbe96/Case%20Study%20%237%20-%20Balanced%20Tree/SQL%20Server%20Implementation"><img width = 110 height = 110 align = "center" src = "https://github.com/user-attachments/assets/04fcb916-7003-4eb5-8403-63cec20ce761"></a></h3>
</h3>
<br></br>
<br></br>
<img src="https://github.com/user-attachments/assets/d63282b0-7835-46a0-8093-99dcb2bc0059" height = 150 width="120" align = "left" >  <div id="box-shadow-object"  
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
<h2>"Balanced Tree Clothing Company prides themselves on 
providing an optimised range of clothing and lifestyle 
wear for the modern adventurer!"</h2>
<h4>Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams 
analyse their sales performance and generate a basic financial report to share with the wider business.</h4>
</pre>
</div>
</div>
<br></br>
<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/f9944b6839e0c004efada0bae74b959952b28837/Case%20Study%20%237%20-%20Balanced%20Tree/PostgreSQL%20Implementation/high_level_sales_analysis.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/45be6f00-349b-4690-a696-babcb9fe7e33"></a> High Level Sales Analysis</h3>
</h3>
</p>

<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/f9944b6839e0c004efada0bae74b959952b28837/Case%20Study%20%237%20-%20Balanced%20Tree/PostgreSQL%20Implementation/product%20analysis.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/5fc2382e-695b-4823-8bfa-f8e0825cc513"></a> Product Analysis</h3>
</h3>
</p>

<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/f9944b6839e0c004efada0bae74b959952b28837/Case%20Study%20%237%20-%20Balanced%20Tree/PostgreSQL%20Implementation/transaction_analysis.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/cb97005b-8cca-47e5-8232-d9501509891e"></a> Transaction Analysis</h3>
</h3>
</p>

<p align = "right">
<h3>
<a href = "https://github.com/itsmeyogesh22/8-Weeks-SQL-Challenge/blob/f9944b6839e0c004efada0bae74b959952b28837/Case%20Study%20%237%20-%20Balanced%20Tree/PostgreSQL%20Implementation/bonus_challenge.sql"><img width = 60 height = 60 align = "left" src ="https://github.com/user-attachments/assets/e08703f9-75c6-4fd5-b012-ac3c6038916f"></a> Bonus Challenge
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
<h3>Product Details: balanced_tree.product_details includes all information about 
the entire range that Balanced Clothing sells in their store.</h3>
</pre>
     
| product_id | price | product_name                     | category_id | segment_id | style_id | category_name | segment_name | style_name          |
|------------|-------|----------------------------------|-------------|------------|----------|---------------|--------------|---------------------|
| c4a632     | 13    | Navy Oversized Jeans - Womens    | 1           | 3          | 7        | Womens        | Jeans        | Navy Oversized      |
| e83aa3     | 32    | Black Straight Jeans - Womens    | 1           | 3          | 8        | Womens        | Jeans        | Black Straight      |
| e31d39     | 10    | Cream Relaxed Jeans - Womens     | 1           | 3          | 9        | Womens        | Jeans        | Cream Relaxed       |
| d5e9a6     | 23    | Khaki Suit Jacket - Womens       | 1           | 4          | 10       | Womens        | Jacket       | Khaki Suit          |
| 72f5d4     | 19    | Indigo Rain Jacket - Womens      | 1           | 4          | 11       | Womens        | Jacket       | Indigo Rain         |
| 9ec847     | 54    | Grey Fashion Jacket - Womens     | 1           | 4          | 12       | Womens        | Jacket       | Grey Fashion        |
| 5d267b     | 40    | White Tee Shirt - Mens           | 2           | 5          | 13       | Mens          | Shirt        | White Tee           |
| c8d436     | 10    | Teal Button Up Shirt - Mens      | 2           | 5          | 14       | Mens          | Shirt        | Teal Button Up      |
| 2a2353     | 57    | Blue Polo Shirt - Mens           | 2           | 5          | 15       | Mens          | Shirt        | Blue Polo           |
| f084eb     | 36    | Navy Solid Socks - Mens          | 2           | 6          | 16       | Mens          | Socks        | Navy Solid          |
| b9a74d     | 17    | White Striped Socks - Mens       | 2           | 6          | 17       | Mens          | Socks        | White Striped       |
| 2feb6b     | 29    | Pink Fluro Polkadot Socks - Mens | 2           | 6          | 18       | Mens          | Socks        | Pink Fluro Polkadot |
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
<h3>Product Sales: balanced_tree.sales contains product level information for all the 
transactions made for Balanced Tree including quantity, price, percentage discount, 
member status, a transaction ID and also the transaction timestamp.</h3>
</pre>
     
| prod_id | qty | price | discount | member | txn_id | start_txn_time           |
|---------|-----|-------|----------|--------|--------|--------------------------|
| c4a632  | 4   | 13    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| 5d267b  | 4   | 40    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| b9a74d  | 4   | 17    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| 2feb6b  | 2   | 29    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| c4a632  | 5   | 13    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| e31d39  | 2   | 10    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| 72f5d4  | 3   | 19    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| 2a2353  | 3   | 57    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| f084eb  | 3   | 36    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| c4a632  | 1   | 13    | 21       | f      | ef648d | 2021-01-27 02:18:17.1648 |
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
<h3>Product Hierarcy & Product Price: Thes tables are used only for the bonus question
where we will use them to recreate the balanced_tree.product_details table.</h3>
</pre>
<br></br>
<h3>balanced_tree.product_hierarchy</h3>

| id | parent_id | level_text          | level_name |
|----|-----------|---------------------|------------|
| 1  |           | Womens              | Category   |
| 2  |           | Mens                | Category   |
| 3  | 1         | Jeans               | Segment    |
| 4  | 1         | Jacket              | Segment    |
| 5  | 2         | Shirt               | Segment    |
| 6  | 2         | Socks               | Segment    |
| 7  | 3         | Navy Oversized      | Style      |
| 8  | 3         | Black Straight      | Style      |
| 9  | 3         | Cream Relaxed       | Style      |
| 10 | 4         | Khaki Suit          | Style      |
| 11 | 4         | Indigo Rain         | Style      |
| 12 | 4         | Grey Fashion        | Style      |
| 13 | 5         | White Tee           | Style      |
| 14 | 5         | Teal Button Up      | Style      |
| 15 | 5         | Blue Polo           | Style      |
| 16 | 6         | Navy Solid          | Style      |
| 17 | 6         | White Striped       | Style      |
| 18 | 6         | Pink Fluro Polkadot | Style      |

<br></br>
<h3>balanced_tree.product_prices</h3>

| id | product_id | price |
|----|------------|-------|
| 7  | c4a632     | 13    |
| 8  | e83aa3     | 32    |
| 9  | e31d39     | 10    |
| 10 | d5e9a6     | 23    |
| 11 | 72f5d4     | 19    |
| 12 | 9ec847     | 54    |
| 13 | 5d267b     | 40    |
| 14 | c8d436     | 10    |
| 15 | 2a2353     | 57    |
| 16 | f084eb     | 36    |
| 17 | b9a74d     | 17    |
| 18 | 2feb6b     | 29    |
</div>
</div>
