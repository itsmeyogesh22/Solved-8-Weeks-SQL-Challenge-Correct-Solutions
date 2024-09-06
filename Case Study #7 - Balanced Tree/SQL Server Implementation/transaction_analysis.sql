USE [8 Weeks SQL Challenge];

/*
	1) How many unique transactions were there?
*/
SELECT
  COUNT(DISTINCT txn_id) AS unique_transaction
FROM balanced_tree.sales;


/*
	2) What is the average unique products purchased in each transaction?
*/
WITH cte_transaction_products AS (
  SELECT
    txn_id,
    COUNT(DISTINCT prod_id) AS product_count
  FROM balanced_tree.sales
  GROUP BY txn_id
)
SELECT
  ROUND(AVG(product_count), 2) AS avg_unique_products
FROM cte_transaction_products;


/*
	3) What are the 25th, 50th and 75th percentile values for the revenue per transaction?
*/
WITH cte_transaction_revenue AS (
  SELECT
    txn_id,
    SUM(qty * price) AS revenue
  FROM balanced_tree.sales
  GROUP BY txn_id
)
SELECT TOP 1
   PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) OVER () AS pct_25,
   PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue) OVER ()  AS pct_50,
   PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue)  OVER () AS pct_75
FROM cte_transaction_revenue;


/*
	4) What is the average discount value per transaction?
*/
WITH cte_transaction_discounts AS (
  SELECT
    txn_id,
    CAST(SUM(price * qty * discount) AS NUMERIC)/100 AS total_discount
  FROM balanced_tree.sales
  GROUP BY txn_id
)
SELECT
  CAST(AVG(total_discount) AS DECIMAL(5, 2)) AS avg_unique_products
FROM cte_transaction_discounts;


/*
	5) What is the percentage split of all transactions for members vs non-members?
*/
WITH cte_member_transactions AS (
  SELECT
    sales.member,
    COUNT(DISTINCT sales.txn_id) AS transactions
  FROM balanced_tree.sales
  GROUP BY sales.member
)
SELECT
  cte_member_transactions.member,
  cte_member_transactions.transactions,
  CAST(
	CAST(100 * cte_member_transactions.transactions AS NUMERIC)/ 
	CAST((SUM(cte_member_transactions.transactions) OVER ()) AS NUMERIC)
	AS DECIMAL(5, 2)) AS [percentage]
FROM cte_member_transactions
GROUP BY cte_member_transactions.member, transactions;


/*
	6) What is the average revenue for member transactions and non-member transactions?
*/
WITH cte_member_revenue AS (
  SELECT
    sales.member,
    sales.txn_id,
    CAST(SUM(sales.price * sales.qty) AS NUMERIC) AS revenue
  FROM balanced_tree.sales
  GROUP BY sales.member, sales.txn_id
)
SELECT
  cte_member_revenue.member,
  CAST(AVG(cte_member_revenue.revenue) AS DECIMAL(5, 2)) AS avg_revenue
FROM cte_member_revenue
GROUP BY cte_member_revenue.member;