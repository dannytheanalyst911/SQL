--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Danny Vu
--Date: 13/04/2023 (updated 12/05/2023)
--Tool used: MySQL 8.0

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
  /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	s.customer_id,
    SUM(m.price) AS total_spent
FROM dannys_diner.sales AS s
	JOIN dannys_diner.menu AS m
    ON s.product_id = m.product_id
GROUP BY 
	customer_id
ORDER BY
	customer_id;
-- A spent 76$, B spent 75$ and C spent 36$.

-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
    COUNT(DISTINCT(order_date)) AS day_visited
FROM sales
GROUP BY customer_id;
-- A visited 4 days while B and C came 6 and 2 days perspectively.

-- 3. What was the first item from the menu purchased by each customer?
WITH rank_table AS (
	SELECT
		*,
		dense_rank() over(partition by s.customer_id order by s.order_date) as rank_customer
	FROM sales s 
)
SELECT 
	customer_id,
    product_name
FROM rank_table
JOIN menu m 
		ON rank_table.product_id = m.product_id
WHERE rank_customer = 1
GROUP BY customer_id, product_name;
-- A's first order was sushi, B's was curry and C's was ramen.

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
    product_name,
    COUNT(s.product_id) AS product_cnt
FROM sales s
JOIN menu m 
	ON s.product_id = m.product_id
GROUP BY  s.product_id
ORDER BY product_cnt DESC
LIMIT 1;
-- Ramen was the most purchased item on the menu.

-- 5. Which item was the most popular for each customer?
WITH fav_dish AS
(
	SELECT  s.customer_id,
			m.product_name,
			COUNT(s.customer_id) as order_times,
			dense_rank() over(partition by s.customer_id order by (COUNT(s.product_id)) DESC) AS rank_fav_dish
	FROM sales s
    JOIN menu m
		ON s.product_id = m.product_id
	GROUP BY customer_id, m.product_name
)
SELECT
	customer_id,
    product_name,
    order_times
FROM fav_dish
WHERE rank_fav_dish=1;



-- 6. Which item was purchased first by the customer after they became a member?
WITH rank_table AS
(
	SELECT
		s.customer_id,
        s.order_date,
		m.product_name,
		dense_rank() over(partition by s.customer_id order by s.order_date) as rank_date
	FROM sales s
    JOIN menu m
		ON s.product_id = m.product_id
	JOIN members e
		ON s.customer_id = e.customer_id
	WHERE order_date >= join_date
)
SELECT
	customer_id,
    product_name,
    order_date
FROM rank_table
WHERE rank_date=1;
	
    
    
-- 7. Which item was purchased just before the customer became a member?
WITH rank_table AS
(
	SELECT
		s.customer_id,
        s.order_date,
		m.product_name,
		dense_rank() over(partition by s.customer_id order by s.order_date DESC) as rank_date
	FROM sales s
    JOIN menu m
		ON s.product_id = m.product_id
	JOIN members e
		ON s.customer_id = e.customer_id
	WHERE order_date < join_date
)
SELECT
	customer_id,
    product_name,
    order_date
FROM rank_table
WHERE rank_date=1;
-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
	s.customer_id,
    COUNT(s.product_id) as total_items,
    SUM(m.price) as amount_spent
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
JOIN members e
	ON s.customer_id = e.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH point_table AS
(
	SELECT 
		*,
    CASE 
      WHEN product_name='sushi' THEN price*20
			ELSE price*10
		END as point_earned
	FROM menu m
)
SELECT
	customer_id,
    SUM(point_earned) as total_points
FROM sales s
JOIN point_table p
	ON s.product_id = p.product_id
GROUP BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH point_table AS
(
WITH date_cte AS
(
	SELECT
		*,
        DATE_ADD(join_date, INTERVAL 6 DAY) as valid_date,
        LAST_DAY('2021-01-01') as last_day
	FROM members mm
)
SELECT
	s.customer_id,
    CASE
		WHEN order_date between join_date and valid_date THEN price*20
        WHEN product_name='sushi' THEN price*20
			ELSE price*10
		END as points
FROM date_cte d
JOIN sales s
	ON s.customer_id = d.customer_id
JOIN menu m 
	ON s.product_id = m.product_id
WHERE order_date < last_day
)
SELECT
	customer_id,
    SUM(points) AS total_points
FROM point_table
GROUP BY customer_id
ORDER BY customer_id
