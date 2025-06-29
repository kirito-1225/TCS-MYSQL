
-- First

CREATE DATABASE travel_db;

USE travel_db;

-- a) Database Design and Sample Data

-- Drop tables if they exist to ensure a clean slate
DROP TABLE IF EXISTS HOTEL_BOOKINGS;
DROP TABLE IF EXISTS HOTELS;
DROP TABLE IF EXISTS PAYMENTS;
DROP TABLE IF EXISTS BOOKINGS;
DROP TABLE IF EXISTS CUSTOMERS;
DROP TABLE IF EXISTS DESTINATIONS;

-- 1. CUSTOMERS Table
CREATE TABLE CUSTOMERS (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    country VARCHAR(50),
    registration_date DATE NOT NULL
);

-- 2. DESTINATIONS Table
CREATE TABLE DESTINATIONS (
    dest_id INT PRIMARY KEY AUTO_INCREMENT,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    avg_temperature DECIMAL(5, 2),
    best_season VARCHAR(50)
);

-- 3. BOOKINGS Table
CREATE TABLE BOOKINGS (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    dest_id INT NOT NULL,
    booking_date DATE NOT NULL,
    travel_date DATE NOT NULL,
    return_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (dest_id) REFERENCES DESTINATIONS(dest_id)
);

-- 4. PAYMENTS Table
CREATE TABLE PAYMENTS (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES BOOKINGS(booking_id)
);

-- 5. HOTELS Table
CREATE TABLE HOTELS (
    hotel_id INT PRIMARY KEY AUTO_INCREMENT,
    dest_id INT NOT NULL,
    hotel_name VARCHAR(100) NOT NULL,
    rating DECIMAL(3, 1),
    price_per_night DECIMAL(10, 2),
    amenities TEXT,
    FOREIGN KEY (dest_id) REFERENCES DESTINATIONS(dest_id)
);

-- 6. HOTEL_BOOKINGS Table
CREATE TABLE HOTEL_BOOKINGS (
    hb_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    hotel_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    rooms INT NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES BOOKINGS(booking_id),
    FOREIGN KEY (hotel_id) REFERENCES HOTELS(hotel_id)
);

-- Indexes for performance optimization
CREATE INDEX idx_customer_email ON CUSTOMERS(email);
CREATE INDEX idx_booking_customer_id ON BOOKINGS(customer_id);
CREATE INDEX idx_booking_dest_id ON BOOKINGS(dest_id);
CREATE INDEX idx_payment_booking_id ON PAYMENTS(booking_id);
CREATE INDEX idx_hotel_dest_id ON HOTELS(dest_id);
CREATE INDEX idx_hotel_booking_booking_id ON HOTEL_BOOKINGS(booking_id);
CREATE INDEX idx_hotel_booking_hotel_id ON HOTEL_BOOKINGS(hotel_id);


-- Insert Sample Data (minimum 5 records per table, with latest dates for query satisfaction)
-- All prices are in $ dollars.

-- CUSTOMERS
INSERT INTO CUSTOMERS (name, email, phone, country, registration_date) VALUES
('Alice Smith', 'alice.s@example.com', '111-222-3333', 'USA', '2024-01-15'),
('Bob Johnson', 'bob.j@example.com', '444-555-6666', 'Canada', '2024-02-20'),
('Charlie Brown', 'charlie.b@example.com', '777-888-9999', 'UK', '2024-03-01'),
('Diana Prince', 'diana.p@example.com', '123-456-7890', 'USA', '2024-04-10'),
('Eve Adams', 'eve.a@example.com', '987-654-3210', 'Australia', '2024-05-05'),
('Frank White', 'frank.w@example.com', '555-111-2222', 'USA', '2024-06-20'), -- Registered recently
('Grace Lee', 'grace.l@example.com', '222-333-4444', 'South Korea', '2023-11-01'),
('Yuuki kaoru', 'yuuki.s@example.com', '111-255-3333', 'USA', '2024-02-15');

