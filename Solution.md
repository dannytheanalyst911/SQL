### 1. What is the total amount each customer spent at the restaurant?

````sql
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
````

#### Steps:
- Use **SUM** and **GROUP BY** to find out ```total_spent``` each customer spent at restaurent.
- Use **JOIN** to merge ```sales``` and ```menu``` tables as ```customer_id``` and ```price``` are from both tables.

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT
  customer_id,
  COUNT(DISTINCT(order_date)) AS day_visited
FROM sales
GROUP BY customer_id;
````
#### Steps:
- Use **COUNTDISTINCT** and **GROUP BY** to find out customer's ```day_visited``` at restaurant.


#### Answer:
| customer_id | day_visited |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 days.
- Customer B visited 6 days.
- Customer C visited 2 days.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
WITH rank_table AS (
	SELECT
		*,
		DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as rank_customer
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
````

#### Steps:
- Create temp table ```rank_table``` to calculate rank of the ```order_date```.
- Use **DENSE_RANK** and  to find to rank the ```order_date``` by ```customer_id```.
- Join ```rank_table```and ```menu```.
- Take the only first item by apply filter **WHERE** with ```rank_customer```as 1.


#### Answer:
| customer_id | product_name |
| ----------- | ----------- |
| A           | sushi          |
| A           | curry          |
| B           | curry          |
| C           | ramen         |

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
````sql
SELECT
	product_name,
	COUNT(s.product_id) AS product_cnt
FROM sales s
JOIN menu m 
	ON s.product_id = m.product_id
GROUP BY  s.product_id
ORDER BY product_cnt DESC
LIMIT 1;
````

#### Steps:
- Use **COUNT** ```product_id```and aggregate by ```product_id```.
- Order by ```product_id``` decending and **LIMIT** by 1 so the item bought the most time appear on the result.

#### Answer:
| product_name | product_cnt |
| ----------- | ----------- |
| ramen           | 8          |

***

### 5. Which item was the most popular for each customer?
````sql
WITH fav_dish AS
(
	SELECT  
		s.customer_id,
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
````

#### Steps:
- Create temp table ```fav_dish```: join ```sales```and ```menu```table, then **COUNT** ```customer_id```to calculate ```order_times```.
- Within the ```fav_dish```, rank **COUNT** of ```product_id```descending by ```customer_id```to give the ordered-the-most-time item rank 1 for each customer.
- Select the attributes that we need to see while setting ```rank_fav_dish```= 1.

#### Answer:
| customer_id | product_name | order_times |
| ----------- | ----------- |--------------|
| A           | ramen         |3  |
| B           | curry          |2|
| B           | sushi         |2|
| B           | ramen         |2|
| C           | ramen         |3  |

***

### 6. Which item was purchased first by the customer after they became a member?
````sql
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
````
#### Steps:
- In ```rank_table``` tamp table, join all 3 tables we have and set ```order_date```>=```join_date```so our table only left with orders after they becoming members.
- Rank ```order_date```by ```customer_id```to set the earliest order after A & B became members rank 1.
- Set ```rank_date```= 1 and pull out the information we need.

#### Answer:
| customer_id | product_name | order_date |
| ----------- | ----------- |--------------|
| A           | curry        |2021-01-07  |
| B           | sushi         |2021-01-11|

***

### 7. Which item was purchased just before the customer became a member?
````sql
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
````

#### Steps:
- Same like number 6, but this time we set ```order_date```< ```join_date```.
- Rank the same, but ```order_date```set to descending so the order that customer purchase right before they became member come at rank first.

#### Answer:
| customer_id | product_name | order_date |
| ----------- | ----------- |--------------|
| A           |  sushi       |2021-01-01  |
| A           | curry        |2021-01-01|
| B           | sushi         |2021-01-04|

***

### 8. What is the total items and amount spent for each member before they became a member?
````sql
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
````
#### Steps:
- Join 3 tables, set ```order_date```< ```join_date```.
- Use **COUNT** ```product_id```and **SUM** ```price```then **GROUP BY** ```customer_id```.

#### Answer:
| customer_id | total_items | amount_spent |
| ----------- | ----------- |--------------|
| A           |  sushi       |25  |
| B           | curry        |40|

***
### 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
````sql
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
````
#### Steps:
- Create temp table ```point_table```, add the column ```point_earned``` using **CASE** to set the rule every dollar for 10 points and sushi gets double.
- Join ```sales```table, then use **SUM** and **GROUP BY** to calculate ```total_point``` by ```customer_id```.

#### Answer:
| customer_id | total_points |
| ----------- | ----------- |
| A           | 860          |
| B           | 940          |
| C           | 360          |

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
````sql
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
````

#### Steps:
- Create temp table ```date_cte```, use **DATE_ADD** to add 6 days to ```join_date```, aslo use **LAST_DAY** to set ```last_day```was 2021-01-31.
- Use **CASE** to set the rules: if the product is sushi then 20 points, if the order date within the first week after member subcription (between ```join_date```and ```valid_date```) then 20 points, otherwise 10 point.
- Join ```date_cte``` with ```sales```and ```menu```table. Since we calculate in January, so set ```order_date``` < ```last_date```.
- Wrap the table we just createin another teamp table name ```point_table```.
- Use **SUM** and **GROUP BY** to calculate the ```total_points```.

#### Answer:
| customer_id | total_points |
| ----------- | ----------- |
| A           | 1370     |
| B           | 820      |
