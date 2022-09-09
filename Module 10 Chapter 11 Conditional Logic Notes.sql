-- 405 Chapter 11. Conditional Logic Notes -- 

-- Example of Conditional Logic (using CASE)
SELECT first_name, last_name,
	CASE -- conditional logic -- 
     WHEN active = 1 THEN 'ACTIVE' -- This query includes a case expression to generate a value for the activity_type column, which returns the string “ACTIVE” or “INACTIVE” depending on the value of the customer.active column -- 
     ELSE 'INACTIVE'
    END activity_type
FROM sakila.customer;
-- 599 rows returned 

-- Searched CASE Expressions 
-- Syntax structure 
CASE
  WHEN C1 THEN E1
  WHEN C2 THEN E2
  ...
  WHEN CN THEN EN
  [ELSE ED]
END;
-- Example of Searched CASE Expression
CASE
  WHEN category.name IN ('Children','Family','Sports','Animation')
    THEN 'All Ages'
  WHEN category.name = 'Horror'
    THEN 'Adult'
  WHEN category.name IN ('Music','Games')
    THEN 'Teens'
  ELSE 'Other'
END;

-- Simple CASE Expression (less flexible because you cannot specify your own conditions) 
-- Syntax
CASE V0 -- V0 represents a value, and the symbols V1, V2, ..., VN represent values that are to be compared to V0 -- 
  WHEN V1 THEN E1
  WHEN V2 THEN E2
  ... -- The symbols E1, E2, ..., EN represent expressions to be returned by the case expression, and ED represents the expression to be returned if none of the values in the set V1, V2, ..., VN matches the V0 value --
  WHEN VN THEN EN
  [ELSE ED]
END;
-- Example of Simple CASE Expression 
CASE category.name
  WHEN 'Children' THEN 'All Ages'
  WHEN 'Family' THEN 'All Ages'
  WHEN 'Sports' THEN 'All Ages'
  WHEN 'Animation' THEN 'All Ages'
  WHEN 'Horror' THEN 'Adult'
  WHEN 'Music' THEN 'Teens'
  WHEN 'Games' THEN 'Teens'
  ELSE 'Other'
END;

-- Examples of CASE Expressions
-- Result Set Transformation (You may have run into a situation where you are performing aggregations over a finite set of values, such as days of the week, but you want the result set to contain a single row with one column per value instead of one row per value)
-- You have also been instructed to return a single row of data with three columns (one for each of the three months). To transform this result set into a single row, you will need to create three columns and, within each column, sum only those rows pertaining to the month in question -- 
SELECT
    SUM(CASE WHEN monthname(rental_date) = 'May' THEN 1
		ELSE 0 END) May_rentals,
    SUM(CASE WHEN monthname(rental_date) = 'June' THEN 1
		ELSE 0 END) June_rentals,
    SUM(CASE WHEN monthname(rental_date) = 'July' THEN 1
		ELSE 0 END) July_rentals
FROM sakila.rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-01';
-- 1 row returned 

-- Checking for Existence (determining whether a relationship exists between two entities without regard for the quantity)
SELECT a.first_name, a.last_name,
	CASE
		WHEN EXISTS (SELECT 1 FROM sakila.film_actor fa
                        INNER JOIN sakila.film f ON fa.film_id = f.film_id
						WHERE fa.actor_id = a.actor_id
                        AND f.rating = 'G') THEN 'Y'
         ELSE 'N'
       END g_actor,
	CASE
		WHEN EXISTS (SELECT 1 FROM sakila.film_actor fa
                        INNER JOIN sakila.film f ON fa.film_id = f.film_id
						WHERE fa.actor_id = a.actor_id
                        AND f.rating = 'PG') THEN 'Y'
		ELSE 'N'
	  END pg_actor,
	CASE
		WHEN EXISTS (SELECT 1 FROM sakila.film_actor fa
                        INNER JOIN sakila.film f ON fa.film_id = f.film_id
                        WHERE fa.actor_id = a.actor_id
                        AND f.rating = 'NC-17') THEN 'Y'
		ELSE 'N'
	END nc17_actor
FROM sakila.actor a
WHERE a.last_name LIKE 'S%' OR a.first_name LIKE 'S%';
-- 22 rows returned 
-- Example of simple CASE expression to count the number of copies in inventory for each film and then  returns either 'Out Of Stock', 'Scarce', 'Available', or 'Common'
SELECT f.title,
	CASE (SELECT count(*) FROM sakila.inventory i 
			WHERE i.film_id = f.film_id)
         WHEN 0 THEN 'Out Of Stock'
         WHEN 1 THEN 'Scarce'
         WHEN 2 THEN 'Scarce'
         WHEN 3 THEN 'Available'
         WHEN 4 THEN 'Available'
         ELSE 'Common'
       END film_availability
FROM sakila.film f;
-- 1000 rows returned 

-- Dividion-by-Zero Errors (To safeguard your calculations from encountering errors or, even worse, from being mysteriously set to null, you should wrap all denominators in conditional logic, as demonstrated by the following)
SELECT c.first_name, c.last_name,
    sum(p.amount) tot_payment_amt,
    count(p.amount) num_payments,
    sum(p.amount) /
         CASE WHEN count(p.amount) = 0 THEN 1
           ELSE count(p.amount)
         END avg_payment
FROM sakila.customer c
	LEFT OUTER JOIN sakila.payment p
	ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name;
-- 599 rows returned 