-- DESTINATIONS
INSERT INTO DESTINATIONS (city, country, category, avg_temperature, best_season) VALUES
('Paris', 'France', 'Romantic', 15.5, 'Spring'),
('Tokyo', 'Japan', 'Cultural', 20.0, 'Autumn'),
('New York', 'USA', 'City Break', 18.2, 'Autumn'),
('Sydney', 'Australia', 'Beach', 25.0, 'Summer'),
('Rome', 'Italy', 'Historic', 22.0, 'Spring'),
('London', 'UK', 'City Break', 12.0, 'Summer'),
('Dubai', 'UAE', 'Luxury', 30.0, 'Winter');

-- BOOKINGS
INSERT INTO BOOKINGS (customer_id, dest_id, booking_date, travel_date, return_date, status, total_amount) VALUES
(1, 1, '2025-06-20', '2025-07-10', '2025-07-17', 'Confirmed', 1500.00),
(2, 2, '2025-06-05', '2025-08-01', '2025-08-10', 'Confirmed', 2200.00),
(3, 3, '2025-05-15', '2025-09-01', '2025-09-07', 'Pending', 900.00), 
(1, 4, '2025-06-25', '2025-07-20', '2025-07-30', 'Confirmed', 3000.00),
(4, 5, '2025-04-01', '2025-06-15', '2025-06-20', 'Completed', 1800.00),
(1, 1, '2025-03-10', '2025-04-01', '2025-04-07', 'Completed', 1200.00),
(5, 6, '2025-06-01', '2025-07-05', '2025-07-12', 'Confirmed', 850.00), 
(6, 7, '2025-06-26', '2025-07-01', '2025-07-07', 'Confirmed', 5000.00),
(7, 2, '2024-12-01', '2025-01-10', '2025-01-15', 'Completed', 1900.00);


-- PAYMENTS
-- Ensure some payments are 'Completed' for trigger logic
INSERT INTO PAYMENTS (booking_id, payment_date, amount, payment_method, status) VALUES
(1, '2025-06-20', 1500.00, 'Credit Card', 'Completed'),
(2, '2025-06-05', 2200.00, 'PayPal', 'Completed'), 
(3, '2025-05-16', 900.00, 'Bank Transfer', 'Pending'), 
(4, '2025-06-25', 3000.00, 'Credit Card', 'Completed'),
(5, '2025-04-02', 1800.00, 'Credit Card', 'Completed'),
(6, '2025-03-10', 1200.00, 'Debit Card', 'Completed'),
(7, '2025-06-01', 850.00, 'Credit Card', 'Completed');


-- HOTELS
INSERT INTO HOTELS (dest_id, hotel_name, rating, price_per_night, amenities) VALUES
(1, 'Hotel Grand Paris', 4.8, 250.00, 'Pool, Spa, Wifi'),  
(2, 'Tokyo Inn', 4.2, 120.00, 'Wifi, Breakfast'),
(3, 'NYC Central Hotel', 3.9, 180.00, 'Gym, Wifi'),
(4, 'Sydney Beach Resort', 4.6, 300.00, 'Beach Access, Pool'),
(5, 'Roman Holiday Inn', 4.0, 150.00, 'Restaurant'),
(1, 'Eiffel Tower View', 4.9, 350.00, 'Balcony, City View'),
(6, 'London Blooms Hotel', 4.1, 100.00, 'Tea, Wifi');

-- HOTEL_BOOKINGS
INSERT INTO HOTEL_BOOKINGS (booking_id, hotel_id, check_in, check_out, rooms, total_cost) VALUES
(1, 1, '2025-07-10', '2025-07-17', 2, 1750.00),
(4, 4, '2025-07-20', '2025-07-30', 3, 3000.00), 
(2, 2, '2025-08-01', '2025-08-10', 1, 1080.00),
(5, 5, '2025-06-15', '2025-06-20', 1, 750.00),
(6, 1, '2025-04-01', '2025-04-07', 1, 800.00), 
(7, 6, '2025-07-05', '2025-07-12', 1, 700.00); 

