USE [8 Weeks SQL Challenge];

CREATE SCHEMA fresh_segments;

DROP TABLE IF EXISTS fresh_segments.interest_map;
CREATE TABLE fresh_segments.interest_map (
  "id" INTEGER,
  "interest_name" TEXT,
  "interest_summary" TEXT,
  "created_at" DATETIME2,
  "last_modified" DATETIME2
);

DROP TABLE IF EXISTS fresh_segments.interest_metrics;
CREATE TABLE fresh_segments.interest_metrics
	(
	_month INT NULL,
	_year BIGINT NULL,
	month_year VARCHAR(50) NULL,
	interest_id BIGINT NULL,
	composition FLOAT NULL,
	index_value FLOAT NULL,
	ranking INT NULL,
	percentile_ranking FLOAT NULL
	);
INSERT INTO fresh_segments.interest_metrics
	(
	_month,
	_year,
	month_year,
	interest_id,
	composition,
	index_value,
	ranking,
	percentile_ranking
	)
SELECT
	V1.COL1,
	V1.COL2,
	V1.COL3,
	V1.COL4,
	V1.COL5,
	V1.COL6,
	V1.COL7,
	V1.COL8
FROM
(
SELECT 
	[interest_metrics_1-10000].[month],
	[interest_metrics_1-10000].[year],
	[interest_metrics_1-10000].month_year,
	[interest_metrics_1-10000].interest_id,
	[interest_metrics_1-10000].composition,
	[interest_metrics_1-10000].index_value,
	[interest_metrics_1-10000].ranking,
	[interest_metrics_1-10000].percentile_ranking
FROM fresh_segments.[interest_metrics_1-10000]
UNION
SELECT 
	[interest_metrics_10001-14273].[month],
	[interest_metrics_10001-14273].[year],
	[interest_metrics_10001-14273].month_year,
	[interest_metrics_10001-14273].interest_id,
	[interest_metrics_10001-14273].composition,
	[interest_metrics_10001-14273].index_value,
	[interest_metrics_10001-14273].ranking,
	[interest_metrics_10001-14273].percentile_ranking
FROM fresh_segments.[interest_metrics_10001-14273]
) AS V1(COL1, COL2, COL3, COL4, COL5, COL6, COL7, COL8);
