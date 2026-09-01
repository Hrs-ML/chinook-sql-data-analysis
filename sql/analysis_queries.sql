/*
===============================================================================
                         E-COMMERCE DATA ANALYSIS
===============================================================================

Project  : SQL Data Analysis
Database : Chinook
Tool     : PostgreSQL

Description:
This project uses the Chinook database to perform SQL-based business analysis.
The analysis focuses on customers, sales, invoices, tracks, artists, albums,
genres, and employee performance.

The questions below explore revenue, customer behavior, product performance,
sales trends, and employee performance.

===============================================================================
                         ANALYSIS QUESTIONS
===============================================================================*/


-- ============================================================================
-- 01. REVENUE BY GENRE
-- ============================================================================
-- Which music genres generate the highest total revenue?
-- ============================================================================

SELECT
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM genre AS g
JOIN track AS t
    ON g.genre_id = t.genre_id
JOIN invoice_line AS il
    ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY total_revenue DESC
LIMIT 5;

-- ============================================================================
-- 02. TOP ARTISTS BY REVENUE
-- ============================================================================
-- Which artists generate the highest total revenue?
-- ============================================================================

SELECT
    ar.name AS artist,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM artist AS ar
JOIN album AS al
    ON ar.artist_id = al.artist_id
JOIN track AS t
    ON al.album_id = t.album_id
JOIN invoice_line AS il
    ON t.track_id = il.track_id
GROUP BY ar.name
ORDER BY total_revenue DESC
LIMIT 5;

-- ============================================================================
-- 03. COUNTRY PERFORMANCE
-- ============================================================================
-- Which countries have the highest number of customers and total revenue?
-- ============================================================================

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND(SUM(i.total), 2) AS total_revenue
FROM customer AS c
LEFT JOIN invoice AS i
    ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC
LIMIT 5;

-- ============================================================================
-- 04. TOP CUSTOMERS
-- ============================================================================
-- Who are the top 10 customers based on their total spending?
-- ============================================================================

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    ROUND(SUM(i.total), 2) AS total_spending
FROM customer AS c
JOIN invoice AS i
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spending DESC
LIMIT 10;

-- ============================================================================
-- 05. INVOICE VALUE ANALYSIS
-- ============================================================================
-- What are the average, minimum, and maximum invoice values?
-- ============================================================================

SELECT
    ROUND(AVG(total), 2) AS average_invoice_value,
    ROUND(MIN(total), 2) AS minimum_invoice_value,
    ROUND(MAX(total), 2) AS maximum_invoice_value
FROM invoice;

-- ============================================================================
-- 06. MOST PURCHASED TRACKS
-- ============================================================================
-- Which tracks have been purchased the most based on the total quantity sold?
-- ============================================================================

SELECT
    t.track_id,
    t.name AS track,
    SUM(il.quantity) AS total_quantity_sold
FROM track AS t
JOIN invoice_line AS il
    ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- ============================================================================
-- 07. TOP ALBUMS BY REVENUE
-- ============================================================================
-- Which albums generate the highest total revenue?
-- ============================================================================

SELECT
    al.title AS album,
    ar.name AS artist,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM album AS al
JOIN artist AS ar
    ON al.artist_id = ar.artist_id
JOIN track AS t
    ON al.album_id = t.album_id
JOIN invoice_line AS il
    ON t.track_id = il.track_id
GROUP BY al.album_id, al.title, ar.name
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================================================
-- 08. REVENUE TREND
-- ============================================================================
-- How does total revenue change over time?
-- ============================================================================

SELECT
    DATE_TRUNC('month', invoice_date)::date AS month,
    ROUND(SUM(total), 2) AS monthly_revenue
FROM invoice
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY month;

-- ============================================================================
-- 09. CUSTOMERS WITH NO PURCHASES
-- ============================================================================
-- Are there any customers who have never made a purchase?
-- ============================================================================

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.country
FROM customer AS c
LEFT JOIN invoice AS i
    ON c.customer_id = i.customer_id
WHERE i.invoice_id IS NULL
ORDER BY c.customer_id;

-- ============================================================================
-- 10. EMPLOYEE PERFORMANCE
-- ============================================================================
-- Which support employees manage the most customers, and how much revenue
-- is generated by those customers?
-- ============================================================================

SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND(COALESCE(SUM(i.total), 0), 2) AS customer_revenue
FROM employee AS e
LEFT JOIN customer AS c
    ON e.employee_id = c.support_rep_id
LEFT JOIN invoice AS i
    ON c.customer_id = i.customer_id
WHERE e.title = 'Sales Support Agent'
GROUP BY e.employee_id, employee_name
ORDER BY customer_revenue DESC;

-- ============================================================================
-- 11. REVENUE BY MEDIA TYPE
-- ============================================================================
-- Which media types generate the highest total revenue?
-- ============================================================================

SELECT
    mt.name AS media_type,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM media_type AS mt
JOIN track AS t
    ON mt.media_type_id = t.media_type_id
JOIN invoice_line AS il
    ON t.track_id = il.track_id
GROUP BY mt.name
ORDER BY total_revenue DESC
LIMIT 5;

-- ============================================================================
-- 12. CUSTOMER PURCHASE FREQUENCY
-- ============================================================================
-- Which customers have made the highest number of purchases?
-- ============================================================================

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(i.invoice_id) AS total_purchases
FROM customer AS c
JOIN invoice AS i
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_purchases DESC
LIMIT 10;

-- ============================================================================
-- 13. GENRE POPULARITY
-- ============================================================================
-- Which genres have the highest number of tracks sold?
-- ============================================================================

SELECT
    g.name AS genre,
    SUM(il.quantity) AS total_tracks_sold
FROM genre AS g
JOIN track AS t
    ON g.genre_id = t.genre_id
JOIN invoice_line AS il
    ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY total_tracks_sold DESC
LIMIT 10;

-- ============================================================================
-- 14. MONTHLY SALES PERFORMANCE
-- ============================================================================
-- Which months generate the highest total revenue?
-- ============================================================================

SELECT
    TO_CHAR(invoice_date, 'Month') AS month,
    EXTRACT(MONTH FROM invoice_date) AS month_number,
    ROUND(SUM(total), 2) AS total_revenue
FROM invoice
GROUP BY
    TO_CHAR(invoice_date, 'Month'),
    EXTRACT(MONTH FROM invoice_date)
ORDER BY total_revenue DESC
LIMIT 12;

-- ============================================================================
-- 15. HIGH-VALUE CUSTOMERS
-- ============================================================================
-- Which customers have spent more than the average customer spending?
-- ============================================================================

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    ROUND(SUM(i.total), 2) AS total_spending
FROM customer AS c
JOIN invoice AS i
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
HAVING SUM(i.total) > (
    SELECT AVG(customer_spending)
    FROM (
        SELECT
            customer_id,
            SUM(total) AS customer_spending
        FROM invoice
        GROUP BY customer_id
    ) AS customer_totals
)
ORDER BY total_spending DESC;
/*
===============================================================================
                              END OF ANALYSIS
===============================================================================
*/