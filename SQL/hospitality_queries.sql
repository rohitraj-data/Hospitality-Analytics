CREATE DATABASE hospitality;
USE hospitality;

CREATE TABLE dim_date (
    date DATE,
    mmm_yy VARCHAR(10),
    week_no INT,
    day_type VARCHAR(10)
);

CREATE TABLE dim_hotels (
    property_id INT,
    property_name VARCHAR(100),
    category VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE dim_rooms (
    room_id VARCHAR(10),
    room_class VARCHAR(50)
);

CREATE TABLE fact_bookings (
    booking_id VARCHAR(20),
    property_id INT,
    booking_date DATE,
    check_in_date DATE,
    check_out_date DATE,
    no_guests INT,
    room_category VARCHAR(10),
    booking_platform VARCHAR(50),
    ratings_given FLOAT,
    booking_status VARCHAR(20),
    revenue_generated DECIMAL(10,2),
    revenue_realized DECIMAL(10,2)
);

CREATE TABLE fact_aggregated_bookings (
    property_id INT,
    check_in_date DATE,
    room_category VARCHAR(10),
    successful_bookings INT,
    capacity INT
);

SELECT * FROM dim_date;
SELECT COUNT(*) FROM dim_date;

SELECT * FROM dim_hotels;
SELECT COUNT(*) FROM dim_hotels;

SELECT * FROM dim_rooms;
SELECT COUNT(*) FROM dim_rooms;

SELECT * FROM fact_bookings;
SELECT COUNT(*) FROM fact_bookings;

SELECT * FROM fact_aggregated_bookings;
SELECT COUNT(*) FROM fact_aggregated_bookings;

-- Total Revenue
SELECT ROUND(SUM(revenue_realized),2) AS total_revenue
FROM fact_bookings;

-- Occupancy Rate
SELECT 
ROUND(SUM(successful_bookings)*100 / SUM(capacity),2) AS occupancy_rate
FROM fact_aggregated_bookings;

-- Cancellation Rate
SELECT 
ROUND(
COUNT(CASE WHEN booking_status='Cancelled' THEN 1 END)*100
/ COUNT(*),2) AS cancellation_rate
FROM fact_bookings;

-- Total Bookings
SELECT COUNT(*) AS total_bookings
FROM fact_bookings;

-- Utilized Capacity
SELECT SUM(successful_bookings) AS utilized_rooms
FROM fact_aggregated_bookings;


-- Weekday vs Weekend Revenue & Booking
SELECT d.day_type,
COUNT(f.booking_id) AS total_bookings,
ROUND(SUM(f.revenue_realized),2) AS revenue
FROM fact_bookings f
JOIN dim_date d ON f.check_in_date = d.date
GROUP BY d.day_type;

-- Revenue by City & Hotel
SELECT h.city,
h.property_name,
ROUND(SUM(f.revenue_realized),2) AS revenue
FROM fact_bookings f
JOIN dim_hotels h ON f.property_id = h.property_id
GROUP BY h.city, h.property_name
ORDER BY revenue DESC;

-- Class Wise Revenue
SELECT r.room_class,
ROUND(SUM(f.revenue_realized),2) AS revenue
FROM fact_bookings f
JOIN dim_rooms r ON f.room_category = r.room_id
GROUP BY r.room_class;

-- Checked-out / Cancel / No-show
SELECT booking_status,
COUNT(*) AS total_bookings,
ROUND(SUM(revenue_realized),2) AS revenue
FROM fact_bookings
GROUP BY booking_status;




