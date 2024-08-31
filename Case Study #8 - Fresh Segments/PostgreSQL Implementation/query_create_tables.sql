-- https://embed.db-fiddle.com/51202689-29e3-4e8b-b585-41270b8f7103

CREATE SCHEMA fresh_segments;

DROP TABLE IF EXISTS fresh_segments.interest_map;
CREATE TABLE fresh_segments.interest_map (
  "id" INTEGER,
  "interest_name" TEXT,
  "interest_summary" TEXT,
  "created_at" TIMESTAMP,
  "last_modified" TIMESTAMP
);

DROP TABLE IF EXISTS fresh_segments.interest_metrics;
CREATE TABLE fresh_segments.interest_metrics
	(
	_month INT,
	_year DOUBLE PRECISION,
	month_year CHARACTER VARYING,
	interest_id BIGINT,
	composition FLOAT,
	index_value FLOAT,
	ranking INT,
	percentile_ranking FLOAT
	);