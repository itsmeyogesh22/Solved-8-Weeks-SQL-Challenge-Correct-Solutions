USE [8 Weeks SQL Challenge];

/*
	Generate a table that has 1 single row for every unique visit_id record and has the following columns:
		+user_id
		+visit_id
		+visit_start_time: the earliest event_time for each visit
		+page_views: count of page views for each visit
		+cart_adds: count of product cart add events for each visit
		+purchase: 1/0 flag if a purchase event exists for each visit
		+campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
		+impression: count of ad impressions for each visit
		+click: count of ad clicks for each visit
		+(Optional column) cart_products: a comma separated text value with products added to the cart sorted by 
		 the order they were added to the cart (hint: use the sequence_number).

	Use the subsequent dataset to generate at least 5 insights for the Clique Bait team 
		+ bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, 
		  be sure to emphasise the most important points from your findings.
	
	Some ideas you might want to investigate further include:
		+Identifying users who have received impressions during each campaign period and comparing 
		 each metric with other users who did not have an impression > event.
		+Does clicking on an impression lead to higher purchase rates?
		+What is the uplift in purchase rate when comparing users who click on a campaign impression 
		 versus users who do not receive an impression? What if we compare them with users who just 
		 an impression but do not click?
		+What metrics can you use to quantify the success or failure of each campaign compared to eachother?




*/
SELECT 
  users.user_id,
  events.visit_id,
  MIN(events.event_time) AS visit_start_time,
  SUM(CASE WHEN events.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN events.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
  MAX(CASE WHEN events.event_type = 3 THEN 1 ELSE 0 END) AS purchase,
  campaign_identifier.campaign_name,
  MAX(CASE WHEN events.event_type = 4 THEN 1 ELSE 0 END) AS impression,
  MAX(CASE WHEN events.event_type = 5 THEN 1 ELSE 0 END) AS click,
  STRING_AGG(
    CASE
      WHEN page_hierarchy.product_id IS NOT NULL AND event_type = 2
        THEN page_hierarchy.page_name
      ELSE NULL END,
    ', '
  ) AS cart_products
FROM clique_bait.events
INNER JOIN clique_bait.users
  ON events.cookie_id = users.cookie_id
LEFT JOIN clique_bait.campaign_identifier
  ON events.event_time BETWEEN campaign_identifier.start_date AND campaign_identifier.end_date
LEFT JOIN clique_bait.page_hierarchy
  ON events.page_id = page_hierarchy.page_id
GROUP BY
  users.user_id,
  events.visit_id,
  campaign_identifier.campaign_name
ORDER BY MIN(events.event_time) ASC;