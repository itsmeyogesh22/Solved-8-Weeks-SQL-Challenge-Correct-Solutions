/*
	1) How many customers has Foodie-Fi ever had?
*/
SELECT 
	COUNT(DISTINCT subscriptions.customer_id) AS total_customer 
FROM foodie_fi.subscriptions;


/*
	2) What is the monthly distribution of trial plan start_date values for our dataset 
	- use the start of the month as the group by value
*/
SELECT 
	DATE_PART('MONTH', subscriptions.start_date) AS month_of_year,
	TO_CHAR(subscriptions.start_date, 'MONTH') AS month_name,
	COUNT(subscriptions.customer_id) AS distribution
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi."plans" AS t2
	ON subscriptions.plan_id = t2.plan_id
WHERE t2.plan_name = 'trial'
GROUP BY 1, 2
ORDER BY 1;


/*
	3) What plan start_date values occur after the year 2020 for our dataset? 
	Show the breakdown by count of events for each plan_name
*/
/*
	This question is a bit tricky because it is not clear
	whether or not result set should include unique start_date 
	values for each plan type after the year 2020. Hence why I have 
	provided two methods to get the results. However, it seems the 
	query results provided by Danny are incorrect:

	+=========+===============+=========+
	| plan_id | plan_name     | events  |
	+=========+===============+=========+
	| 1       | basic monthly | 8       |
	| 2       | pro monthly   | 60      |
	| 3       | pro annual    | 57      |
	| 4       | churn         | 74      |
	+---------+---------------+---------+

	Before writing two different queries below, I checked unique start_date values
	for each plan type and it was quite different. Not implying I am 100% correct,
	it could be I might have missed something. Please do let me know if I'm missing
	something here.

	
*/
--Unique values only
SELECT 
	V1.plan_id,
	plans.plan_name,
	COUNT(*)
FROM
(
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY plan_id, start_date ORDER BY start_date) AS row_id
FROM foodie_fi.subscriptions
WHERE subscriptions.start_date > '2020-12-31'
ORDER BY 2, 4
) AS V1
INNER JOIN foodie_fi."plans" 
	ON V1.plan_id = plans.plan_id
WHERE V1.row_id = 1
GROUP BY 1, 2
ORDER BY 1;


--Including non-unique values
SELECT 
	V1.plan_id,
	plans.plan_name,
	COUNT(*)
FROM
(
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY plan_id, start_date ORDER BY start_date) AS row_id
FROM foodie_fi.subscriptions
WHERE subscriptions.start_date > '2020-12-31'
ORDER BY 2, 4
) AS V1
INNER JOIN foodie_fi."plans" 
	ON V1.plan_id = plans.plan_id
--WHERE V1.row_id = 1
GROUP BY 1, 2
ORDER BY 1;



/*
	4) What is the customer count and percentage of customers 
	who have churned rounded to 1 decimal place?
*/
SELECT 
	SUM(
		CASE 
			WHEN subscriptions.plan_id = 4 THEN 1 
			ELSE 0 
		END) AS customer_churn_count,
	ROUND(
	100*(SUM(
			CASE 
				WHEN subscriptions.plan_id = 4 THEN 1 
				ELSE 0 
			END))::NUMERIC/
	 COUNT(DISTINCT subscriptions.customer_id)::NUMERIC,
	2) AS churn_percentage
FROM foodie_fi.subscriptions;


/*
	5) How many customers have churned straight after their initial free trial 
	- what percentage is this rounded to 1 decimal place?
*/
WITH trials_cte AS (
SELECT *,
	LEAD(subscriptions.plan_id) 
		OVER (
			PARTITION BY subscriptions.customer_id
			ORDER BY subscriptions.start_date ASC
		) AS post_trial_plan
FROM foodie_fi.subscriptions
) 
SELECT 
	SUM(
		CASE 
			WHEN trials_cte.plan_id = 0 AND trials_cte.post_trial_plan = 4 
			THEN 1
			ELSE 0
		END
	) AS churn_count,
	ROUND(
	100*SUM(
		CASE 
			WHEN trials_cte.plan_id = 0 AND trials_cte.post_trial_plan = 4 
			THEN 1
			ELSE 0
		END
	)::NUMERIC/
	COUNT(DISTINCT trials_cte.customer_id)::NUMERIC,
	1) AS churn_percentage
FROM trials_cte;


/*
	6) What is the number and percentage of customer plans after their initial free trial?
*/
WITH trials_cte AS (
SELECT 
	subscriptions.customer_id,
	subscriptions.plan_id,
	ROW_NUMBER()
		OVER (
			PARTITION BY subscriptions.customer_id
			ORDER BY subscriptions.start_date ASC
		) AS event_order
FROM foodie_fi.subscriptions
)
SELECT 
	trials_cte.plan_id,
	t2.plan_name,
	SUM(
		CASE 
			WHEN trials_cte.event_order = 2 
			THEN 1
			ELSE 0
		END)AS post_trial_subscriptions,
	ROUND(
	100*SUM(
		CASE 
			WHEN trials_cte.event_order = 2 
			THEN 1
			ELSE 0
		END)::NUMERIC/(SELECT 
							COUNT(DISTINCT trials_cte.customer_id) 
					FROM trials_cte
	)::NUMERIC) AS proportion
