


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
GROUP BY customer_id;
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
SELECT
	customer_id,
    COUNT(s.product_id) AS product_cnt
FROM sales s
JOIN menu m 
	ON s.product_id = m.product_id
WHERE product_name = 'ramen'
GROUP BY  s.product_id, customer_id;
-- A and C ordered ramen 3 times while B did it twice.

-- 5. Which item was the most popular for each customer?
SELECT
	s.customer_id,
    COUNT(m.product_id) as product_cnt,
    m.product_name
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
WHERE s.customer_id = 'A'
GROUP BY s.customer_id, m.product_id
ORDER BY product_cnt DESC;
-- Ramen was the most popular for A.
SELECT
	s.customer_id,
    COUNT(m.product_id) as product_cnt,
    m.product_name
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
WHERE s.customer_id = 'B'
GROUP BY s.customer_id, m.product_id
ORDER BY product_cnt DESC;
-- B ordered all product twice.
SELECT
	s.customer_id,
    COUNT(m.product_id) as product_cnt,
    m.product_name
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
WHERE s.customer_id = 'C'
GROUP BY s.customer_id, m.product_id
ORDER BY product_cnt DESC;
-- Ramen was the most popular for C.

-- 6. Which item was purchased first by the customer after they became a member?
SELECT
	*
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
JOIN members e
	ON s.customer_id = e.customer_id
WHERE order_date > join_date
ORDER BY order_date
    
    
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
