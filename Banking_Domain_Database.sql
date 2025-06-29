-- First

CREATE DATABASE banking_db;

USE banking_db;



-- a) Database Setup and Sample Data

-- Drop tables if they exist to ensure a clean slate
DROP TABLE IF EXISTS ATM_TRANSACTIONS;
DROP TABLE IF EXISTS CREDIT_CARDS;
DROP TABLE IF EXISTS LOAN_PAYMENTS;
DROP TABLE IF EXISTS LOANS;
DROP TABLE IF EXISTS TRANSACTIONS;
DROP TABLE IF EXISTS ACCOUNTS;
DROP TABLE IF EXISTS CUSTOMERS;

-- 1. CUSTOMERS Table
CREATE TABLE CUSTOMERS (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    date_of_birth DATE NOT NULL,
    account_opening_date DATE NOT NULL
);

-- 2. ACCOUNTS Table
CREATE TABLE ACCOUNTS (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    account_type VARCHAR(50) NOT NULL, -- e.g., 'Savings', 'Checking', 'Current'
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(50) NOT NULL, -- e.g., 'Active', 'Inactive', 'Closed'
    created_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- 3. TRANSACTIONS Table
CREATE TABLE TRANSACTIONS (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- e.g., 'Deposit', 'Withdrawal', 'Transfer'
    amount DECIMAL(15, 2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    description VARCHAR(255),
    reference_account_id INT, -- Nullable FK for transfers
    FOREIGN KEY (account_id) REFERENCES ACCOUNTS(account_id)
);

-- 4. LOANS Table
CREATE TABLE LOANS (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    loan_type VARCHAR(50) NOT NULL, -- e.g., 'Personal', 'Home', 'Car'
    loan_amount DECIMAL(15, 2) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL, -- e.g., 5.50 for 5.50%
    tenure_months INT NOT NULL,
    status VARCHAR(50) NOT NULL, -- e.g., 'Approved', 'Disbursed', 'Repaid', 'Overdue'
    approval_date DATE NOT NULL,
    next_payment_due_date DATE, -- Added for overdue loan queries
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- 5. LOAN_PAYMENTS Table
CREATE TABLE LOAN_PAYMENTS (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(15, 2) NOT NULL,
    principal_amount DECIMAL(15, 2) NOT NULL,
    interest_amount DECIMAL(15, 2) NOT NULL,
    balance_remaining DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (loan_id) REFERENCES LOANS(loan_id)
);

-- 6. CREDIT_CARDS Table
CREATE TABLE CREDIT_CARDS (
    card_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    card_number VARCHAR(16) UNIQUE NOT NULL,
    card_type VARCHAR(50) NOT NULL, -- e.g., 'Visa', 'Mastercard'
    credit_limit DECIMAL(15, 2) NOT NULL,
    outstanding_balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    issue_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- 7. ATM_TRANSACTIONS Table
CREATE TABLE ATM_TRANSACTIONS (
    atm_txn_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    atm_id VARCHAR(50) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- e.g., 'Withdrawal', 'Deposit', 'Balance Inquiry'
    amount DECIMAL(15, 2), -- Nullable for balance inquiries
    transaction_date DATETIME NOT NULL,
    location VARCHAR(255),
    FOREIGN KEY (account_id) REFERENCES ACCOUNTS(account_id)
);

-- Indexes for performance optimization
CREATE INDEX idx_customers_email ON CUSTOMERS(email);
CREATE INDEX idx_accounts_customer_id ON ACCOUNTS(customer_id);
CREATE INDEX idx_transactions_account_id ON TRANSACTIONS(account_id);
CREATE INDEX idx_transactions_date ON TRANSACTIONS(transaction_date);
CREATE INDEX idx_loans_customer_id ON LOANS(customer_id);
CREATE INDEX idx_loan_payments_loan_id ON LOAN_PAYMENTS(loan_id);
CREATE INDEX idx_credit_cards_customer_id ON CREDIT_CARDS(customer_id);
CREATE INDEX idx_atm_transactions_account_id ON ATM_TRANSACTIONS(account_id);


-- Insert Sample Data (ensuring all queries yield results)

-- CUSTOMERS
INSERT INTO CUSTOMERS (name, email, phone, address, date_of_birth, account_opening_date) VALUES
('John Doe', 'john.doe@example.com', '111-222-3333', '123 Main St, Anytown', '1985-05-10', '2020-01-15'),
('Jane Smith', 'jane.s@example.com', '444-555-6666', '456 Oak Ave, Otherville', '1990-11-22', '2021-03-20'),
('Alice Brown', 'alice.b@example.com', '777-888-9999', '789 Pine Rd, Smalltown', '1978-01-01', '2022-07-01'),
('Bob White', 'bob.w@example.com', '123-456-7890', '101 Elm St, Bigcity', '1992-08-15', '2023-02-10'),
('Charlie Green', 'charlie.g@example.com', '987-654-3210', '202 Birch Ln, Midtown', '1980-03-30', '2024-06-01'),
('Diana Red', 'diana.r@example.com', '333-222-1111', '303 Cedar Dr, West End', '1995-07-07', '2025-01-01'),
('Eve Blue', 'eve.b@example.com', '666-777-8888', '404 Spruce Ct, East End', '1982-04-04', '2023-10-25');

-- ACCOUNTS
INSERT INTO ACCOUNTS (customer_id, account_type, balance, status, created_date) VALUES
(1, 'Savings', 5000.00, 'Active', '2020-01-15'),
(1, 'Checking', 2500.00, 'Active', '2020-01-15'), -- John Doe has multiple account types
(2, 'Savings', 12000.00, 'Active', '2021-03-20'),
(3, 'Checking', 1500.00, 'Active', '2022-07-01'),
(3, 'Savings', 3000.00, 'Active', '2022-07-01'), -- Alice Brown has multiple account types
(4, 'Savings', 800.00, 'Active', '2023-02-10'),
(5, 'Checking', 10000.00, 'Active', '2024-06-01'),
(6, 'Savings', 50.00, 'Active', '2025-01-01'); 
-- Add an inactive account for the query
INSERT INTO ACCOUNTS (customer_id, account_type, balance, status, created_date) VALUES
(7, 'Savings', 7500.00, 'Active', '2023-10-25');


-- TRANSACTIONS (Using current date for 'last month' calculations)
-- Current date is June 27, 2025. Last month would be May 27, 2025 to June 27, 2025.
INSERT INTO TRANSACTIONS (account_id, transaction_type, amount, transaction_date, description, reference_account_id) VALUES
(1, 'Deposit', 1000.00, '2025-06-01 10:00:00', 'Salary Deposit', NULL),
(2, 'Withdrawal', 200.00, '2025-06-05 14:30:00', 'ATM Withdrawal', NULL),
(1, 'Transfer', 500.00, '2025-06-10 11:00:00', 'Transfer to Checking', 2),
(2, 'Deposit', 150.00, '2025-05-29 09:00:00', 'Cash Deposit', NULL),
(3, 'Deposit', 2000.00, '2025-06-15 16:00:00', 'Freelance Payment', NULL),
(4, 'Withdrawal', 50.00, '2025-04-20 10:00:00', 'Online Purchase', NULL),
(5, 'Deposit', 500.00, '2025-05-10 12:00:00', 'Gift', NULL),
(6, 'Withdrawal', 100.00, '2025-06-20 09:00:00', 'Grocery', NULL),
(7, 'Deposit', 3000.00, '2025-06-22 13:00:00', 'Bonus', NULL);

-- Fraudulent transactions for account 2 (John's Checking) - multiple high-value in short time
INSERT INTO TRANSACTIONS (account_id, transaction_type, amount, transaction_date, description, reference_account_id) VALUES
(2, 'Withdrawal', 1500.00, '2025-06-26 10:05:00', 'Large Purchase', NULL),
(2, 'Withdrawal', 1200.00, '2025-06-26 10:10:00', 'Online Payment', NULL),
(2, 'Withdrawal', 1300.00, '2025-06-26 10:15:00', 'Bill Payment', NULL);
-- Inactive account transactions (Diana Red, account_id 8 - no transactions since created_date 2025-01-01)
-- Eve Blue, account_id 9 (Last transaction will be more than 90 days ago)
INSERT INTO TRANSACTIONS (account_id, transaction_type, amount, transaction_date, description, reference_account_id) VALUES
(9, 'Deposit', 200.00, '2025-03-01 10:00:00', 'Old deposit', NULL); -- This is >90 days from June 27, 2025 (e.g. 118 days)

-- LOANS
INSERT INTO LOANS (customer_id, loan_type, loan_amount, interest_rate, tenure_months, status, approval_date, next_payment_due_date) VALUES
(1, 'Home', 250000.00, 4.50, 360, 'Approved', '2020-02-01', '2025-07-01'),
(2, 'Personal', 10000.00, 8.00, 60, 'Disbursed', '2021-04-01', '2025-07-01'),
(3, 'Car', 30000.00, 6.25, 84, 'Disbursed', '2022-08-01', '2025-05-20'),
(4, 'Personal', 5000.00, 7.50, 36, 'Approved', '2023-03-01', '2025-07-01');

-- LOAN_PAYMENTS
INSERT INTO LOAN_PAYMENTS (loan_id, payment_date, amount_paid, principal_amount, interest_amount, balance_remaining) VALUES
(1, '2025-06-01', 1500.00, 1000.00, 500.00, 248000.00),
(2, '2025-06-10', 250.00, 200.00, 50.00, 9500.00),
(3, '2025-04-15', 500.00, 400.00, 100.00, 29000.00);

-- CREDIT_CARDS
INSERT INTO CREDIT_CARDS (customer_id, card_number, card_type, credit_limit, outstanding_balance, issue_date, expiry_date) VALUES
(1, '1111222233334444', 'Visa', 10000.00, 1500.00, '2020-06-01', '2026-06-01'),
(2, '5555666677778888', 'Mastercard', 5000.00, 800.00, '2021-09-01', '2027-09-01'),
(3, '9999000011112222', 'Visa', 7500.00, 0.00, '2022-12-01', '2028-12-01');

-- ATM_TRANSACTIONS
INSERT INTO ATM_TRANSACTIONS (account_id, atm_id, transaction_type, amount, transaction_date, location) VALUES
(1, 'ATM001', 'Withdrawal', 100.00, '2025-06-18 10:00:00', 'City Center'),
(3, 'ATM002', 'Deposit', 500.00, '2025-06-20 11:00:00', 'Mall Area'),
(2, 'ATM001', 'Balance Inquiry', NULL, '2025-06-25 15:00:00', 'City Center');

-- Display Tables after inserting data

mysql> SHOW TABLES
    -> ;
+----------------------+
| Tables_in_banking_db |
+----------------------+
| accounts             |
| atm_transactions     |
| credit_cards         |
| customers            |
| loan_payments        |
| loans                |
| transactions         |
+----------------------+
7 rows in set (0.00 sec)

mysql> SELECT * FROM accounts;
+------------+-------------+--------------+----------+--------+--------------+
| account_id | customer_id | account_type | balance  | status | created_date |
+------------+-------------+--------------+----------+--------+--------------+
|          1 |           1 | Savings      |  5000.00 | Active | 2020-01-15   |
|          2 |           1 | Checking     |  2500.00 | Active | 2020-01-15   |
|          3 |           2 | Savings      | 12000.00 | Active | 2021-03-20   |
|          4 |           3 | Checking     |  1500.00 | Active | 2022-07-01   |
|          5 |           3 | Savings      |  3000.00 | Active | 2022-07-01   |
|          6 |           4 | Savings      |   800.00 | Active | 2023-02-10   |
|          7 |           5 | Checking     | 10000.00 | Active | 2024-06-01   |
|          8 |           6 | Savings      |    50.00 | Active | 2025-01-01   |
|          9 |           7 | Savings      |  7500.00 | Active | 2023-10-25   |
+------------+-------------+--------------+----------+--------+--------------+
9 rows in set (0.00 sec)

mysql> SELECT * FROM customers;
+-------------+---------------+-----------------------+--------------+-------------------------+---------------+----------------------+
| customer_id | name          | email                 | phone        | address                 | date_of_birth | account_opening_date |
+-------------+---------------+-----------------------+--------------+-------------------------+---------------+----------------------+
|           1 | John Doe      | john.doe@example.com  | 111-222-3333 | 123 Main St, Anytown    | 1985-05-10    | 2020-01-15           |
|           2 | Jane Smith    | jane.s@example.com    | 444-555-6666 | 456 Oak Ave, Otherville | 1990-11-22    | 2021-03-20           |
|           3 | Alice Brown   | alice.b@example.com   | 777-888-9999 | 789 Pine Rd, Smalltown  | 1978-01-01    | 2022-07-01           |
|           4 | Bob White     | bob.w@example.com     | 123-456-7890 | 101 Elm St, Bigcity     | 1992-08-15    | 2023-02-10           |
|           5 | Charlie Green | charlie.g@example.com | 987-654-3210 | 202 Birch Ln, Midtown   | 1980-03-30    | 2024-06-01           |
|           6 | Diana Red     | diana.r@example.com   | 333-222-1111 | 303 Cedar Dr, West End  | 1995-07-07    | 2025-01-01           |
|           7 | Eve Blue      | eve.b@example.com     | 666-777-8888 | 404 Spruce Ct, East End | 1982-04-04    | 2023-10-25           |
+-------------+---------------+-----------------------+--------------+-------------------------+---------------+----------------------+
7 rows in set (0.00 sec)

mysql> SELECT * FROM transactions;
+----------------+------------+------------------+---------+---------------------+----------------------+----------------------+
| transaction_id | account_id | transaction_type | amount  | transaction_date    | description          | reference_account_id |
+----------------+------------+------------------+---------+---------------------+----------------------+----------------------+
|              1 |          1 | Deposit          | 1000.00 | 2025-06-01 10:00:00 | Salary Deposit       |                 NULL |
|              2 |          2 | Withdrawal       |  200.00 | 2025-06-05 14:30:00 | ATM Withdrawal       |                 NULL |
|              3 |          1 | Transfer         |  500.00 | 2025-06-10 11:00:00 | Transfer to Checking |                    2 |
|              4 |          2 | Deposit          |  150.00 | 2025-05-29 09:00:00 | Cash Deposit         |                 NULL |
|              5 |          3 | Deposit          | 2000.00 | 2025-06-15 16:00:00 | Freelance Payment    |                 NULL |
|              6 |          4 | Withdrawal       |   50.00 | 2025-04-20 10:00:00 | Online Purchase      |                 NULL |
|              7 |          5 | Deposit          |  500.00 | 2025-05-10 12:00:00 | Gift                 |                 NULL |
|              8 |          6 | Withdrawal       |  100.00 | 2025-06-20 09:00:00 | Grocery              |                 NULL |
|              9 |          7 | Deposit          | 3000.00 | 2025-06-22 13:00:00 | Bonus                |                 NULL |
|             10 |          2 | Withdrawal       | 1500.00 | 2025-06-26 10:05:00 | Large Purchase       |                 NULL |
|             11 |          2 | Withdrawal       | 1200.00 | 2025-06-26 10:10:00 | Online Payment       |                 NULL |
|             12 |          2 | Withdrawal       | 1300.00 | 2025-06-26 10:15:00 | Bill Payment         |                 NULL |
|             13 |          9 | Deposit          |  200.00 | 2025-03-01 10:00:00 | Old deposit          |                 NULL |
+----------------+------------+------------------+---------+---------------------+----------------------+----------------------+
13 rows in set (0.00 sec)

mysql> SELECT * FROM loans;
+---------+-------------+-----------+-------------+---------------+---------------+-----------+---------------+-----------------------+
| loan_id | customer_id | loan_type | loan_amount | interest_rate | tenure_months | status    | approval_date | next_payment_due_date |
+---------+-------------+-----------+-------------+---------------+---------------+-----------+---------------+-----------------------+
|       1 |           1 | Home      |   250000.00 |          4.50 |           360 | Approved  | 2020-02-01    | 2025-07-01            |
|       2 |           2 | Personal  |    10000.00 |          8.00 |            60 | Disbursed | 2021-04-01    | 2025-07-01            |
|       3 |           3 | Car       |    30000.00 |          6.25 |            84 | Disbursed | 2022-08-01    | 2025-05-20            |
|       4 |           4 | Personal  |     5000.00 |          7.50 |            36 | Approved  | 2023-03-01    | 2025-07-01            |
+---------+-------------+-----------+-------------+---------------+---------------+-----------+---------------+-----------------------+
4 rows in set (0.00 sec)

mysql> SELECT * FROM loan_payments;
+------------+---------+--------------+-------------+------------------+-----------------+-------------------+
| payment_id | loan_id | payment_date | amount_paid | principal_amount | interest_amount | balance_remaining |
+------------+---------+--------------+-------------+------------------+-----------------+-------------------+
|          1 |       1 | 2025-06-01   |     1500.00 |          1000.00 |          500.00 |         248000.00 |
|          2 |       2 | 2025-06-10   |      250.00 |           200.00 |           50.00 |           9500.00 |
|          3 |       3 | 2025-04-15   |      500.00 |           400.00 |          100.00 |          29000.00 |
+------------+---------+--------------+-------------+------------------+-----------------+-------------------+
3 rows in set (0.00 sec)

mysql> SELECT * FROM credit_cards;
+---------+-------------+------------------+------------+--------------+---------------------+------------+-------------+
| card_id | customer_id | card_number      | card_type  | credit_limit | outstanding_balance | issue_date | expiry_date |
+---------+-------------+------------------+------------+--------------+---------------------+------------+-------------+
|       1 |           1 | 1111222233334444 | Visa       |     10000.00 |             1500.00 | 2020-06-01 | 2026-06-01  |
|       2 |           2 | 5555666677778888 | Mastercard |      5000.00 |              800.00 | 2021-09-01 | 2027-09-01  |
|       3 |           3 | 9999000011112222 | Visa       |      7500.00 |                0.00 | 2022-12-01 | 2028-12-01  |
+---------+-------------+------------------+------------+--------------+---------------------+------------+-------------+
3 rows in set (0.00 sec)

mysql> SELECT * FROM atm_transactions;
+------------+------------+--------+------------------+--------+---------------------+-------------+
| atm_txn_id | account_id | atm_id | transaction_type | amount | transaction_date    | location    |
+------------+------------+--------+------------------+--------+---------------------+-------------+
|          1 |          1 | ATM001 | Withdrawal       | 100.00 | 2025-06-18 10:00:00 | City Center |
|          2 |          3 | ATM002 | Deposit          | 500.00 | 2025-06-20 11:00:00 | Mall Area   |
|          3 |          2 | ATM001 | Balance Inquiry  |   NULL | 2025-06-25 15:00:00 | City Center |
+------------+------------+--------+------------------+--------+---------------------+-------------+
3 rows in set (0.00 sec)


-- b) Basic Banking Operations

-- 1. List all active accounts with their current balances

mysql> SELECT
    ->     A.account_id,
    ->     C.name AS customer_name,
    ->     A.account_type,
    ->     A.balance,
    ->     A.status
    -> FROM
    ->     ACCOUNTS A
    -> JOIN
    ->     CUSTOMERS C ON A.customer_id = C.customer_id
    -> WHERE
    ->     A.status = 'Active';
+------------+---------------+--------------+----------+--------+
| account_id | customer_name | account_type | balance  | status |
+------------+---------------+--------------+----------+--------+
|          1 | John Doe      | Savings      |  5000.00 | Active |
|          2 | John Doe      | Checking     |  2500.00 | Active |
|          3 | Jane Smith    | Savings      | 12000.00 | Active |
|          4 | Alice Brown   | Checking     |  1500.00 | Active |
|          5 | Alice Brown   | Savings      |  3000.00 | Active |
|          6 | Bob White     | Savings      |   800.00 | Active |
|          7 | Charlie Green | Checking     | 10000.00 | Active |
|          8 | Diana Red     | Savings      |    50.00 | Active |
|          9 | Eve Blue      | Savings      |  7500.00 | Active |
+------------+---------------+--------------+----------+--------+
9 rows in set (0.00 sec)

-- 2. Find customers who have multiple account types

mysql> SELECT
    ->     C.customer_id,
    ->     C.name,
    ->     C.email,
    ->     COUNT(DISTINCT A.account_type) AS distinct_account_types
    -> FROM
    ->     CUSTOMERS C
    -> JOIN
    ->     ACCOUNTS A ON C.customer_id = A.customer_id
    -> GROUP BY
    ->     C.customer_id, C.name, C.email
    -> HAVING
    ->     COUNT(DISTINCT A.account_type) > 1;
+-------------+-------------+----------------------+------------------------+
| customer_id | name        | email                | distinct_account_types |
+-------------+-------------+----------------------+------------------------+
|           1 | John Doe    | john.doe@example.com |                      2 |
|           3 | Alice Brown | alice.b@example.com  |                      2 |
+-------------+-------------+----------------------+------------------------+
2 rows in set (0.00 sec)

-- 3. Calculate total deposits and withdrawals for each account in the last month

mysql> SELECT
    ->     A.account_id,
    ->     A.account_type,
    ->     C.name AS customer_name,
    ->     SUM(CASE WHEN T.transaction_type = 'Deposit' THEN T.amount ELSE 0 END) AS total_deposits_last_month,
    ->     SUM(CASE WHEN T.transaction_type = 'Withdrawal' THEN T.amount ELSE 0 END) AS total_withdrawals_last_month
    -> FROM
    ->     ACCOUNTS A
    -> JOIN
    ->     CUSTOMERS C ON A.customer_id = C.customer_id
    -> LEFT JOIN
    ->     TRANSACTIONS T ON A.account_id = T.account_id
    -> WHERE
    ->     T.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    -> GROUP BY
    ->     A.account_id, A.account_type, C.name
    -> ORDER BY
    ->     A.account_id;
+------------+--------------+---------------+---------------------------+------------------------------+
| account_id | account_type | customer_name | total_deposits_last_month | total_withdrawals_last_month |
+------------+--------------+---------------+---------------------------+------------------------------+
|          1 | Savings      | John Doe      |                   1000.00 |                         0.00 |
|          2 | Checking     | John Doe      |                    150.00 |                      4200.00 |
|          3 | Savings      | Jane Smith    |                   2000.00 |                         0.00 |
|          6 | Savings      | Bob White     |                      0.00 |                       100.00 |
|          7 | Checking     | Charlie Green |                   3000.00 |                         0.00 |
+------------+--------------+---------------+---------------------------+------------------------------+
5 rows in set (0.00 sec)

-- 4. Display customers with overdue loan payments

mysql> SELECT
    ->     C.customer_id,
    ->     C.name,
    ->     L.loan_id,
    ->     L.loan_type,
    ->     L.loan_amount,
    ->     L.next_payment_due_date,
    ->     L.status AS loan_status
    -> FROM
    ->     CUSTOMERS C
    -> JOIN
    ->     LOANS L ON C.customer_id = L.customer_id
    -> WHERE
    ->     L.status = 'Disbursed' -- Assuming disbursed loans can be overdue
    ->     AND L.next_payment_due_date IS NOT NULL
    ->     AND L.next_payment_due_date < CURDATE();
+-------------+-------------+---------+-----------+-------------+-----------------------+-------------+
| customer_id | name        | loan_id | loan_type | loan_amount | next_payment_due_date | loan_status |
+-------------+-------------+---------+-----------+-------------+-----------------------+-------------+
|           3 | Alice Brown |       3 | Car       |    30000.00 | 2025-05-20            | Disbursed   |
+-------------+-------------+---------+-----------+-------------+-----------------------+-------------+
1 row in set (0.00 sec)


-- c) Advanced Queries

-- 1. Create a query to identify potentially fraudulent transactions (multiple high-value transactions in short time)
-- Definition: More than 2 transactions with amount > 1000 within 15 minutes for the same account

mysql> SELECT
    ->     T1.account_id,
    ->     A.account_type,
    ->     C.name AS customer_name,
    ->     T1.transaction_date AS transaction_time_1,
    ->     T1.amount AS amount_1,
    ->     T2.transaction_date AS transaction_time_2,
    ->     T2.amount AS amount_2,
    ->     T3.transaction_date AS transaction_time_3,
    ->     T3.amount AS amount_3
    -> FROM
    ->     TRANSACTIONS T1
    -> JOIN
    ->     TRANSACTIONS T2 ON T1.account_id = T2.account_id
    ->     AND T1.transaction_id < T2.transaction_id -- ensure T2 is after T1
    ->     AND TIMESTAMPDIFF(MINUTE, T1.transaction_date, T2.transaction_date) <= 15
    -> JOIN
    ->     TRANSACTIONS T3 ON T2.account_id = T3.account_id
    ->     AND T2.transaction_id < T3.transaction_id -- ensure T3 is after T2
    ->     AND TIMESTAMPDIFF(MINUTE, T2.transaction_date, T3.transaction_date) <= 15
    -> JOIN
    ->     ACCOUNTS A ON T1.account_id = A.account_id
    -> JOIN
    ->     CUSTOMERS C ON A.customer_id = C.customer_id
    -> WHERE
    ->     T1.amount > 1000 AND T2.amount > 1000 AND T3.amount > 1000
    -> ORDER BY
    ->     T1.account_id, T1.transaction_date;
+------------+--------------+---------------+---------------------+----------+---------------------+----------+---------------------+----------+
| account_id | account_type | customer_name | transaction_time_1  | amount_1 | transaction_time_2  | amount_2 | transaction_time_3  | amount_3 |
+------------+--------------+---------------+---------------------+----------+---------------------+----------+---------------------+----------+
|          2 | Checking     | John Doe      | 2025-06-26 10:05:00 |  1500.00 | 2025-06-26 10:10:00 |  1200.00 | 2025-06-26 10:15:00 |  1300.00 |
+------------+--------------+---------------+---------------------+----------+---------------------+----------+---------------------+----------+
1 row in set (0.00 sec)

-- 2. Generate a monthly statement for a specific account showing all transactions
-- Example: For account_id = 1 (John Doe's Savings) for June 2025

mysql> SELECT
    ->     T.transaction_id,
    ->     T.transaction_date,
    ->     T.transaction_type,
    ->     T.amount,
    ->     T.description,
    ->     A.account_id,
    ->     A.account_type,
    ->     C.name AS customer_name
    -> FROM
    ->     TRANSACTIONS T
    -> JOIN
    ->     ACCOUNTS A ON T.account_id = A.account_id
    -> JOIN
    ->     CUSTOMERS C ON A.customer_id = C.customer_id
    -> WHERE
    ->     A.account_id in (1,2) -- Specific account_id
    ->     AND DATE_FORMAT(T.transaction_date, '%Y-%m') = '2025-06' -- Specific month and year
    -> ORDER BY
    ->     T.transaction_date;
+----------------+---------------------+------------------+---------+----------------------+------------+--------------+---------------+
| transaction_id | transaction_date    | transaction_type | amount  | description          | account_id | account_type | customer_name |
+----------------+---------------------+------------------+---------+----------------------+------------+--------------+---------------+
|              1 | 2025-06-01 10:00:00 | Deposit          | 1000.00 | Salary Deposit       |          1 | Savings      | John Doe      |
|              2 | 2025-06-05 14:30:00 | Withdrawal       |  200.00 | ATM Withdrawal       |          2 | Checking     | John Doe      |
|              3 | 2025-06-10 11:00:00 | Transfer         |  500.00 | Transfer to Checking |          1 | Savings      | John Doe      |
|             10 | 2025-06-26 10:05:00 | Withdrawal       | 1500.00 | Large Purchase       |          2 | Checking     | John Doe      |
|             11 | 2025-06-26 10:10:00 | Withdrawal       | 1200.00 | Online Payment       |          2 | Checking     | John Doe      |
|             12 | 2025-06-26 10:15:00 | Withdrawal       | 1300.00 | Bill Payment         |          2 | Checking     | John Doe      |
+----------------+---------------------+------------------+---------+----------------------+------------+--------------+---------------+
6 rows in set (0.00 sec)


-- 3. Find customers eligible for loan pre-approval based on account balance and transaction history
-- Criteria: Savings balance > $4000 AND total deposits in last 6 months > $1500

mysql> SELECT
    ->     C.customer_id,
    ->     C.name,
    ->     C.email,
    ->     SUM(CASE WHEN A.account_type = 'Savings' THEN A.balance ELSE 0 END) AS savings_balance,
    ->     SUM(CASE WHEN T.transaction_type = 'Deposit' THEN T.amount ELSE 0 END) AS total_deposits_last_6_months
    -> FROM
    ->     CUSTOMERS C
    -> JOIN
    ->     ACCOUNTS A ON C.customer_id = A.customer_id
    -> LEFT JOIN
    ->     TRANSACTIONS T ON A.account_id = T.account_id
    ->     AND T.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    -> WHERE
    ->     A.account_type = 'Savings' -- Only consider savings account for balance check
    -> GROUP BY
    ->     C.customer_id, C.name, C.email
    -> HAVING
    ->     SUM(CASE WHEN A.account_type = 'Savings' THEN A.balance ELSE 0 END) > 4000
    ->     AND SUM(CASE WHEN T.transaction_type = 'Deposit' THEN T.amount ELSE 0 END) > 1500;
+-------------+------------+--------------------+-----------------+------------------------------+
| customer_id | name       | email              | savings_balance | total_deposits_last_6_months |
+-------------+------------+--------------------+-----------------+------------------------------+
|           2 | Jane Smith | jane.s@example.com |        12000.00 |                      2000.00 |
+-------------+------------+--------------------+-----------------+------------------------------+
1 row in set (0.00 sec)


-- 4. Calculate the bank's total exposure to each loan type

mysql> SELECT
    ->     loan_type,
    ->     SUM(loan_amount) AS total_exposure
    -> FROM
    ->     LOANS
    -> WHERE
    ->     status IN ('Approved', 'Disbursed') -- Only consider active loans
    -> GROUP BY
    ->     loan_type
    -> ORDER BY
    ->     total_exposure DESC;
+-----------+----------------+
| loan_type | total_exposure |
+-----------+----------------+
| Home      |      250000.00 |
| Car       |       30000.00 |
| Personal  |       15000.00 |
+-----------+----------------+
3 rows in set (0.00 sec)


-- d) Analytical Queries

-- 1. Create a view showing customer profitability (total deposits - total withdrawals + loan interest received)
-- Assuming the bank earns the 'interest_amount' from loan payments.
-- Do this in sqlworkbench

CREATE VIEW Customer_Profitability_V AS
SELECT
    C.customer_id,
    C.name,
    C.email,
    COALESCE(SUM(CASE WHEN T.transaction_type = 'Deposit' THEN T.amount ELSE 0 END), 0) AS total_deposits,
    COALESCE(SUM(CASE WHEN T.transaction_type = 'Withdrawal' THEN T.amount ELSE 0 END), 0) AS total_withdrawals,
    COALESCE(SUM(LP.interest_amount), 0) AS total_loan_interest_paid_by_customer,
    (COALESCE(SUM(CASE WHEN T.transaction_type = 'Deposit' THEN T.amount ELSE 0 END), 0) -
     COALESCE(SUM(CASE WHEN T.transaction_type = 'Withdrawal' THEN T.amount ELSE 0 END), 0) +
     COALESCE(SUM(LP.interest_amount), 0)) AS net_profitability
FROM
    CUSTOMERS C
LEFT JOIN
    ACCOUNTS A ON C.customer_id = A.customer_id
LEFT JOIN
    TRANSACTIONS T ON A.account_id = T.account_id
LEFT JOIN
    LOANS L ON C.customer_id = L.customer_id
LEFT JOIN
    LOAN_PAYMENTS LP ON L.loan_id = LP.loan_id
GROUP BY
    C.customer_id, C.name, C.email
ORDER BY
    net_profitability DESC;

-- To query the view:
-- SELECT * FROM Customer_Profitability_V;

mysql> SELECT * FROM Customer_Profitability_V;
+-------------+---------------+-----------------------+----------------+-------------------+--------------------------------------+-------------------+
| customer_id | name          | email                 | total_deposits | total_withdrawals | total_loan_interest_paid_by_customer | net_profitability |
+-------------+---------------+-----------------------+----------------+-------------------+--------------------------------------+-------------------+
|           5 | Charlie Green | charlie.g@example.com |        3000.00 |              0.00 |                                 0.00 |           3000.00 |
|           2 | Jane Smith    | jane.s@example.com    |        2000.00 |              0.00 |                                50.00 |           2050.00 |
|           3 | Alice Brown   | alice.b@example.com   |         500.00 |             50.00 |                               200.00 |            650.00 |
|           1 | John Doe      | john.doe@example.com  |        1150.00 |           4200.00 |                              3500.00 |            450.00 |
|           7 | Eve Blue      | eve.b@example.com     |         200.00 |              0.00 |                                 0.00 |            200.00 |
|           6 | Diana Red     | diana.r@example.com   |           0.00 |              0.00 |                                 0.00 |              0.00 |
|           4 | Bob White     | bob.w@example.com     |           0.00 |            100.00 |                                 0.00 |           -100.00 |
+-------------+---------------+-----------------------+----------------+-------------------+--------------------------------------+-------------------+
7 rows in set (0.00 sec)




-- 2. Write a query to identify inactive accounts (no transactions in 90 days)

mysql> SELECT
    ->     A.account_id,
    ->     C.name AS customer_name,
    ->     A.account_type,
    ->     A.balance,
    ->     A.status,
    ->     A.created_date AS account_created_date,
    ->     MAX(T.transaction_date) AS last_transaction_date
    -> FROM
    ->     ACCOUNTS A
    -> JOIN
    ->     CUSTOMERS C ON A.customer_id = C.customer_id
    -> LEFT JOIN
    ->     TRANSACTIONS T ON A.account_id = T.account_id
    -> GROUP BY
    ->     A.account_id, C.name, A.account_type, A.balance, A.status, A.created_date
    -> HAVING
    ->     MAX(T.transaction_date) IS NULL -- Accounts with no transactions ever
    ->     OR MAX(T.transaction_date) < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    -> ORDER BY
    ->     A.account_id;
+------------+---------------+--------------+---------+--------+----------------------+-----------------------+
| account_id | customer_name | account_type | balance | status | account_created_date | last_transaction_date |
+------------+---------------+--------------+---------+--------+----------------------+-----------------------+
|          8 | Diana Red     | Savings      |   50.00 | Active | 2025-01-01           | NULL                  |
|          9 | Eve Blue      | Savings      | 7500.00 | Active | 2023-10-25           | 2025-03-01 10:00:00   |
+------------+---------------+--------------+---------+--------+----------------------+-----------------------+
2 rows in set (0.00 sec)
