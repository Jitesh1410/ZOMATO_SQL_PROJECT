--EDA
SELECT * FROM restaurant;
SELECT * FROM customer;
SELECT * FROM orders;
SELECT * FROM deliveries;
SELECT * FROM rider;
 
--IMPORT DATASET

--CHECKING NULL VALUES

SELECT * FROM restaurant
WHERE restaurant_name IS NULL
		OR
	  city IS NULL
	    OR
	  opening_hours IS NULL;


SELECT * FROM customer
WHERE customer_name IS NULL
		OR
	  reg_date IS NULL;


SELECT * FROM orders
WHERE customer_id IS NULL
		OR
	  restaurant_id IS NULL
	    OR
	  order_item IS NULL
	    OR
	  order_date IS NULL
	   OR
	  order_time IS NULL
	   OR
	  order_status IS NULL
	   OR
	  total_amount IS NULL;



SELECT * FROM  deliveries
WHERE order_id IS NULL
		OR
	  delivery_status IS NULL
	    OR
	  delivery_time IS NULL
	   OR
	  rider_id IS NULL;


SELECT * FROM rider
WHERE rider_name IS NULL
		OR
	  sign_up_date IS NULL;






------------------------------------------------------------------------------------------------------------------------------------
--ANALYSIS


--Q1 
--Write a query to find the top 3 most frequently ordered dishes by "Anahita Ratti" in last 1 year.

SELECT c.customer_name,c.customer_id,o.order_item as dishes,COUNT(*) AS total_orders
FROM orders as o
JOIN
customer as c
ON c.customer_id = o.customer_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 Year'
AND
c.customer_name = 'Anahita Ratti'
GROUP BY 1,2,3
ORDER BY 4 DESC
LIMIT 3;


--Q2 popular time slot
--Identify the time slot during which most of the orders are place --interval 2 hours
SELECT
CASE 
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 10:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
END AS time_slot,
COUNT(order_id) as order_count
FROM orders
GROUP BY 1
ORDER BY order_count DESC;


--Q3
--Find the average order value per customer who have place atleast 20 orders.
SELECT
c.customer_name,
ROUND(AVG(total_amount)) as Average_order_vale
FROM orders as o
JOIN
customer as c
ON o.customer_id = c.customer_id
GROUP BY 1
HAVING COUNT(o.customer_id) >= 20
ORDER BY 2 DESC;

--Q4
--List the customer who have spend more than 10k on food orders.
--Return customer name and customer_id
SELECT 
o.customer_id,
c.customer_name
FROM orders as o
JOIN customer as c
ON o.customer_id = c.customer_id
GROUP BY 1,2
HAVING SUM(total_amount) > 10000;


--Q5
--Write a query to find the order that were placed and later cancelled
--Return restaurant name,city and number of orders cancelled
SELECT 
r.restaurant_name,
r.city,
COUNT(o.order_id) as cancelled
FROM orders as o
JOIN restaurant as r
ON o.restaurant_id = r.restaurant_id
WHERE order_status = 'Cancelled'
GROUP BY 1,2;


--Q6 Restaurant revenue Ranking
--Rank restaurnat by total revenue from last 1 year
--Total revenue and rank 1 in each city
WITH ranking_table
AS
(
SELECT
r.city,
r.restaurant_name,
ROUND(SUM(o.total_amount)) as total_revenue,
RANK()OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) as rank
FROM restaurant as r
JOIN
orders as o
ON r.restaurant_id = o.restaurant_id 
WHERE o.order_date > CURRENT_DATE - INTERVAL '1 YEAR'
GROUP BY 1,2
)
SELECT * FROM ranking_table
WHERE rank =1;


--Q7
--Most popular dish by city:
--indentify the most popular dish by city in terms of number of orders
SELECT * FROM
(
SELECT 
r.city,
o.order_item as dish,
COUNT(o.order_id) as Total_count,
RANK() OVER(PARTITION BY r.city ORDER BY COUNT(o.order_id) DESC) AS rank
FROM restaurant as r
JOIN
orders as o
ON r.restaurant_id = o.restaurant_id 
GROUP BY 1,2
) as t1
WHERE rank = 1 ;