-- Display tables 
mysql> SELECT * FROM bookings;
+------------+-------------+---------+--------------+-------------+-------------+-----------+--------------+
| booking_id | customer_id | dest_id | booking_date | travel_date | return_date | status    | total_amount |
+------------+-------------+---------+--------------+-------------+-------------+-----------+--------------+
|          1 |           1 |       1 | 2025-06-20   | 2025-07-10  | 2025-07-17  | Confirmed |      1500.00 |
|          2 |           2 |       2 | 2025-06-05   | 2025-08-01  | 2025-08-10  | Confirmed |      2200.00 |
|          3 |           3 |       3 | 2025-05-15   | 2025-09-01  | 2025-09-07  | Pending   |       900.00 |
|          4 |           1 |       4 | 2025-06-25   | 2025-07-20  | 2025-07-30  | Confirmed |      3000.00 |
|          5 |           4 |       5 | 2025-04-01   | 2025-06-15  | 2025-06-20  | Completed |      1800.00 |
|          6 |           1 |       1 | 2025-03-10   | 2025-04-01  | 2025-04-07  | Completed |      1200.00 |
|          7 |           5 |       6 | 2025-06-01   | 2025-07-05  | 2025-07-12  | Confirmed |       850.00 |
|          8 |           6 |       7 | 2025-06-26   | 2025-07-01  | 2025-07-07  | Confirmed |      5000.00 |
|          9 |           7 |       2 | 2024-12-01   | 2025-01-10  | 2025-01-15  | Completed |      1900.00 |
+------------+-------------+---------+--------------+-------------+-------------+-----------+--------------+
9 rows in set (0.00 sec)

mysql> SELECT * FROM customers;
+-------------+---------------+-----------------------+--------------+-------------+-------------------+
| customer_id | name          | email                 | phone        | country     | registration_date |
+-------------+---------------+-----------------------+--------------+-------------+-------------------+
|           1 | Alice Smith   | alice.s@example.com   | 111-222-3333 | USA         | 2024-01-15        |
|           2 | Bob Johnson   | bob.j@example.com     | 444-555-6666 | Canada      | 2024-02-20        |
|           3 | Charlie Brown | charlie.b@example.com | 777-888-9999 | UK          | 2024-03-01        |
|           4 | Diana Prince  | diana.p@example.com   | 123-456-7890 | USA         | 2024-04-10        |
|           5 | Eve Adams     | eve.a@example.com     | 987-654-3210 | Australia   | 2024-05-05        |
|           6 | Frank White   | frank.w@example.com   | 555-111-2222 | USA         | 2024-06-20        |
|           7 | Grace Lee     | grace.l@example.com   | 222-333-4444 | South Korea | 2023-11-01        |
|           8 | Yuuki kaoru   | yuuki.s@example.com   | 111-255-3333 | USA         | 2024-02-15        |
+-------------+---------------+-----------------------+--------------+-------------+-------------------+
8 rows in set (0.00 sec)

mysql> SELECT * FROM destinations;
+---------+----------+-----------+------------+-----------------+-------------+
| dest_id | city     | country   | category   | avg_temperature | best_season |
+---------+----------+-----------+------------+-----------------+-------------+
|       1 | Paris    | France    | Romantic   |           15.50 | Spring      |
|       2 | Tokyo    | Japan     | Cultural   |           20.00 | Autumn      |
|       3 | New York | USA       | City Break |           18.20 | Autumn      |
|       4 | Sydney   | Australia | Beach      |           25.00 | Summer      |
|       5 | Rome     | Italy     | Historic   |           22.00 | Spring      |
|       6 | London   | UK        | City Break |           12.00 | Summer      |
|       7 | Dubai    | UAE       | Luxury     |           30.00 | Winter      |
+---------+----------+-----------+------------+-----------------+-------------+
7 rows in set (0.00 sec)

