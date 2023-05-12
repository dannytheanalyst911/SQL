# SQL
My intermediate and advanced SQL querries are shown in the section
# Dinner practice SQL challenge by Danny Ma

Link: [https://8weeksqlchallenge.com/getting-started/](https://8weeksqlchallenge.com/case-study-1/)

Tables.

![image](https://user-images.githubusercontent.com/107795987/229900115-017d6aae-9caf-46e8-96d2-d9953b4c9903.png)

1. What is the total amount each customer spent at the restaurant?
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
  ![image](https://github.com/dannytheanalyst911/SQL-Danny-s-Diner/assets/107795987/5431431d-b378-4edf-a796-19da21546338)
