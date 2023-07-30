CREATE SCHEMA pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
select * from runners;
select * from customer_orders;
select * from runner_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;

-- Data Cleaning & Transformation

-- Table: customer_orders
-- * Looking at the customer_orders table below, we can see that there are
-- 1. In the exclusions column, there are missing/ blank spaces ' ' and null values.
-- 2. In the extras column, there are missing/ blank spaces ' ' and null values.
-- * Our course of action to clean the table:
-- 1. Create a temporary table with all the columns
-- 2. Remove null values in exlusions and extras columns and replace with blank space ' '.

CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT order_id, customer_id, pizza_id, 
 CASE
	  WHEN exclusions IS null OR exclusions LIKE 'null' THEN ''
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN extras IS NULL or extras LIKE 'null' THEN ''
	  ELSE extras
	  END AS extras,
	order_time
FROM customer_orders;

SELECT * FROM customer_orders_temp;

-- Table: runner_orders
-- * Looking at the runner_orders table below, we can see that there are
-- 1. In the exclusions column, there are missing/ blank spaces ' ' and null values.
-- 2. In the extras column, there are missing/ blank spaces ' ' and null values

-- * Our course of action to clean the table:
-- 1. In pickup_time column, remove nulls and replace with blank space ' '.
-- 2. In distance column, remove "km" and nulls and replace with blank space ' '.
-- 3. In duration column, remove "minutes", "minute" and nulls and replace with blank space ' '.
-- 4. In cancellation column, remove NULL and null and and replace with blank space ' '.

CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT order_id, runner_id,
 CASE
	  WHEN pickup_time IS null OR pickup_time LIKE 'null' THEN ''
	  ELSE pickup_time
	  END AS pickup_time,
  CASE
	  WHEN distance IS NULL or distance LIKE 'null' THEN ''
	  ELSE distance
	  END AS distance,
  CASE
	  WHEN duration IS NULL or duration LIKE 'null' THEN ''
	  ELSE duration
	  END AS duration,
  CASE
	  WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ''
	  ELSE cancellation
	  END AS cancellation
FROM runner_orders;

-- Then, we alter the pickup_time, distance and duration columns to the correct data type. 
ALTER TABLE runner_orders_temp
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration INT;

SELECT * FROM runner_orders_temp;

-- SQL QUERIES - FINDING ALL THE METRICS
-- -----------------------------------------------------------------------------------------------------------------------
-- A. Pizza Metrics

-- How many pizzas were ordered?
SELECT COUNT(*) FROM customer_orders_temp;

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) as unique_order_count FROM customer_orders_temp;

-- How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS successful_orders 
FROM runner_orders_temp 
WHERE distance != 0
GROUP BY runner_id;

-- How many of each type of pizza was delivered?
SELECT p.pizza_name, COUNT(p.pizza_id) AS pizza_delivered 
FROM customer_orders_temp co JOIN runner_orders_temp ro
ON co.order_id = ro.order_id
JOIN pizza_names AS p
ON co.pizza_id = p.pizza_id
WHERE distance != 0
GROUP BY p.pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT co.customer_id, p.pizza_name, COUNT(p.pizza_id) AS order_count
FROM customer_orders_temp co JOIN pizza_names p
ON co.pizza_id = p.pizza_id
GROUP BY co.customer_id, p.pizza_name
ORDER BY co.customer_id;

-- What was the maximum number of pizzas delivered in a single order?
SELECT co.order_id, COUNT(customer_id) AS pizza_per_order 
FROM customer_orders_temp co JOIN runner_orders_temp ro
ON co.order_id = ro.order_id
WHERE ro.distance != 0
GROUP BY order_id
ORDER BY pizza_per_order DESC LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT co.customer_id, 
    SUM(
    CASE WHEN exclusions <> '' OR extras <> '' THEN 1
    ELSE 0
    END) AS at_least_1_change,
    SUM(
    CASE WHEN co.exclusions = '' AND co.extras = '' THEN 1
    ELSE 0
    END) AS no_change
