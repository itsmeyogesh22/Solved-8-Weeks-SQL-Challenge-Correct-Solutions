USE [8 Weeks SQL Challenge];

/*
	1) What is the unique count and total amount for each transaction type?
*/
SELECT 
	customer_transactions.txn_type AS transaction_activity,
	COUNT(*) AS total_transactions,
	SUM(customer_transactions.txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY customer_transactions.txn_type;


/*
	2) What is the average total historical deposit counts and amounts for all customers?
*/
WITH cte_customer AS (
SELECT
  customer_transactions.customer_id,
  COUNT(customer_transactions.txn_date) AS deposit_count,
  SUM(customer_transactions.txn_amount) AS total_deposit_amount
FROM data_bank.customer_transactions
WHERE 
	customer_transactions.txn_type = 'deposit'
	AND
	customer_transactions.txn_date != '9999-12-31'
GROUP BY customer_transactions.customer_id
)
SELECT
  ROUND(AVG(cte_customer.deposit_count), 2) AS avg_deposit_count,
  (SUM(cte_customer.total_deposit_amount)/SUM(cte_customer.deposit_count)) AS avg_deposit_amount
FROM cte_customer;


/*
	3) For each month - 
	how many Data Bank customers make more 
	than 1 deposit and at least either 1 purchase or 1 withdrawal in a single month?
*/
WITH cte_customer_months AS (
  SELECT
    DATEPART(MONTH, txn_date) AS month_of_year,
	DATENAME(MONTH, txn_date) AS month_name,
    customer_id,
    SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
    SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
  FROM data_bank.customer_transactions
  GROUP BY DATEPART(MONTH, txn_date), DATENAME(MONTH, txn_date), customer_id
)
SELECT
  month_of_year,
  month_name,
  COUNT(*) AS customer_count
FROM cte_customer_months
/*
Assigning purchase_count = 1 -OR- withdrawal_count = 1 narrows the result
by filtering the records with more than 1 purchase_count -OR- withdrawal_count.
*/
WHERE deposit_count > 1 AND (
  purchase_count != 0 OR withdrawal_count != 0
)
GROUP BY 
	month_of_year,
  	month_name
ORDER BY 1;





/*
	4) What is the closing balance for each customer at the end of the month? 
	Also show the change in balance each month in the same table output.
*/
--total range of months available
SELECT
  DATEPART(MONTH, txn_date) AS month_of_year,
  DATENAME(MONTH, txn_date) AS month_name,
  COUNT(customer_id) AS record_count
FROM data_bank.customer_transactions
GROUP BY 
	DATEPART(MONTH, txn_date),
	DATENAME(MONTH, txn_date)
ORDER BY 1;

WITH cte_monthly_balances AS (
  SELECT
    customer_id,
  	DATEPART(MONTH, txn_date) AS month_of_year,
  	DATENAME(MONTH, txn_date) AS month_name,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        ELSE (-txn_amount)
        END
    ) AS balance
  FROM data_bank.customer_transactions
  GROUP BY customer_id, DATEPART(MONTH, txn_date), DATENAME(MONTH, txn_date)
),
adjusted_balance AS (
SELECT 
	V1.customer_id,
	V2.value AS month_range,
	COALESCE(cte_monthly_balances.month_name, DATENAME(MONTH, V2.value)) AS month_name,
	COALESCE(cte_monthly_balances.balance, 0) AS balance
FROM
(
SELECT 
	cte_monthly_balances.customer_id,
	MIN(cte_monthly_balances.month_of_year) AS opening_date,
	4 AS closing_date
FROM cte_monthly_balances
GROUP BY 
	cte_monthly_balances.customer_id
) AS V1
CROSS APPLY 
	GENERATE_SERIES(opening_date, closing_date, 1) AS V2
LEFT JOIN cte_monthly_balances
	ON 
	V1.customer_id = cte_monthly_balances.customer_id
	AND
	V2.value = cte_monthly_balances.month_of_year
)
SELECT 
	customer_id,
	TRY_PARSE(
		CONCAT_WS(
				'-', 
				YEAR('2020'), 
				month_range, 
				DAY(0)
				) AS DATE USING 'EN-US') AS transaction_date,
	YEAR('2020') AS txn_year,
	month_range AS txn_month,
	DAY(0) AS txn_day,
	balance AS balance_contribution,
	SUM(balance) 
		OVER (
			PARTITION BY customer_id 
			ORDER BY month_range
			) AS ending_balance
