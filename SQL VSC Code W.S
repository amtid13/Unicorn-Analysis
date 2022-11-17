--Join all tables--
SELECT *
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
LEFT JOIN order_details ON orders.order_id = order_details.order_id
LEFT JOIN product ON order_details.product_id = product.product_id;

--1.How many customers do we have in the data?--
SELECT COUNT(DISTINCT(customer_id))
FROM customers;
--795--

--2.What was the city with the most profit for the company in 2015, and how much was it?--
SELECT shipping_city, SUM(order_profits) as total_profit
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
WHERE order_date LIKE '%2015%'
GROUP BY shipping_city
ORDER BY total_profit DESC;
--New York City 14753--

--3.How many different cities do we have in the data?
SELECT COUNT(DISTINCT(shipping_city))
FROM orders;
--531--

--4.Show the total spent by customers from low to high--
SELECT customer_id, SUM(order_sales) AS total_sales
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY customer_id
ORDER BY total_sales;
--546, 657--

--5.What is the most profitable city in the state of Tennessee?--
SELECT shipping_city, shipping_state, SUM(order_profits) as profitable
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
WHERE shipping_state LIKE '%Tennessee%'
GROUP BY shipping_city
ORDER BY profitable DESC;
--Lebanon--

--6.What is the avg annual profit for that city across all years?--
SELECT shipping_city, AVG(order_profits) as annual_profit
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
WHERE shipping_city LIKE '%Lebanon%';
--27.67--

--7.What is the distribution of customer types in the data?--
SELECT COUNT(customer_segment)
FROM customers
WHERE customer_segment = 'Corporate';
--237--

--8.What is the most profitable product category on avg in Iowa across all years?--
SELECT shipping_state, AVG(order_profits) as profit, product_category
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN product ON order_details.product_id = product.product_id
WHERE shipping_state = 'Iowa'
GROUP BY product_category
ORDER BY profit DESC;
--Furniture--

--9.What is the most popular product in that category across all states in 2016?--
SELECT order_date, product_category, product_name, SUM(quantity) as pop_quantity
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN product ON order_details.product_id = product.product_id
WHERE order_date LIKE '%2016%' AND product_category = 'Furniture'
GROUP BY product_name
ORDER BY pop_quantity DESC;
--Global Push Button Manager's Chair, Indigo--

--10.Which customer got the most discount in the data (total amt)?--
SELECT customer_id, 
	SUM(order_sales / (1 - order_discount) - order_sales) AS total_discount
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY customer_id
ORDER BY total_discount DESC;
--687--

--11.How widely did monthly profits vary in 2018?--
WITH table_1 AS 
	(SELECT
		CAST(SUBSTR(order_date, INSTR(order_date,'/') -2,2) AS INT) AS month,
		SUM(order_profits) AS total_profit,
		SUBSTR(order_date, -4, 4) as year
	FROM orders
	JOIN order_details ON orders.order_id = order_details.order_id
	WHERE year = '2018'
	GROUP BY month),
table_2 AS
	(SELECT
		CAST(SUBSTR(order_date,INSTR(order_date,'/') -2,2) AS INT) AS month,
		LAG(SUM(order_profits), 1,0)
		OVER (ORDER BY SUBSTR(order_date,INSTR(order_date, '/') -2,2) ) AS previous_month,
		SUBSTR(order_date, -4, 4) as year
	FROM orders
	JOIN order_details ON orders.order_id = order_details.order_id
	WHERE year = '2018'
	GROUP BY month
	ORDER BY month)

SELECT table_1.month, ABS(table_1.total_profit)-ABS(table_2.previous_month) AS change_in_profit
FROM table_1
JOIN table_2 ON table_1.month = table_2.month
ORDER BY change_in_profit DESC;
--(-13824)--

--12.Which order was the highest in 2015?--
SELECT order_date, orders.order_id, SUM(order_sales) AS sales
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
WHERE order_date LIKE '%2015%'
GROUP BY orders.order_id
ORDER BY sales DESC;
--CA-2015-145317--

--13.What was the rank of each city in the East region in 2015?--
SELECT shipping_city,
	SUM(quantity) AS amt_ordered,
	RANK() OVER (ORDER BY SUM(quantity) DESC) AS rank
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
WHERE order_date LIKE '%2015%' AND shipping_region = 'East'
GROUP BY shipping_city;
--Columbus--