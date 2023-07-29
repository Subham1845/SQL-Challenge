/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Bonus Questions
-- 1. Join All The Things => Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
-- 2. Rank All The Things => Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.




CREATE SCHEMA dannys_diner;
use dannys_diner;
CREATE TABLE sales (
 customer_id VARCHAR(1),
 order_date DATE,
 product_id INTEGER
);

INSERT INTO sales 
	(customer_id, order_date, product_id)
VALUES
('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
    
  CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;
 
-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, sum(price) as total_sales
FROM sales s JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, count(DISTINCT order_date) as no_of_times_visited
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH ordered_sales AS (
	SELECT customer_id, order_date, product_name, 
    DENSE_RANK() OVER(partition by customer_id order by order_date) as ranking
    FROM sales s JOIN menu m ON s.product_id = m.product_id
) 

SELECT customer_id, product_name FROM ordered_sales 
WHERE ranking = 1 
GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, count(s.product_id) as no_of_times_purchased
FROM sales s JOIN menu m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY no_of_times_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH ordered_item AS (
	SELECT s.customer_id, m.product_name, count(m.product_id) AS order_count,
    DENSE_RANK() OVER(partition by s.customer_id order by COUNT(s.customer_id) DESC) AS ranking
    FROM menu m JOIN sales s ON m.product_id = s.product_id
    GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, order_count FROM ordered_item 
WHERE ranking = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH joined_as_member AS (
	SELECT m.customer_id, s.product_id,
    row_number() over(partition by m.customer_id ORDER BY s.order_date) as row_num
	FROM members m JOIN sales s ON m.customer_id = s.customer_id
    AND s.order_date > m.join_date
)

SELECT customer_id, product_name
FROM joined_as_member jm JOIN menu m 
ON jm.product_id = m.product_id
WHERE row_num = 1
ORDER BY customer_id ASC;

-- 7. Which item was purchased just before the customer became a member?

WITH joined_as_member AS (
	SELECT m.customer_id, s.product_id,
    row_number() over(partition by m.customer_id ORDER BY s.order_date DESC) as row_num
	FROM members m JOIN sales s ON m.customer_id = s.customer_id
    AND s.order_date < m.join_date
)

SELECT customer_id, product_name
FROM joined_as_member jm JOIN menu m 
ON jm.product_id = m.product_id
WHERE row_num = 1
ORDER BY customer_id ASC;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id,	COUNT(s.product_id) AS total_items, SUM(me.price) AS total_sales
FROM sales s JOIN members m 
ON s.customer_id = m.customer_id AND s.order_date < m.join_date
JOIN menu me ON s.product_id = me.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points_calc AS (
	 SELECT 
     product_id,
     case
		when product_id = 1 then price*20
        else price*10
     end as points
     FROM menu
)

SELECT s.customer_id, sum(pc.points) as total_points
FROM sales s JOIN points_calc pc
ON s.product_id = pc.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH dates_cte AS (
	SELECT 
    customer_id, 
      join_date, 
      DATE_ADD('2021-01-31', INTERVAL 6 DAY) AS valid_date
	FROM members
)

SELECT 
  s.customer_id, 
  SUM(CASE
    WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
    WHEN s.order_date BETWEEN dates.join_date AND dates.valid_date THEN 2 * 10 * m.price
    ELSE 10 * m.price END) AS points
FROM sales s
INNER JOIN dates_cte AS dates
  ON s.customer_id = dates.customer_id
  AND dates.join_date <= s.order_date
INNER JOIN menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY points DESC;

-- Bonus Questions
-- 1. Join All The Things => Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

SELECT 
  s.customer_id, 
  s.order_date,  
  m.product_name, 
  m.price,
  CASE
  WHEN mm.join_date > s.order_date THEN "N"
  WHEN mm.join_date <= s.order_date THEN 'Y'
  ELSE "N"
  END as member_status
  
  FROM sales s LEFT JOIN members mm
  ON s.customer_id = mm.customer_id
  JOIN menu m 
  ON s.product_id = m.product_id
ORDER BY mm.customer_id, s.order_date;

-- 2. Rank All The Things => Danny also requires further information about the ranking of customer products, 
-- but he purposely does not need the ranking for non-member purchases so he expects null ranking values for 
-- the records when customers are not yet part of the loyalty program.

WITH customer_data as(
  SELECT s.customer_id, 
  s.order_date,  
  m.product_name, 
  m.price,
  CASE
  WHEN mm.join_date > s.order_date THEN "N"
  WHEN mm.join_date <= s.order_date THEN 'Y'
  ELSE "N"
  END as member_status
  FROM sales s LEFT JOIN members mm
  ON s.customer_id = mm.customer_id
  JOIN menu m 
  ON s.product_id = m.product_id
  )
 SELECT *,
	case
    when member_status ='N' then null
    else RANK() OVER(partition by customer_id, member_status order by order_date) end  as ranking
FROM customer_data;
 
  
  
  
  
  
