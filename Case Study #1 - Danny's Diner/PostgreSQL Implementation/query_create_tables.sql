--CREATE SCHEMA "dannys_diner";
CREATE TABLE dannys_diner.members 
	(
	customer_id CHAR(10),
	join_date DATE
	);

INSERT INTO dannys_diner.members
VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

CREATE TABLE dannys_diner.menu 
	(
	product_id INT,
	product_name VARCHAR(50),
	price INT
	);

INSERT INTO dannys_diner.menu
VALUES
(1, 'sushi', 10),
(2, 'curry', 15),
(3, 'ramen', 12);


CREATE TABLE dannys_diner.sales 
	(
	customer_id CHAR(10),
	order_date DATE,
	product_id INT
	);

INSERT INTO dannys_diner.sales
VALUES
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);