PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS raw_customers;
DROP TABLE IF EXISTS source_orders;
DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS source_events;
DROP TABLE IF EXISTS target_events;
DROP TABLE IF EXISTS staging_customers;
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS daily_sales;
DROP TABLE IF EXISTS daily_order_counts;
DROP TABLE IF EXISTS web_events;

CREATE TABLE raw_customers (
    source_row_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    email TEXT,
    status TEXT NOT NULL,
    updated_at TEXT,
    ingestion_time TEXT NOT NULL
);

INSERT INTO raw_customers VALUES
(1, 1001, 'alice@example.com', 'active', '2026-07-01 09:00:00', '2026-07-01 09:05:00'),
(2, 1002, 'bob@oldmail.com', 'active', '2026-07-01 10:00:00', '2026-07-01 10:02:00'),
(3, 1003, 'carol@example.com', 'active', '2026-07-02 08:30:00', '2026-07-02 08:31:00'),
(4, 1001, 'alice.new@example.com', 'active', '2026-07-03 12:00:00', '2026-07-03 12:01:00'),
(5, 1004, NULL, 'pending', '2026-07-03 14:00:00', '2026-07-03 14:04:00'),
(6, 1002, 'bob@example.com', 'active', '2026-07-04 07:00:00', '2026-07-04 07:03:00'),
(7, 1005, 'dev@example.com', 'inactive', '2026-07-04 09:00:00', '2026-07-04 09:02:00'),
(8, 1004, 'dina@example.com', 'active', '2026-07-05 11:00:00', '2026-07-05 11:01:00'),
(9, 1006, 'eli@example.com', 'active', '2026-07-05 15:30:00', '2026-07-05 15:31:00'),
(10, 1006, 'eli+new@example.com', 'active', '2026-07-05 15:30:00', '2026-07-05 15:35:00'),
(11, 1007, 'fatima@example.com', 'active', NULL, '2026-07-06 10:00:00'),
(12, 1001, 'alice.new@example.com', 'inactive', '2026-07-07 08:00:00', '2026-07-07 08:01:00'),
(13, 1008, 'gus@example.com', 'active', '2026-07-07 09:00:00', '2026-07-07 09:01:00'),
(14, 1008, 'gus@example.com', 'active', '2026-07-07 09:00:00', '2026-07-07 09:01:00');

CREATE TABLE source_orders (
    tenant_id TEXT NOT NULL,
    order_id TEXT NOT NULL,
    order_date TEXT NOT NULL,
    customer_id INTEGER NOT NULL,
    order_total REAL NOT NULL,
    status TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    PRIMARY KEY (tenant_id, order_id)
);

INSERT INTO source_orders VALUES
('T1', 'O1001', '2026-07-01', 1001, 48.50, 'paid', '2026-07-01 09:15:00'),
('T2', 'O1001', '2026-07-01', 2001, 75.00, 'paid', '2026-07-01 09:20:00'),
('T1', 'O1002', '2026-07-01', 1002, 120.00, 'paid', '2026-07-01 11:00:00'),
('T1', 'O1003', '2026-07-02', 1003, 39.99, 'shipped', '2026-07-02 10:00:00'),
('T1', 'O1004', '2026-07-02', 1004, 210.00, 'paid', '2026-07-02 14:10:00'),
('T1', 'O1005', '2026-07-03', 1005, 18.75, 'paid', '2026-07-03 08:10:00'),
('T1', 'O1006', '2026-07-03', 1001, 64.00, 'cancelled', '2026-07-03 12:30:00'),
('T1', 'O1007', '2026-07-04', 1006, 99.95, 'refunded', '2026-07-05 16:00:00'),
('T1', 'O1008', '2026-07-04', 1002, 27.40, 'paid', '2026-07-04 17:00:00'),
('T2', 'O1009', '2026-07-05', 2002, 340.00, 'shipped', '2026-07-05 13:00:00'),
('T1', 'O1010', '2026-07-05', 1007, 15.00, 'paid', '2026-07-05 18:00:00'),
('T1', 'O1011', '2026-07-06', 1008, 55.50, 'paid', '2026-07-06 09:00:00'),
('T1', 'O1012', '2026-07-06', 1003, 87.25, 'paid', '2026-07-06 09:45:00'),
('T2', 'O1013', '2026-07-06', 2003, 44.00, 'paid', '2026-07-06 15:00:00'),
('T1', 'O1014', '2026-07-07', 1004, 130.00, 'shipped', '2026-07-07 11:00:00'),
('T1', 'O1015', '2026-07-07', 1005, 22.00, 'paid', '2026-07-07 12:00:00');

CREATE TABLE fact_orders (
    tenant_id TEXT NOT NULL,
    order_id TEXT NOT NULL,
    order_date TEXT NOT NULL,
    customer_id INTEGER NOT NULL,
    order_total REAL NOT NULL,
    status TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    PRIMARY KEY (tenant_id, order_id)
);