FROM adjusted_balance
ORDER BY 1 ASC;

/*
	5) Comparing the closing balance of a customer’s first month 
	and the closing balance from their second month, what percentage of customers:
		a) Have a negative first month balance?
		b) Have a positive first month balance?
		c) Increase their opening month’s positive closing balance by more than 5% 
		in the following month?
		d) Reduce their opening month’s positive closing balance by more than 5% 
		in the following month?
		e) Move from a positive balance in the first month to a negative balance in 
		the second month?
*/

--Solution-1: Results without filtering 5% increase in opening month's positive closing balance
WITH cte_monthly_balances AS (
  SELECT
    customer_id,
  	DATEPART(MONTH, txn_date) AS month_of_year,
  	DATENAME(MONTH, txn_date) AS month_name,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        ELSE -(txn_amount)
        END
    ) AS balance
  FROM data_bank.customer_transactions
  GROUP BY customer_id, DATEPART(MONTH, txn_date), DATENAME(MONTH, txn_date)
),
cte_generated_months AS (
SELECT DISTINCT
	customer_transactions.customer_id,
	CAST(DATEADD(MONTH, G1.value, '2020-01-01') AS DATE) AS month_end
FROM data_bank.customer_transactions
CROSS APPLY GENERATE_SERIES(0, 3) AS G1
),
final_cte AS (
SELECT
  cte_generated_months.customer_id,
  cte_generated_months.month_end,
  COALESCE(cte_monthly_balances.balance, 0) AS balance_contribution,
  LAG(cte_monthly_balances.balance) 
  		OVER (
		  	PARTITION BY cte_generated_months.customer_id
    		ORDER BY DATEPART(MONTH, cte_generated_months.month_end)
  ) AS last_month_balance,
  SUM(cte_monthly_balances.balance) 
  		OVER (
    		PARTITION BY cte_generated_months.customer_id
    		ORDER BY DATEPART(MONTH, cte_generated_months.month_end) 
  ) AS ending_balance
FROM cte_generated_months
LEFT JOIN cte_monthly_balances
	ON cte_generated_months.customer_id = cte_monthly_balances.customer_id
	AND
	DATEPART(MONTH, cte_generated_months.month_end) = cte_monthly_balances.month_of_year
WHERE DATEPART(MONTH, cte_generated_months.month_end) BETWEEN 1 AND 4
),
opening_balance AS (
SELECT 
	CAST(CAST(100*SUM(CASE WHEN balance_contribution > 0 THEN 1 ELSE 0 END) AS DECIMAL(10, 5))/CAST(COUNT(*) AS DECIMAL(10, 5)) AS DECIMAL(5, 2)) AS positive_pc,
	SUM(CASE WHEN balance_contribution > 0 THEN 1 ELSE 0 END) AS positive_opening_count,
	CAST(CAST(100*SUM(CASE WHEN balance_contribution < 0 THEN 1 ELSE 0 END) AS DECIMAL(10, 5))/CAST(COUNT(*) AS DECIMAL(10, 5)) AS DECIMAL(5, 2)) AS negative_pc,
	SUM(CASE WHEN balance_contribution < 0 THEN 1 ELSE 0 END) AS negative_opening_count,
	COUNT(*) AS total_customers
FROM
(
SELECT DISTINCT
	customer_id,
	DATEPART(MONTH, month_end) AS month_num,
	balance_contribution,
	ending_balance,
	LEAD(balance_contribution) OVER w AS prev_balance
FROM final_cte
WINDOW
	w AS (PARTITION BY customer_id ORDER BY DATEPART(MONTH, month_end) ASC)
) AS V1
WHERE month_num = 1
),
stats_2 AS (
SELECT 
	customer_id,
	month_num,
	balance_contribution,
	ending_balance,
	prev_balance,
	COALESCE((100*(ABS(balance_contribution)-ABS(prev_balance))/(NULLIF(balance_contribution, 0))), 0) AS col_eval
FROM
(
SELECT DISTINCT
	customer_id,
	DATEPART(MONTH, month_end) AS month_num,
	CAST(COALESCE(balance_contribution, 0) AS DECIMAL(10, 5)) AS balance_contribution,
	CAST(COALESCE(ending_balance, 0) AS DECIMAL(10, 5)) AS ending_balance,
	CAST(LAG(balance_contribution) OVER w AS DECIMAL(10, 5)) AS prev_balance
FROM final_cte
WHERE DATEPART(MONTH, month_end) <= 2
WINDOW
	w AS (PARTITION BY customer_id ORDER BY DATEPART(MONTH, month_end) ASC)
) AS V2
WHERE prev_balance IS NOT NULL 
),
final_eval AS (
SELECT 
	SUM(CASE WHEN col_eval > 0  OR balance_contribution = 0 THEN 1 ELSE 0 END) AS increase_pc,
	SUM(CASE WHEN col_eval < 0 OR (ending_balance < 0 AND balance_contribution < 0) THEN 1 ELSE 0 END) AS decrease_pc,
	SUM(CASE WHEN prev_balance > 0 AND ending_balance < 0 THEN 1 ELSE 0 END) AS negative_transition,
	SUM(CASE WHEN balance_contribution = 0 THEN 1 ELSE 0 END) AS zero_counter
FROM stats_2
)
SELECT 
	CAST(FLOOR(opening_balance.positive_pc) AS DECIMAL(5, 2)) AS positive_pc,
	CAST(FLOOR(opening_balance.negative_pc) AS DECIMAL(5, 2)) AS negative_pc,
	CAST(FLOOR(100*(final_eval.increase_pc-final_eval.zero_counter)/opening_balance.total_customers) AS DECIMAL(5, 2)) AS increase_pc,
	CAST(FLOOR(100*(final_eval.decrease_pc-final_eval.zero_counter)/opening_balance.total_customers)  AS DECIMAL(5, 2)) AS decrease_pc,
	CAST(FLOOR(100*(final_eval.negative_transition)/opening_balance.positive_opening_count)  AS DECIMAL(5, 2)) AS negative_balance_pc