mysql> SELECT * FROM hotel_bookings;
+-------+------------+----------+------------+------------+-------+------------+
| hb_id | booking_id | hotel_id | check_in   | check_out  | rooms | total_cost |
+-------+------------+----------+------------+------------+-------+------------+
|     1 |          1 |        1 | 2025-07-10 | 2025-07-17 |     2 |    1750.00 |
|     2 |          4 |        4 | 2025-07-20 | 2025-07-30 |     3 |    3000.00 |
|     3 |          2 |        2 | 2025-08-01 | 2025-08-10 |     1 |    1080.00 |
|     4 |          5 |        5 | 2025-06-15 | 2025-06-20 |     1 |     750.00 |
|     5 |          6 |        1 | 2025-04-01 | 2025-04-07 |     1 |     800.00 |
|     6 |          7 |        6 | 2025-07-05 | 2025-07-12 |     1 |     700.00 |
+-------+------------+----------+------------+------------+-------+------------+
6 rows in set (0.00 sec)

mysql> SELECT * FROM hotels;
+----------+---------+---------------------+--------+-----------------+--------------------+
| hotel_id | dest_id | hotel_name          | rating | price_per_night | amenities          |
+----------+---------+---------------------+--------+-----------------+--------------------+
|        1 |       1 | Hotel Grand Paris   |    4.8 |          250.00 | Pool, Spa, Wifi    |
|        2 |       2 | Tokyo Inn           |    4.2 |          120.00 | Wifi, Breakfast    |
|        3 |       3 | NYC Central Hotel   |    3.9 |          180.00 | Gym, Wifi          |
|        4 |       4 | Sydney Beach Resort |    4.6 |          300.00 | Beach Access, Pool |
|        5 |       5 | Roman Holiday Inn   |    4.0 |          150.00 | Restaurant         |
|        6 |       1 | Eiffel Tower View   |    4.9 |          350.00 | Balcony, City View |
|        7 |       6 | London Blooms Hotel |    4.1 |          100.00 | Tea, Wifi          |
+----------+---------+---------------------+--------+-----------------+--------------------+
7 rows in set (0.00 sec)

mysql> SELECT * FROM payments;
+------------+------------+--------------+---------+----------------+-----------+
| payment_id | booking_id | payment_date | amount  | payment_method | status    |
+------------+------------+--------------+---------+----------------+-----------+
|          1 |          1 | 2025-06-20   | 1500.00 | Credit Card    | Completed |
|          2 |          2 | 2025-06-05   | 2200.00 | PayPal         | Completed |
|          3 |          3 | 2025-05-16   |  900.00 | Bank Transfer  | Pending   |
|          4 |          4 | 2025-06-25   | 3000.00 | Credit Card    | Completed |
|          5 |          5 | 2025-04-02   | 1800.00 | Credit Card    | Completed |
|          6 |          6 | 2025-03-10   | 1200.00 | Debit Card     | Completed |
|          7 |          7 | 2025-06-01   |  850.00 | Credit Card    | Completed |
+------------+------------+--------------+---------+----------------+-----------+
7 rows in set (0.00 sec)

-- b) Basic Queries

-- 1. List all customers who have made bookings in the last 30 days

mysql> SELECT
    ->     C.customer_id,
    ->     C.name,
    ->     C.email,
    ->     MAX(B.booking_date) AS latest_booking_date
    -> FROM
    ->     CUSTOMERS C
    -> JOIN
    ->     BOOKINGS B ON C.customer_id = B.customer_id
    -> WHERE
    ->     B.booking_date >= CURDATE() - INTERVAL 30 DAY
    -> GROUP BY
    ->     C.customer_id, C.name, C.email;