FROM customer_orders_temp co JOIN runner_orders_temp r
ON co.order_id = r.order_id
WHERE r.distance != 0
GROUP BY co.customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT SUM(
    CASE WHEN exclusions <> '' AND extras <> '' THEN 1
    ELSE 0
    END) AS pizza_count
FROM customer_orders_temp c 
JOIN runner_orders_temp r 
ON c.order_id = r.order_id
WHERE r.distance >= 1;

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time) as hour_of_day, 
COUNT(order_id) as pizza_count
FROM customer_orders_temp
GROUP BY hour_of_day;

-- What was the volume of orders for each day of the week?
SELECT 
  DATE_FORMAT(DATE_ADD(order_time, INTERVAL 2 DAY),'%W') AS day_of_week,
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders_temp
GROUP BY day_of_week;


-- ********************************************************************
-- B. Runner and Customer Experience

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT EXTRACT(WEEK FROM registration_date)+1 as registration_week, 
COUNT(runner_id) as runner_count
FROM runners
GROUP BY registration_week;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH time_taken AS (
SELECT  c.order_id, c.order_time, ro.pickup_time, TIMESTAMPDIFF(MINUTE, order_time, ro.pickup_time) as pickup_min 
FROM customer_orders_temp c JOIN runner_orders_temp ro
ON c.order_id = ro.order_id
WHERE ro.distance != 0
GROUP BY c.order_id, c.order_time, ro.pickup_time
)
SELECT AVG(pickup_min) as avg_pickup_minutes
FROM time_taken
WHERE pickup_min > 1; 

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH orders_group AS (
   SELECT c.order_id, count(c.order_id) AS pizza_count, 
      TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS time_diff 
   FROM customer_orders_temp c JOIN runner_orders_temp r
   ON c.order_id = r.order_id
   GROUP BY c.order_id, r.pickup_time, c.order_time
   ORDER BY c.order_id
 )
 SELECT pizza_count, AVG(time_diff) 
 FROM orders_group
 GROUP BY pizza_count;

-- What was the average distance travelled for each customer?
SELECT customer_id, AVG(distance) AS average_distance
FROM customer_orders_temp c JOIN runner_orders_temp r
ON c.order_id = r.order_id
WHERE r.duration != 0
GROUP BY customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration)-MIN(duration) AS time_difference_order
FROM runner_orders r
WHERE r.duration != 0;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
  r.runner_id, 
  c.customer_id, 
  c.order_id, 
  COUNT(c.order_id) AS pizza_count, 
  r.distance, (r.duration / 60) AS duration_hr , 
  ROUND((r.distance/r.duration * 60), 2) AS avg_speed
FROM runner_orders_temp AS r
JOIN customer_orders_temp AS c
  ON r.order_id = c.order_id
WHERE distance != 0
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
ORDER BY c.order_id;

-- What is the successful delivery percentage for each runner?
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM runner_orders_temp
GROUP BY runner_id;

-- *************************************************************************
-- C. Ingredient Optimisation

-- What are the standard ingredients for each pizza?
SELECT pn.pizza_id, topping_name
FROM pizza_names pn JOIN pizza_recipes pr
ON pn.pizza_id = pr.pizza_id 
JOIN pizza_toppings pt
ON  pr.toppings = pt.topping_id
GROUP BY pn.pizza_id, topping_name;

-- What was the most commonly added extra?
WITH toppings_cte AS (
SELECT
  pizza_id,
  substring_index(substring_index(toppings, ',', 2), ',', -1) AS topping_id
FROM pizza_recipes)

SELECT 
  t.topping_id, pt.topping_name, 
  COUNT(t.topping_id) AS topping_count
FROM toppings_cte t
INNER JOIN pizza_toppings pt
  ON t.topping_id = pt.topping_id
GROUP BY t.topping_id, pt.topping_name
ORDER BY topping_count DESC;





  