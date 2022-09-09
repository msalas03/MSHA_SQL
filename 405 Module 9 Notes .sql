-- 405 Module 9 --

-- Chapter 8. Grouping and Aggregates -- 

-- Grouping Concepts 
SELECT customer_id -- column being chosen -- 
FROM sakila.rental -- schema.table containing the column of interest -- 
GROUP BY customer_id; -- grouping the rental dates by the customer id -- 
-- 599 rows returned 

SELECT customer_id, count(*) -- using an aggregate function in the SELECT clause to count the number of rows in each group -- 
FROM sakila.rental -- schema.table containing the column of interest -- 
GROUP BY customer_id; -- grouping the rental dates by the customer id -- 
-- 599 rows returned 

SELECT customer_id, count(*) -- aggrigate function used to count the number of rows in each group, asterisk tells the server to count everything in that group -- 
FROM sakila.rental -- schema.table containing the column of interest -- 
GROUP BY customer_id -- grouping the rental dates by the customer id -- 
ORDER BY 2 DESC; -- determining which customers have rented the most films, order is descending -- 
-- 599 rows returned 

 SELECT customer_id, count(*) 
FROM sakila.rental
GROUP BY customer_id 
HAVING count(*) >= 40; -- filtering out undesired data from your result set based on groups of data rather than based on the raw data, results show the only the customers that have rented 40 or more films --
-- 7 rows returned 

-- Aggregate Functions: perform a specific operation over all rows in a group
-- max(): Returns the maximum value within a set
-- min(): Returns the minimum value within a set
-- avg(): Returns the average value across a set
-- sum(): Returns the sum of the values across a set
-- count(): Returns the number of values in a set
SELECT MAX(amount) max_amt,
	   MIN(amount) min_amt,
	   AVG(amount) avg_amt,
	   SUM(amount) tot_amt,
	   COUNT(*) num_payments --  query that uses all of the common aggregate functions to analyze the data on film rental payments --
FROM sakila.payment;
-- 1 row returned 

-- Implicit Versus Explicit Groups 
SELECT customer_id,
  MAX(amount) max_amt,
  MIN(amount) min_amt,
  AVG(amount) avg_amt, -- query to execute the same five aggregate functions for each customer --
  SUM(amount) tot_amt,
  COUNT(*) num_payments
FROM sakila.payment
GROUP BY customer_id; -- grouping the aggregate by the customer id -- 
-- 599 rows returned 

-- Counting Distinct Values
SELECT COUNT(customer_id) num_rows, -- counting the number of rows in payment table -- 
       COUNT(DISTINCT customer_id) num_customers -- examines the value in the customer_id column and counts only the number of unique values (no duplicates) -- 
FROM skaila.payment;
-- an example in the diffrence using DISTINCT no rows returned

-- Using Expressions 
SELECT MAX(datediff(return_date,rental_date)) -- using datediff function to compute the number of days between the return date and the rental date for every rental -- 
FROM sakila.rental; -- the max function above reutnes the highest value --

-- Generating Groups
-- Single Column Grouping 
 SELECT actor_id, count(*)
 FROM sakila.film_actor -- find the number of films associated with each actor --
 GROUP BY actor_id;
 -- 200 rows returned 

-- Multicolumn grouping 
SELECT fa.actor_id, f.rating, count(*)
FROM sakila.film_actor fa
	INNER JOIN sakila.film f -- find the total number of films for each film rating (G, PG, ...) for each actor --
    ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating
ORDER BY 1,2;
-- 996 rows returned 

-- Grouping via Expressions
SELECT extract(YEAR FROM rental_date) year, -- using extract function to return only the year portion of a date to group the rows in the rental table -- 
		COUNT(*) how_many
FROM sakila.rental
GROUP BY extract(YEAR FROM rental_date);
-- 2 rows returned 

-- Generating Rollups 
SELECT fa.actor_id, f.rating, count(*)
FROM sakila.film_actor fa
    INNER JOIN sakila.film f
    ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating WITH ROLLUP -- adding WITH ROLLUP creates a count for each distinct actor, along with the total count for each actor/rating combination --
ORDER BY 1,2;
-- 1197 rows returned 

-- Group Filter Conditions
 SELECT fa.actor_id, f.rating, count(*)
FROM sakila.film_actor fa
    INNER JOIN sakila.film f
    ON fa.film_id = f.film_id
WHERE f.rating IN ('G','PG') -- filtering out any films rated other than 'G' and 'PG' before grouping -- 
GROUP BY fa.actor_id, f.rating
HAVING count(*) > 9; -- filter condition filtering out any actors will less than 10 films after grouping -- 
-- 16 rows returned 


-- Chapter 10. Joins Revisited -- 
-- Outer Joins (If Join conditions fail there is still a column return but it is null, this is the difference between Inner and Outer Joins) 
SELECT f.film_id, f.title, count(i.inventory_id) num_copies -- The num_copies column definition was changed from count(*) to count(i.inventory_id), which will count the number of non-null values of the inventory.inventory_id column --
FROM sakila.film f
    LEFT OUTER JOIN sakila.inventory i -- left outer join =  instructs the server to include all rows from the table on the left side of the join (film, in this case) and then include columns from the table on the right side of the join (inventory) --
    ON f.film_id = i.film_id
GROUP BY f.film_id, f.title;
-- 1000 rows returned 

SELECT f.film_id, f.title, i.inventory_id
FROM sakila.film f
	LEFT OUTER JOIN sakila.inventory i -- joining film f table and inventory i tables allowing for null values -- 
    ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15; -- filter condition for film id being between 13 and 15 -- 
-- 11 rows returned 

-- Left Versus Right Outer Joins (Left is most commonly used, Right is to show example) 
-- The keyword left indicates that the table on the left side of the join is responsible for determining the number of rows in the result set, whereas the table on the right side is used to provide column values whenever a match is found. However, you may also specify a right outer join, in which case the table on the right side of the join is responsible for determining the number of rows in the result set, whereas the table on the left side is used to provide column values --
SELECT f.film_id, f.title, i.inventory_id
FROM sakila.inventory i
	RIGHT OUTER JOIN sakila.film f -- right table (film f determines number of rows) and left table (inventory i used to provide column values) --  
    ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15;
-- 11 rows returned
 
--  If you want to outer-join tables A and B and you want all rows from A with additional columns from B whenever there is matching data, you can specify either A left outer join B or B right outer join A --

-- Three Way Outer Joins (outer-joining one table with two other tables)
SELECT f.film_id, f.title, i.inventory_id, r.rental_date
FROM sakila.film f
	LEFT OUTER JOIN sakila.inventory i
    ON f.film_id = i.film_id -- left outer join connecting film f and inventory i tables using film_id --
    LEFT OUTER JOIN sakila.rental r
    ON i.inventory_id = r.inventory_id -- left out join connecting rental r and inventory i tables using inventory_id -- 
WHERE f.film_id BETWEEN 13 AND 15;
-- 32 rows returned 

-- Cross Joins (Cartesian product, which is essentially the result of joining multiple tables without specifying any join conditions)
SELECT c.name category_name, l.name language_name
FROM sakila.category c
    CROSS JOIN sakila.language l;
-- 96 rows returned 

-- Natural Joins (allows you to name the tables to be joined but lets the database server determine what the join conditions need to be)
SELECT cust.first_name, cust.last_name, date(r.rental_date)
FROM
    (SELECT customer_id, first_name, last_name
     FROM sakila.customer
      ) cust
    NATURAL JOIN sakila.rental r;
-- 16044 rows returned 