--Q8 Customer Churn:
--Find the Customer who haven't place order in 2025 but did in 2024
SELECT DISTINCT(customer_id)  from orders
WHERE EXTRACT(YEAR FROM order_date) = 2025
AND 
customer_id NOT IN
(SELECT DISTINCT(customer_id)  from orders
WHERE EXTRACT(YEAR FROM order_date) = 2024);


--Q9 Restaurant growth ratio monthly based on total_orders delivered
WITH month_ratio
AS(
SELECT
restaurant_id,
TO_CHAR(order_date, 'yy-mm') as month,
COUNT(order_id) as total_order_delivered,
LAG(COUNT(order_id))OVER(PARTITION BY restaurant_id ORDER BY TO_CHAR(order_date, 'yy-mm')) AS previous_month
FROM orders
WHERE order_status = 'Delivered'
GROUP BY 1,2
ORDER BY 1,2
)
SELECT 
restaurant_id,month,total_order_delivered,previous_month,
ROUND((total_order_delivered::numeric-previous_month::numeric)/previous_month::numeric * 100,2) as ratio
FROM month_ratio;


--Q10 Customer Segmentation:
-- Customer Segmentation:Segment customers into 'Gold' or 'Silver' groups based on their total spending
--compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
--label them as 'Gold'; otherwise, label them as 'Silver', Write an SQL query to determine each segment's
--total number of orders and total revenue
SELECT category,
SUM(total_orders) as total_orders,
SUM(total_spend) as total_revenue
FROM
(SELECT 
customer_id,
SUM(total_amount) AS total_spend,
COUNT(order_id) as total_orders,
CASE
WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM orders) THEN 'GOLD'
ELSE 'SILVER'
END AS category
FROM orders
GROUP BY 1) AS t1
GROUP BY 1;


--Q11 Rider Monthly order incentive
--Calculate rider monthly incentive assume that they earn 35% of order amount
SELECT 
d.rider_id,
TO_CHAR(o.order_date,'yy-mm') as month,
ROUND(SUM(total_amount)*0.35) as earning
FROM orders as o
JOIN
deliveries as d
ON o.order_id = d.order_id
GROUP BY 1,2
ORDER BY 1,2;


--Q12 Order Frequency by day
--Analyze order frequency per day of weeek and identify the peak day of week for each restaurant
SELECT 
restaurant_name,
day,
total_orders
FROM(
SELECT
r.restaurant_name,
TO_CHAR(order_date, 'DAY') AS day,
COUNT(o.order_id) AS total_orders,
RANK()OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) AS RANK
FROM orders as o
JOIN 
restaurant as r
ON o.restaurant_id = r.restaurant_id
GROUP BY 1,2
ORDER BY 3 DESC) AS t1
WHERE RANK = 1;


--Q13-- Customer lifetime value(CLV)
--Calculate the total revenue genrated by each customer

SELECT 
c.customer_name,
ROUND(SUM(total_amount)) as CLV
FROM orders as o
JOIN
customer as c
ON o.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC;

--Q14 Monthly Sales Trend
--Identify Sales trend by comparing each month total sales to previous month.

SELECT 
TO_CHAR(order_date, 'yy-mm') AS month,
ROUND(SUM(total_amount)) as total_sales,
ROUND(LAG(SUM(total_amount),1)OVER(ORDER BY TO_CHAR(order_date, 'yy-mm'))) AS previous_month
FROM orders
GROUP BY 1;


--Q15 Order Item Popularity
--Track the popularity of the item over time and identify seasonal demand spike

SELECT
order_item,
seasons,
COUNT(order_id) as total_orders
FROM
(
SELECT *,
EXTRACT(MONTH FROM order_date),
CASE
WHEN EXTRACT(MONTH FROM order_date) BETWEEN 1 AND 5 THEN 'SUMMER'
WHEN EXTRACT(MONTH FROM order_date) BETWEEN 6 AND 9 THEN 'MONSOON'
ELSE 'WINTER'
END AS seasons
FROM orders) as t1
GROUP BY 1,2
ORDER BY 1,3 DESC;