INSERT INTO fact_orders VALUES
('T1', 'O1001', '2026-07-01', 1001, 48.50, 'paid', '2026-07-01 09:15:00'),
('T2', 'O1001', '2026-07-01', 2001, 75.00, 'paid', '2026-07-01 09:20:00'),
('T1', 'O1002', '2026-07-01', 1002, 120.00, 'paid', '2026-07-01 11:00:00'),
('T1', 'O1003', '2026-07-02', 1003, 39.99, 'shipped', '2026-07-02 10:00:00'),
('T1', 'O1004', '2026-07-02', 1004, 210.00, 'paid', '2026-07-02 14:10:00'),
('T1', 'O1006', '2026-07-03', 1001, 64.00, 'cancelled', '2026-07-03 12:30:00'),
('T1', 'O1007', '2026-07-04', 1006, 89.95, 'refunded', '2026-07-05 16:00:00'),
('T1', 'O1008', '2026-07-04', 1002, 27.40, 'paid', '2026-07-04 17:00:00'),
('T2', 'O1009', '2026-07-05', 2002, 340.00, 'shipped', '2026-07-05 13:00:00'),
('T1', 'O1010', '2026-07-05', 1007, 15.00, 'paid', '2026-07-05 18:00:00'),
('T1', 'O1011', '2026-07-06', 1008, 55.50, 'paid', '2026-07-06 09:00:00'),
('T2', 'O1013', '2026-07-06', 2003, 44.00, 'paid', '2026-07-06 15:00:00'),
('T1', 'O1014', '2026-07-07', 1004, 130.00, 'paid', '2026-07-07 11:00:00'),
('T1', 'O1015', '2026-07-07', 1005, 22.00, 'paid', '2026-07-07 12:00:00'),
('T1', 'O9999', '2026-07-06', 1099, 77.00, 'paid', '2026-07-06 18:00:00');

