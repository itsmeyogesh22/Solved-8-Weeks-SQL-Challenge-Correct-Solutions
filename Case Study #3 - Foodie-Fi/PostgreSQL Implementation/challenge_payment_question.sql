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
	'2020-12-31'::DATE AS last_month,
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
ORDER BY 1
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
		THEN cte_date_events.next_payment_date::TEXT
		WHEN cte_date_events.next_payment_date IS NULL 
		AND 
		cte_date_events.plan_id = 3
		THEN
			COALESCE(
			REPLACE(
				cte_date_events.payment_date::TEXT,
				RIGHT(cte_date_events.payment_date::TEXT, 2),
				RIGHT(cte_date_events.next_payment_date::TEXT, 2)),
				cte_date_events.payment_date::TEXT)
		ELSE REPLACE(
				cte_date_events.last_month::TEXT, 
				RIGHT(cte_date_events.last_month::TEXT, 2), 
				RIGHT(cte_date_events.payment_date::TEXT, 2))
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
adjusted_prices AS (
SELECT DISTINCT
	V1.customer_id,
	V1.plan_id,
	V1.plan_name,
	V1.payment_date,
	V1.price,
	CASE 
		WHEN LAG(V1.plan_id) OVER next_plan = 1
		AND V1.plan_id IN (2, 3)
		AND V1.plan_id != 1
		THEN V1.price - 9.90
		ELSE V1.price
	END AS amount
FROM 
(
SELECT 
	adjusted_dates.customer_id,
	adjusted_dates.plan_id,
	adjusted_dates.plan_name,
	GENERATE_SERIES(
			adjusted_dates.payment_date::DATE, 
			adjusted_dates.next_payment_date::DATE, 
			INTERVAL '1 MONTH') AS payment_date,
	adjusted_dates.price
FROM adjusted_dates
) AS V1
WINDOW 
	next_plan AS (PARTITION BY V1.customer_id ORDER BY V1.payment_date ASC)
)
INSERT INTO foodie_fi.payments
SELECT 
	adjusted_prices.customer_id,
	adjusted_prices.plan_id,
	adjusted_prices.plan_name,
	adjusted_prices.payment_date::DATE,
	adjusted_prices.amount,
	ROW_NUMBER() 
		OVER (
			PARTITION BY adjusted_prices.customer_id 
			ORDER BY adjusted_prices.payment_date::DATE ASC) AS payment_order
FROM adjusted_prices
ORDER BY 1;

SELECT * FROM foodie_fi.payments;