+-------------+-------------+---------------------+---------------------+
| customer_id | name        | email               | latest_booking_date |
+-------------+-------------+---------------------+---------------------+
|           1 | Alice Smith | alice.s@example.com | 2025-06-25          |
|           2 | Bob Johnson | bob.j@example.com   | 2025-06-05          |
|           5 | Eve Adams   | eve.a@example.com   | 2025-06-01          |
|           6 | Frank White | frank.w@example.com | 2025-06-26          |
+-------------+-------------+---------------------+---------------------+
4 rows in set (0.01 sec)




-- 2. Find the top 3 most popular destinations based on booking count

mysql> SELECT
    ->     D.city,
    ->     D.country,
    ->     COUNT(B.booking_id) AS booking_count
    -> FROM
    ->     DESTINATIONS D
    -> JOIN
    ->     BOOKINGS B ON D.dest_id = B.dest_id
    -> GROUP BY
    ->     D.city, D.country
    -> ORDER BY
    ->     booking_count DESC
    -> LIMIT 3;
+----------+---------+---------------+
| city     | country | booking_count |
+----------+---------+---------------+
| Paris    | France  |             2 |
| Tokyo    | Japan   |             2 |
| New York | USA     |             1 |
+----------+---------+---------------+
3 rows in set (0.00 sec)

-- 3. Calculate the total revenue generated from each destination

mysql> SELECT
    ->     D.city,
    ->     D.country,
    ->     SUM(B.total_amount) AS total_revenue
    -> FROM
    ->     DESTINATIONS D
    -> JOIN
    ->     BOOKINGS B ON D.dest_id = B.dest_id
    -> WHERE
    ->     B.status = 'Completed' -- Only count completed bookings for revenue
    -> GROUP BY
    ->     D.city, D.country
    -> ORDER BY
    ->     total_revenue DESC;
+-------+---------+---------------+
| city  | country | total_revenue |
+-------+---------+---------------+
| Tokyo | Japan   |       1900.00 |
| Rome  | Italy   |       1800.00 |
| Paris | France  |       1200.00 |
+-------+---------+---------------+
3 rows in set (0.00 sec)

-- Other one where we consider both completed and confirmed status ones

mysql> SELECT
    ->     D.city,
    ->     D.country,
    ->     SUM(B.total_amount) AS total_revenue
    -> FROM
    ->     DESTINATIONS D
    -> JOIN
    ->     BOOKINGS B ON D.dest_id = B.dest_id
    -> WHERE
    ->     B.status IN ('Completed', 'Confirmed') -- Only count completed and confirmed bookings for revenue
    -> GROUP BY
    ->     D.city, D.country
    -> ORDER BY
    ->     total_revenue DESC;
+--------+-----------+---------------+
| city   | country   | total_revenue |
+--------+-----------+---------------+
| Dubai  | UAE       |       5000.00 |
| Tokyo  | Japan     |       4100.00 |
| Sydney | Australia |       3000.00 |
| Paris  | France    |       2700.00 |
| Rome   | Italy     |       1800.00 |
| London | UK        |        850.00 |
+--------+-----------+---------------+
6 rows in set (0.00 sec)

-- 4. Display customers who have never made any booking

mysql> SELECT
    ->     C.customer_id,
    ->     C.name,
    ->     C.email
    -> FROM
    ->     CUSTOMERS C
    -> LEFT JOIN
    ->     BOOKINGS B ON C.customer_id = B.customer_id
    -> WHERE
    ->     B.booking_id IS NULL;
+-------------+-------------+---------------------+
| customer_id | name        | email               |
+-------------+-------------+---------------------+
|           8 | Yuuki kaoru | yuuki.s@example.com |
+-------------+-------------+---------------------+
1 row in set (0.00 sec)


-- c) Intermediate Queries

-- 1. Find customers who have booked hotels with rating above 4.5 and spent more than $2000

