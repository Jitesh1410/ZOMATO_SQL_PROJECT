--Zomato Data Analysis using SQL.
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS restaurant;
DROP TABLE IF EXISTS rider;
DROP TABLE IF EXISTS deliveries;

CREATE TABLE customer(
customer_id INT PRIMARY KEY,
customer_name VARCHAR(30),
reg_date DATE
);


CREATE TABLE restaurant(
restaurant_id INT PRIMARY KEY,
restaurant_name VARCHAR(30),
city VARCHAR(30),
opening_hours VARCHAR(50)
);


CREATE TABLE orders(
order_id INT PRIMARY KEY,
customer_id INT,
restaurant_id INT,
order_item VARCHAR(50),
order_date DATE,
order_time TIME,
order_status VARCHAR(30),
total_amount FLOAT
);


-- ADDING FOREIGN KEY CONSTRAINTS
ALTER TABLE orders
ADD CONSTRAINT fk_customers
FOREIGN KEY (customer_id)
REFERENCES customer(customer_id);


-- ADDING FOREIGN KEY CONSTRAINTS
ALTER TABLE orders
ADD CONSTRAINT fk_restaurant
FOREIGN KEY (restaurant_id)
REFERENCES restaurant(restaurant_id);

CREATE TABLE rider(
rider_id INT PRIMARY KEY,
rider_name VARCHAR(30),
sign_up_date DATE
);

CREATE TABLE deliveries(
order_id INT,
delivery_id INT PRIMARY KEY,
delivery_status VARCHAR(20),
delivery_time TIME,
rider_id INT,
CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
CONSTRAINT fk_rider FOREIGN KEY (rider_id) REFERENCES rider(rider_id)
);



---END OF SCHEMAS