FROM trials_cte
INNER JOIN foodie_fi."plans" AS t2
	ON trials_cte.plan_id = t2.plan_id
WHERE trials_cte.plan_id != 0
GROUP BY 1, 2
ORDER BY 1 ASC;


/*
	7) What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
*/
WITH valid_subscriptions AS (
  SELECT
    customer_id,
    plan_id,
    start_date,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY start_date DESC
    ) AS plan_rank
  FROM foodie_fi.subscriptions
  WHERE start_date <= '2020-12-31'::DATE
),
summarised_plans AS (
  SELECT
    plan_id,
    COUNT(DISTINCT customer_id) AS customers
  FROM valid_subscriptions
	WHERE plan_rank = 1
  GROUP BY plan_id
)
SELECT 
	t2.plan_id,
	t2.plan_name,
	summarised_plans.customers,
	ROUND(
    (100 * summarised_plans.customers)::NUMERIC/ 
      (SUM(summarised_plans.customers) OVER ())::NUMERIC,
    2
  ) AS percentage
FROM summarised_plans
INNER JOIN foodie_fi."plans" AS t2
	ON summarised_plans.plan_id = t2.plan_id
ORDER BY 1;


/*
	8) How many customers have upgraded to an annual plan in 2020?
*/
WITH valid_subscriptions AS(
SELECT *,
	ROW_NUMBER()
		OVER (
			PARTITION BY subscriptions.customer_id
			ORDER BY subscriptions.start_date DESC
	) AS subscription_order
FROM foodie_fi.subscriptions
WHERE subscriptions.start_date BETWEEN '2020-01-01' AND '2020-12-31'
) 
SELECT 
	COUNT(*) AS annual_subscribers
FROM valid_subscriptions
WHERE 
	valid_subscriptions.subscription_order = 1
	AND 
	valid_subscriptions.plan_id = 3;



/*
	9) How many days on average does it take for a customer 
	to an annual plan from the day they join Foodie-Fi? 
*/
WITH joining_dates_cte AS (
SELECT *
FROM foodie_fi.subscriptions
WHERE subscriptions.plan_id = 0
),
annual_plan_transition AS (
SELECT *
FROM foodie_fi.subscriptions
WHERE subscriptions.plan_id = 3 
)
SELECT 
	ROUND(
	AVG(
		DATE_PART('DAYS', 
					(
					annual_plan_transition.start_date::TIMESTAMP - 
					joining_dates_cte.start_date::TIMESTAMP
					)
	)
	)) AS duration_to_upgrade_days
FROM joining_dates_cte
INNER JOIN annual_plan_transition
	ON joining_dates_cte.customer_id = annual_plan_transition.customer_id;


/*
	10) Can you further breakdown this average value into 30 day periods 
		(i.e. 0-30 days, 31-60 days etc)
*/
WITH annual_plan AS (
  SELECT
    customer_id,
    start_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
),
trial AS (
  SELECT
    customer_id,
    start_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
),
annual_days AS (
SELECT
  DATE_PART(
      'day',
      annual_plan.start_date::TIMESTAMP -
        trial.start_date::TIMESTAMP
    )::INTEGER AS duration
FROM annual_plan
INNER JOIN trial
  ON annual_plan.customer_id = trial.customer_id
)
SELECT
  duration_days AS breakdown_period,
  COUNT(*) AS customers
 FROM
(
SELECT 
	CASE 
		WHEN annual_days.duration BETWEEN 0 AND 29 THEN '0 - 30 days'
		WHEN annual_days.duration BETWEEN 30 AND 59 THEN '30 - 60 days'
		WHEN annual_days.duration BETWEEN 60 AND 89 THEN '60 - 90 days'
		WHEN annual_days.duration BETWEEN 90 AND 119 THEN '90 - 120 days'
		WHEN annual_days.duration BETWEEN 120 AND 149 THEN '120 - 150 days'
		WHEN annual_days.duration BETWEEN 150 AND 179 THEN '150 - 180 days'
		WHEN annual_days.duration BETWEEN 180 AND 209 THEN '180 - 210 days'
		WHEN annual_days.duration BETWEEN 210 AND 239 THEN '210 - 240 days'
		WHEN annual_days.duration BETWEEN 240 AND 269 THEN '240 - 270 days'
		WHEN annual_days.duration BETWEEN 270 AND 299 THEN '270 - 300 days'
		WHEN annual_days.duration BETWEEN 300 AND 329 THEN '300 - 330 days'
		WHEN annual_days.duration BETWEEN 330 AND 359 THEN '330 - 360 days'
	END AS duration_days,
	1 AS total_days
FROM annual_days
) AS V1
GROUP BY 1
ORDER BY LEFT(duration_days, POSITION('-' IN duration_days)-1)::INT;



/*
	11) How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
*/
WITH ranked_plans AS (
SELECT
  customer_id,
  plan_id,
  start_date,
  LAG(plan_id) OVER (
      PARTITION BY customer_id
      ORDER BY start_date DESC
  ) AS lag_plan_id
FROM foodie_fi.subscriptions
WHERE DATE_PART('year', start_date) = 2020
)
SELECT
  COUNT(*)
FROM ranked_plans
WHERE lag_plan_id = 2 AND plan_id = 1;