mysql> SELECT DISTINCT
    ->     C.customer_id,
    ->     C.name,
    ->     C.email
    -> FROM
    ->     CUSTOMERS C
    -> JOIN
    ->     BOOKINGS B ON C.customer_id = B.customer_id
    -> JOIN
    ->     HOTEL_BOOKINGS HB ON B.booking_id = HB.booking_id
    -> JOIN
    ->     HOTELS H ON HB.hotel_id = H.hotel_id
    -> WHERE
    ->     H.rating > 4.5
    ->     AND HB.total_cost > 2000.00;
+-------------+-------------+---------------------+
| customer_id | name        | email               |
+-------------+-------------+---------------------+
|           1 | Alice Smith | alice.s@example.com |
+-------------+-------------+---------------------+
1 row in set (0.00 sec)

-- 2. Create a query to show monthly booking trends for the current year

mysql> SELECT
    ->     DATE_FORMAT(booking_date, '%Y-%m') AS booking_month,
    ->     COUNT(booking_id) AS total_bookings,
    ->     SUM(total_amount) AS total_amount_booked
    -> FROM
    ->     BOOKINGS
    -> WHERE
    ->     YEAR(booking_date) = YEAR(CURDATE()) -- Current year
    -> GROUP BY
    ->     booking_month
    -> ORDER BY
    ->     booking_month;
+---------------+----------------+---------------------+
| booking_month | total_bookings | total_amount_booked |
+---------------+----------------+---------------------+
| 2025-03       |              1 |             1200.00 |
| 2025-04       |              1 |             1800.00 |
| 2025-05       |              1 |              900.00 |
| 2025-06       |              5 |            12550.00 |
+---------------+----------------+---------------------+
4 rows in set (0.00 sec)

-- 3. List destinations where the average booking amount is above the overall average

mysql> SELECT
    ->     D.city,
    ->     D.country,
    ->     AVG(B.total_amount) AS average_booking_amount
    -> FROM
    ->     DESTINATIONS D
    -> JOIN
    ->     BOOKINGS B ON D.dest_id = B.dest_id
    -> GROUP BY
    ->     D.city, D.country
    -> HAVING
    ->     AVG(B.total_amount) > (SELECT AVG(total_amount) FROM BOOKINGS);
+--------+-----------+------------------------+
| city   | country   | average_booking_amount |
+--------+-----------+------------------------+
| Tokyo  | Japan     |            2050.000000 |
| Sydney | Australia |            3000.000000 |
| Dubai  | UAE       |            5000.000000 |
+--------+-----------+------------------------+
3 rows in set (0.00 sec)

-- Other where we display the over_all_average amount

mysql> WITH OverallAverage AS (
    ->     SELECT AVG(total_amount) AS overall_avg_amount
    ->     FROM BOOKINGS
    -> )
    -> SELECT
    ->     D.city,
    ->     D.country,
    ->     AVG(B.total_amount) AS average_booking_amount,
    ->     OA.overall_avg_amount
    -> FROM
    ->     DESTINATIONS D
    -> JOIN
    ->     BOOKINGS B ON D.dest_id = B.dest_id
    -> CROSS JOIN
    ->     OverallAverage OA
    -> GROUP BY
    ->     D.city, D.country, OA.overall_avg_amount
    -> HAVING
    ->     AVG(B.total_amount) > OA.overall_avg_amount
    -> ORDER BY
    ->     average_booking_amount DESC;
+--------+-----------+------------------------+--------------------+
| city   | country   | average_booking_amount | overall_avg_amount |
+--------+-----------+------------------------+--------------------+
| Dubai  | UAE       |            5000.000000 |        2038.888889 |
| Sydney | Australia |            3000.000000 |        2038.888889 |
| Tokyo  | Japan     |            2050.000000 |        2038.888889 |
+--------+-----------+------------------------+--------------------+
3 rows in set (0.00 sec)

-- 4. Find customers who have visited the same destination more than once

