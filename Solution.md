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
