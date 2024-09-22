USE [8 Weeks SQL Challenge];

/*
	The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes 
	amounts paid by each customer in the subscriptions table with the following requirements:
		1) monthly payments always occur on the same day of month as the original start_date of any 
		   monthly paid plan.
		2) upgrades from basic to monthly or pro plans are reduced by the current paid amount in 
		   that month and start immediately.
		3) upgrades from pro monthly to pro annual are paid at the end of the current billing period
		   and also starts at the end of the month period.
		4) once a customer churns they will no longer make payments.
*/
DROP TABLE IF EXISTS foodie_fi.payments;
CREATE TABLE foodie_fi.payments 
		(
		customer_id INT,
		plan_id INT,
		plan_name VARCHAR(50),
		payment_date DATE,
		amount NUMERIC,
		payment_order INT
		);

WITH cte_date_events AS (
SELECT 
	subscriptions.customer_id,
	subscriptions.plan_id,
	t2.plan_name,
	subscriptions.start_date AS payment_date,
	LEAD(subscriptions.start_date) OVER date_window AS next_payment_date,
	'2020-12-31' AS last_month,
	t2.price
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi."plans" AS t2
	ON subscriptions.plan_id = t2.plan_id
WHERE 
	subscriptions.plan_id != 0
	AND
	subscriptions.start_date BETWEEN '2020-01-01' AND '2020-12-31'
WINDOW
	date_window AS (
		PARTITION BY subscriptions.customer_id 
		ORDER BY subscriptions.start_date
		)
),
adjusted_dates AS (
SELECT 
	cte_date_events.customer_id,
	cte_date_events.plan_id,
	cte_date_events.plan_name,
	cte_date_events.payment_date,
	CASE 
		WHEN cte_date_events.next_payment_date IS NOT NULL 
		AND
		cte_date_events.plan_id IN (1, 2)
		THEN cte_date_events.next_payment_date
		WHEN cte_date_events.next_payment_date IS NULL 
		AND 
		cte_date_events.plan_id = 3
		THEN
			COALESCE(
			REPLACE(
				cte_date_events.payment_date,
				RIGHT(cte_date_events.payment_date, 2),
				RIGHT(cte_date_events.next_payment_date, 2)),
				cte_date_events.payment_date)
		ELSE REPLACE(
				cte_date_events.last_month, 
				RIGHT(cte_date_events.last_month, 2), 
				RIGHT(cte_date_events.payment_date, 2))
	END AS next_payment_date,
	cte_date_events.price
FROM cte_date_events
WHERE cte_date_events.customer_id 
		NOT IN
			(
			SELECT DISTINCT 
				cte_date_events.customer_id
			FROM cte_date_events
			WHERE cte_date_events.plan_id = 4
			)
),
valid_ordered_dates AS (
SELECT 
	V1.customer_id,
	V1.plan_id,
	V1.plan_name,
	V1.payment_date,
	V1.price,
	YEAR(V1.payment_date) AS interval_year,
	V1.month_interval,
	V1.day_interval,
	CAST(
		TRY_PARSE(
			CONCAT(
				YEAR(V1.payment_date), 
				'-', V1.month_interval, 
				'-', 
				V1.day_interval
				) AS DATETIME USING 'EN-US') AS DATE) AS transaction_date
FROM
(
SELECT 
	T1.customer_id,
	T1.plan_id,
	T1.plan_name,
	T1.price,
	T1.payment_date,
	T2.value AS month_interval,
	T3.value AS day_interval,
	ROW_NUMBER() OVER (PARTITION BY T1.customer_id, T1.payment_date, T2.value ORDER BY T3.value ASC) AS date_order
	FROM 
	adjusted_dates AS T1
	CROSS APPLY
	GENERATE_SERIES(
			MONTH(T1.payment_date), 
			MONTH(T1.next_payment_date), 
			1) AS T2
	CROSS APPLY
		GENERATE_SERIES(
			DAY(T1.payment_date), 
			DAY(T1.next_payment_date), 
			1) AS T3
) AS V1
WHERE V1.date_order = 1
)
INSERT INTO foodie_fi.payments
		(
		customer_id,
		plan_id,
		plan_name,
		payment_date,
		amount,
		payment_order
		)
SELECT 
	valid_ordered_dates.customer_id,
	valid_ordered_dates.plan_id,
	valid_ordered_dates.plan_name,
	valid_ordered_dates.transaction_date AS payment_date,
	CASE 
		WHEN valid_ordered_dates.plan_id IN (2, 3)
		AND
		LAG(valid_ordered_dates.plan_id) 
			OVER (
				PARTITION BY valid_ordered_dates.customer_id 
				ORDER BY valid_ordered_dates.transaction_date ASC
				) = 1 
		THEN valid_ordered_dates.price - 9.90
		ELSE valid_ordered_dates.price
		END AS amount,
	ROW_NUMBER() 
		OVER (
			PARTITION BY valid_ordered_dates.customer_id 
			ORDER BY valid_ordered_dates.transaction_date ASC
			) AS payment_order
FROM valid_ordered_dates
WHERE valid_ordered_dates.transaction_date IS NOT NULL
ORDER BY 1;

SELECT * FROM foodie_fi.payments ORDER BY 1 ASC;