CREATE TABLE source_events (
    event_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    event_timestamp TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

INSERT INTO source_events VALUES
('E001', 'U01', 'login', '2026-07-07 08:00:00', '2026-07-07 08:00:10'),
('E002', 'U01', 'search', '2026-07-07 08:05:00', '2026-07-07 08:05:05'),
('E003', 'U02', 'login', '2026-07-07 08:15:00', '2026-07-07 08:15:08'),
('E004', 'U01', 'purchase', '2026-07-07 09:00:00', '2026-07-07 09:00:10'),
('E005', 'U03', 'login', '2026-07-07 09:30:00', '2026-07-07 09:30:05'),
('E006', 'U02', 'logout', '2026-07-07 10:00:00', '2026-07-07 10:00:07'),
('E007', 'U04', 'login', '2026-07-07 10:00:00', '2026-07-07 10:12:00'),
('E008', 'U04', 'search', '2026-07-07 10:25:00', '2026-07-07 10:25:02'),
('E009', 'U05', 'login', '2026-07-07 10:40:00', '2026-07-07 10:40:02'),
('E010', 'U01', 'logout', '2026-07-07 11:00:00', '2026-07-07 11:00:02'),
('E011', 'U03', 'purchase', '2026-07-07 11:15:00', '2026-07-07 11:15:04'),
('E012', 'U06', 'login', '2026-07-07 12:00:00', '2026-07-07 12:00:05'),
('E013', 'U02', 'purchase', '2026-07-07 12:30:00', '2026-07-07 12:30:03'),
('E014', 'U07', 'login', '2026-07-07 09:59:30', '2026-07-07 12:45:00'),
('E015', 'U08', 'login', '2026-07-07 13:00:00', '2026-07-07 13:00:02');

CREATE TABLE target_events AS SELECT * FROM source_events WHERE 0;
CREATE UNIQUE INDEX target_events_event_id_idx ON target_events(event_id);

INSERT INTO target_events VALUES
('E001', 'U01', 'login', '2026-07-07 08:00:00', '2026-07-07 08:00:10'),
('E002', 'U01', 'search', '2026-07-07 08:05:00', '2026-07-07 08:05:05'),
('E003', 'U02', 'login', '2026-07-07 08:15:00', '2026-07-07 08:15:08'),
('E004', 'U01', 'checkout', '2026-07-07 09:00:00', '2026-07-07 09:00:01'),
('E005', 'U03', 'login', '2026-07-07 09:30:00', '2026-07-07 09:30:05'),
('E006', 'U02', 'logout', '2026-07-07 10:00:00', '2026-07-07 10:00:07');

CREATE TABLE staging_customers (
    customer_id INTEGER PRIMARY KEY,
    email TEXT,
    status TEXT NOT NULL,
    city TEXT,
    updated_at TEXT NOT NULL
);

INSERT INTO staging_customers VALUES
(1001, 'alice.new@example.com', 'inactive', 'London', '2026-07-07 08:00:00'),
(1002, 'bob@example.com', 'active', 'Leeds', '2026-07-04 07:00:00'),
(1003, NULL, 'active', 'Bristol', '2026-07-07 09:00:00'),
(1004, 'dina@example.com', 'active', 'Manchester', '2026-07-05 11:00:00'),
(1005, 'DEV@EXAMPLE.COM', 'inactive', 'Glasgow', '2026-07-07 10:00:00'),
(1006, ' eli+new@example.com ', 'active', 'Cardiff', '2026-07-07 10:30:00'),
(1008, 'gus@example.com', 'active', NULL, '2026-07-07 09:00:00'),
(1009, 'hana@example.com', 'active', 'York', '2026-07-07 11:00:00');

CREATE TABLE dim_customers (
    customer_id INTEGER PRIMARY KEY,
    email TEXT,
    status TEXT NOT NULL,
    city TEXT,
    updated_at TEXT NOT NULL
);

INSERT INTO dim_customers VALUES
(1001, 'alice.new@example.com', 'active', 'London', '2026-07-03 12:00:00'),
(1002, 'bob@example.com', 'active', 'Leeds', '2026-07-04 07:00:00'),
(1003, 'carol@example.com', 'active', 'Bristol', '2026-07-02 08:30:00'),
(1004, 'dina@example.com', 'active', 'Manchester', '2026-07-05 11:00:00'),
(1005, 'dev@example.com', 'inactive', 'Glasgow', '2026-07-04 09:00:00'),
(1006, 'eli+new@example.com', 'active', 'Cardiff', '2026-07-05 15:30:00'),
(1007, 'fatima@example.com', 'active', 'Oxford', '2026-07-06 10:00:00'),
(1008, 'gus@example.com', 'active', 'Edinburgh', '2026-07-07 09:00:00');

CREATE TABLE daily_sales (
    order_date TEXT PRIMARY KEY,
    daily_revenue REAL NOT NULL
);

INSERT INTO daily_sales VALUES
('2026-06-23', 820.00), ('2026-06-24', 910.50), ('2026-06-25', 875.25),
('2026-06-26', 940.00), ('2026-06-27', 610.75), ('2026-06-30', 1020.00),
('2026-07-01', 1195.40), ('2026-07-02', 1090.20), ('2026-07-03', 980.00),
('2026-07-04', 530.50), ('2026-07-06', 1210.00), ('2026-07-07', 250.00),
('2026-07-08', 1265.75), ('2026-07-09', 1310.00);

CREATE TABLE daily_order_counts (
    order_date TEXT PRIMARY KEY,
    order_count INTEGER NOT NULL
);

INSERT INTO daily_order_counts VALUES
('2026-06-23', 72), ('2026-06-24', 80), ('2026-06-25', 77), ('2026-06-26', 83),
('2026-06-27', 51), ('2026-06-30', 91), ('2026-07-01', 104), ('2026-07-02', 98),
('2026-07-03', 89), ('2026-07-04', 44), ('2026-07-06', 108), ('2026-07-07', 19),
('2026-07-08', 112), ('2026-07-09', 117);

CREATE TABLE web_events (
    event_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    event_time TEXT NOT NULL,
    event_type TEXT NOT NULL,
    page TEXT NOT NULL
);

INSERT INTO web_events VALUES
('W001', 'U01', '2026-07-07 08:00:00', 'page_view', '/home'),
('W002', 'U01', '2026-07-07 08:08:00', 'search', '/search'),
('W003', 'U01', '2026-07-07 08:21:00', 'page_view', '/product/42'),
('W004', 'U01', '2026-07-07 08:52:00', 'page_view', '/home'),
('W005', 'U01', '2026-07-07 09:00:00', 'purchase', '/checkout'),
('W006', 'U02', '2026-07-07 09:00:00', 'page_view', '/home'),
('W007', 'U02', '2026-07-07 09:30:00', 'page_view', '/pricing'),
('W008', 'U02', '2026-07-07 10:00:01', 'signup', '/signup'),
('W009', 'U03', '2026-07-07 10:15:00', 'page_view', '/home'),
('W010', 'U03', '2026-07-07 10:15:00', 'search', '/search'),
('W011', 'U03', '2026-07-07 10:20:00', 'page_view', '/product/9'),
('W012', 'U03', '2026-07-07 11:05:00', 'page_view', '/home'),
('W013', 'U03', '2026-07-07 11:29:00', 'purchase', '/checkout'),
('W014', 'U01', '2026-07-07 12:30:00', 'page_view', '/account'),
('W015', 'U01', '2026-07-07 12:45:00', 'logout', '/logout'),
('W016', 'U04', '2026-07-07 13:00:00', 'page_view', '/home'),
('W017', 'U04', '2026-07-07 13:29:59', 'search', '/search'),
('W018', 'U04', '2026-07-07 14:00:00', 'page_view', '/product/3'),
('W019', 'U04', '2026-07-07 14:30:01', 'page_view', '/basket'),
('W020', 'U04', '2026-07-07 14:35:00', 'purchase', '/checkout');

CREATE INDEX raw_customers_customer_id_idx ON raw_customers(customer_id);
CREATE INDEX source_events_timestamp_idx ON source_events(event_timestamp);
CREATE INDEX web_events_user_time_idx ON web_events(user_id, event_time, event_id);

ANALYZE;