FROM 
	final_eval,
	opening_balance;


--Solution-2: Results with filtering more than 5% increase and decrease in opening month's positive closing balance
WITH cte_monthly_balances AS (
  SELECT
    customer_id,
  	DATEPART(MONTH, txn_date) AS month_of_year,
  	DATENAME(MONTH, txn_date) AS month_name,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        ELSE -(txn_amount)
        END
    ) AS balance
  FROM data_bank.customer_transactions
  GROUP BY customer_id, DATEPART(MONTH, txn_date), DATENAME(MONTH, txn_date)
),
cte_generated_months AS (
SELECT DISTINCT
	customer_transactions.customer_id,
	CAST(DATEADD(MONTH, G1.value, '2020-01-01') AS DATE) AS month_end
FROM data_bank.customer_transactions
CROSS APPLY GENERATE_SERIES(0, 3) AS G1
),
final_cte AS (
SELECT
  cte_generated_months.customer_id,
  cte_generated_months.month_end,
  COALESCE(cte_monthly_balances.balance, 0) AS balance_contribution,
  LAG(cte_monthly_balances.balance) 
  		OVER (
		  	PARTITION BY cte_generated_months.customer_id
    		ORDER BY DATEPART(MONTH, cte_generated_months.month_end)
  ) AS last_month_balance,
  SUM(cte_monthly_balances.balance) 
  		OVER (
    		PARTITION BY cte_generated_months.customer_id
    		ORDER BY DATEPART(MONTH, cte_generated_months.month_end) 
  ) AS ending_balance
FROM cte_generated_months
LEFT JOIN cte_monthly_balances
	ON cte_generated_months.customer_id = cte_monthly_balances.customer_id
	AND
	DATEPART(MONTH, cte_generated_months.month_end) = cte_monthly_balances.month_of_year
WHERE DATEPART(MONTH, cte_generated_months.month_end) BETWEEN 1 AND 4
),
opening_balance AS (
SELECT 
	CAST(CAST(100*SUM(CASE WHEN balance_contribution > 0 THEN 1 ELSE 0 END) AS DECIMAL(10, 5))/CAST(COUNT(*) AS DECIMAL(10, 5)) AS DECIMAL(5, 2)) AS positive_pc,
	SUM(CASE WHEN balance_contribution > 0 THEN 1 ELSE 0 END) AS positive_opening_count,
	CAST(CAST(100*SUM(CASE WHEN balance_contribution < 0 THEN 1 ELSE 0 END) AS DECIMAL(10, 5))/CAST(COUNT(*) AS DECIMAL(10, 5)) AS DECIMAL(5, 2)) AS negative_pc,
	SUM(CASE WHEN balance_contribution < 0 THEN 1 ELSE 0 END) AS negative_opening_count,
	COUNT(*) AS total_customers
FROM
(
SELECT DISTINCT
	customer_id,
	DATEPART(MONTH, month_end) AS month_num,
	balance_contribution,
	ending_balance,
	LEAD(balance_contribution) OVER w AS prev_balance
FROM final_cte
WINDOW
	w AS (PARTITION BY customer_id ORDER BY DATEPART(MONTH, month_end) ASC)
) AS V1
WHERE month_num = 1
),
stats_2 AS (
SELECT 
	customer_id,
	month_num,
	balance_contribution,
	ending_balance,
	prev_balance,
	COALESCE((100*(ABS(balance_contribution)-ABS(prev_balance))/(NULLIF(balance_contribution, 0))), 0) AS col_eval
FROM
(
SELECT DISTINCT
	customer_id,
	DATEPART(MONTH, month_end) AS month_num,
	CAST(COALESCE(balance_contribution, 0) AS DECIMAL(10, 5)) AS balance_contribution,
	CAST(COALESCE(ending_balance, 0) AS DECIMAL(10, 5)) AS ending_balance,
	CAST(LAG(balance_contribution) OVER w AS DECIMAL(10, 5)) AS prev_balance
FROM final_cte
WHERE DATEPART(MONTH, month_end) <= 2
WINDOW
	w AS (PARTITION BY customer_id ORDER BY DATEPART(MONTH, month_end) ASC)
) AS V2
WHERE prev_balance IS NOT NULL 
),
final_eval AS (
SELECT 
	SUM(CASE WHEN col_eval > 5.00 AND prev_balance > 0 THEN 1 ELSE 0 END) AS increase_pc,
	SUM(CASE WHEN col_eval < -5.00 AND prev_balance > 0 THEN 1 ELSE 0 END) AS decrease_pc,
	SUM(CASE WHEN prev_balance > 0 AND ending_balance < 0 THEN 1 ELSE 0 END) AS negative_transition,
	SUM(CASE WHEN balance_contribution = 0 THEN 1 ELSE 0 END) AS zero_counter
FROM stats_2
)
SELECT 
	CAST(FLOOR(opening_balance.positive_pc) AS DECIMAL(5, 2)) AS positive_pc,
	CAST(FLOOR(opening_balance.negative_pc) AS DECIMAL(5, 2)) AS negative_pc,
	CAST(FLOOR(100*(final_eval.increase_pc)/opening_balance.positive_opening_count) AS DECIMAL(5, 2)) AS increase_pc,
	CAST(FLOOR(100*(final_eval.decrease_pc)/opening_balance.positive_opening_count)  AS DECIMAL(5, 2)) AS decrease_pc,
	CAST(FLOOR(100*(final_eval.negative_transition)/opening_balance.positive_opening_count)  AS DECIMAL(5, 2)) AS negative_balance_pc
FROM 
	final_eval,
	opening_balance;