-- Chapter 3. Query Primer 
-- Module 5

-- select clause (* means all columns) 
SELECT *
FROM language;

-- select clause listing single table 
SELECT language_id, name, last_update
FROM language;

-- select only a subset of columns
SELECT name
FROM language;

-- select example demonstrates the use of a table column, a literal, an expression, and a built-in function call in a single query
SELECT language_id,
language_id * 3.1415927 lang_pi_value, 
upper(name) language_name
FROM language;

-- example for executing a built-in function/evaluate simple expression 
SELECT version(),
user(),
database();

-- adding column aliases
SELECT language_id,
'COMMON' language_usage,
language_id * 3.1415927 lang_pi_value,
upper(name) language_name
FROM language;

-- making the column aliases stand out more with AS
SELECT language_id,
'COMMON' AS language_usage,
language_id * 3.1415927 AS lang_pi_value,
upper(name) AS language_name
FROM language;

-- removing duplicates (DISTINCT after SELECT) *Look at data first, DISTINCT requires data to be sorted*
SELECT DISTINCT actor_id
FROM film_actor
ORDER BY actor_id;

-- Derived (Subquery-Generated) Tables
SELECT concat(cust.last_name, ', ', cust.first_name) full_name
FROM
	(SELECT first_name, last_name, email
    FROM customer
    WHERE first_name = 'JESSIE'
    )
    cust;
    
-- Temporary tables (disapear at the end of transaction or when database session is closed)
CREATE TEMPORARY TABLE actors_j
	(actor_id smallint(5),
    first_name varchar(45),
    last_name varchar(45)
    );
INSERT INTO actors_j
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE 'J%';

SELECT * FROM actors_j;

-- Views (a query that is stored in the data dictionary, looks and acts like table: virtual table)
CREATE VIEW cust_vw AS
SELECT customer_id, first_name, last_name, active
FROM customer;

SELECT first_name, last_name
FROM cust_vw
WHERE active = 0;

-- Table Links (join multiple tables)
SELECT customer.first_name, customer.last_name,
	time(rental.rental_date) rental_time
FROM customer
	INNER JOIN rental
	ON customer.customer_id = rental.customer_id
WHERE date(rental.rental_date) = '2005-06-14';

-- Defining Table Aliases
SELECT c.first_name, c.last_name,
  time(r.rental_date) rental_time
FROM customer c
  INNER JOIN rental r
  ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14';

-- The WHERE Clause 
SELECT title
FROM film
WHERE rating = 'G' AND rental_duration >= 7;

SELECT title
FROM film
WHERE rating = 'G' OR rental_duration >= 7;
    
SELECT title, rating, rental_duration
FROM film
WHERE (rating = 'G' AND rental_duration >= 7)
	OR (rating = 'PG-13' AND rental_duration < 4);
    
-- The GROUP BY and HAVING Clauses 
SELECT c.first_name, c.last_name, count(*)
FROM customer c
	INNER JOIN rental r
	ON c.customer_id = r.customer_id
GROUP BY c.first_name, c.last_name
HAVING count(*) >= 40;

-- The ORDER BY Clause 
SELECT c.first_name, c.last_name,
	time(r.rental_date) rental_time
FROM customer c
	INNER JOIN rental r
    ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name;

SELECT c.first_name, c.last_name,
	time(r.rental_date) rental_time
FROM customer c
	INNER JOIN rental r
    ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name, c.first_name;

-- Ascending vs Descending sort order (asc vs desc)
SELECT c.first_name, c.last_name,
	time(r.rental_date) rental_time
FROM customer c
    INNER JOIN rental r
    ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY time(r.rental_date) desc;

-- Sorting via Numeric Placeholders
SELECT c.first_name, c.last_name,
    time(r.rental_date) rental_time
FROM customer c
    INNER JOIN rental r
    ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY 3 desc;