mysql> SELECT
    ->     C.customer_id,
    ->     C.name,
    ->     C.email,
    ->     D.city,
    ->     D.country,
    ->     COUNT(B.booking_id) AS visit_count
    -> FROM
    ->     CUSTOMERS C
    -> JOIN
    ->     BOOKINGS B ON C.customer_id = B.customer_id
    -> JOIN
    ->     DESTINATIONS D ON B.dest_id = D.dest_id
    -> GROUP BY
    ->     C.customer_id, C.name, C.email, D.city, D.country
    -> HAVING
    ->     COUNT(B.booking_id) > 1
    -> ORDER BY
    ->     C.name, visit_count DESC;
+-------------+-------------+---------------------+-------+---------+-------------+
| customer_id | name        | email               | city  | country | visit_count |
+-------------+-------------+---------------------+-------+---------+-------------+
|           1 | Alice Smith | alice.s@example.com | Paris | France  |           2 |
+-------------+-------------+---------------------+-------+---------+-------------+
1 row in set (0.00 sec)


-- d) Advanced Operations

-- 1. Create a stored procedure to calculate customer loyalty points based on total spending
-- Loyalty points logic: 1 point for every $10 spent on 'Completed' bookings
-- using mysql workbench write the script

DELIMITER //

CREATE PROCEDURE CalculateLoyaltyPoints(
    IN customerId INT,
    OUT loyaltyPoints INT
)
BEGIN
    SELECT
        FLOOR(SUM(B.total_amount) / 10)
    INTO
        loyaltyPoints
    FROM
        BOOKINGS B
    WHERE
        B.customer_id = customerId AND B.status = 'Completed';

    -- If no completed bookings, points are 0
    IF loyaltyPoints IS NULL THEN
        SET loyaltyPoints = 0;
    END IF;
END //

DELIMITER ;

-- Example of how to call the stored procedure:
-- Note that loyality points are awarded to those who have completed the trip.
-- CALL CalculateLoyaltyPoints(1, @points);
-- SELECT @points AS Alice_Loyalty_Points;

mysql> CALL CalculateLoyaltyPoints(1, @points);
Query OK, 1 row affected (0.01 sec)

mysql> SELECT @points AS Alice_Loyalty_Points;
+----------------------+
| Alice_Loyalty_Points |
+----------------------+
|                  570 |
+----------------------+
1 row in set (0.00 sec)

mysql> CALL CalculateLoyaltyPoints(4, @points);
Query OK, 1 row affected (0.00 sec)

mysql> SELECT @points AS Diana_Loyalty_Points;
+----------------------+
| Diana_Loyalty_Points |
+----------------------+
|                  180 |
+----------------------+
1 row in set (0.00 sec)

-- 2. Write a trigger to automatically update the booking status when payment is completed
DELIMITER //

CREATE TRIGGER AfterPaymentUpdateBookingStatus
AFTER UPDATE ON PAYMENTS
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        UPDATE BOOKINGS
        SET status = 'Confirmed'
        WHERE booking_id = NEW.booking_id AND status != 'Confirmed';
    END IF;
END //

DELIMITER ;

-- Example of how to test the trigger:
-- SELECT booking_id, status FROM BOOKINGS WHERE booking_id = 3; -- Status should be 'Pending'
-- UPDATE PAYMENTS SET status = 'Completed' WHERE payment_id = 3; -- This should change Booking 3 status
-- SELECT booking_id, status FROM BOOKINGS WHERE booking_id = 3; -- Status should now be 'Confirmed'

mysql> SELECT booking_id, status FROM BOOKINGS WHERE booking_id = 3;
+------------+-----------+
| booking_id | status    |
+------------+-----------+
|          3 | Pending   |
+------------+-----------+
1 row in set (0.00 sec)

mysql> UPDATE PAYMENTS SET status = 'Completed' WHERE payment_id = 3;
Query OK, 1 rows affected (0.00 sec)


mysql> SELECT booking_id, status FROM BOOKINGS WHERE booking_id = 3;
+------------+-----------+
| booking_id | status    |
+------------+-----------+
|          3 | Confirmed |
+------------+-----------+
1 row in set (0.00 sec)

