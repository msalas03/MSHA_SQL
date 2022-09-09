-- 405 Chapter 6 Notes --
-- Working with sets -- 

-- When performing set operations on two data sets the following must apply --
-- Both data sets must have the same number of columns
-- The data types of each column across the two data sets must be the same (or the server must be able to convert one to the other)

-- The union Operator --
-- The union and union all operators allow you to combine multiple data sets (union sorts the combined set and removes duplicates, Union all does not)
SELECT 'CUST' typ, c.first_name, c.last_name -- columns selected -- 
FROM sakila.customer c -- schema.table -- 
	UNION ALL -- union all, will contain duplicates -- 
    SELECT 'ACTR' typ, a.first_name, a.last_name -- columns selected -- 
    FROM sakila.actor a; -- schema.table -- 
-- 799 rows returned 

-- The intersect Operator -- 
-- intersec operator not present in this version, below as only an example 
SELECT c.first_name, c.last_name -- columns selected -- 
FROM sakila.customer c -- schema.table -- 
WHERE c.first_name LIKE 'D%' AND c.last_name LIKE 'T%' -- function conditions -- 
INTERSECT -- asking for where the two data sets overlap --
SELECT a.first_name, a.last_name -- columns selected -- 
FROM sakila.actor a -- schema.table -- 
WHERE a.first_name LIKE 'D%' AND a.last_name LIKE 'T%'; -- function conditions -- 
-- Empty set (0.04 sec)

-- The except Operator -- 
SELECT a.first_name, a.last_name -- columns selected -- 
FROM sakila.actor a -- schema.table -- 
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%' -- funtion conditions -- 
EXCEPT -- asking for all results minus those found in both data sets -- 
SELECT c.first_name, c.last_name -- columns selected -- 
FROM sakila.customer c -- schema.table -- 
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'; -- function conditions -- 
-- 3 rows returned 

-- Set Operation Rules -- 

-- Sorting Compound Query Results 
-- When specifying names in the order by clause, you will need to choose from the column names in the first query of the compound query
SELECT a.first_name fname, a.last_name lname -- columns selected with aliases at end-- 
FROM sakila.actor a -- schema.table -- 
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%' -- conditions -- 
UNION ALL -- will contain duplicates -- 
SELECT c.first_name, c.last_name -- columns selected -- 
FROM sakila.customer c -- schema.table -- 
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%' -- conditions -- 
ORDER BY lname, fname; -- specific order for results -- 
-- 5 rows returned 

-- Set Operation Precedence 
-- Order matters, read from top to bottom 
SELECT a.first_name, a.last_name -- columns selected -- 
FROM sakila.actor a -- schema.table -- 
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%' -- conditions -- 
UNION ALL -- will contain duplicates in union of above and below sets-- 
SELECT a.first_name, a.last_name -- columns selected -- 
FROM sakila.actor a -- schema.table -- 
WHERE a.first_name LIKE 'M%' AND a.last_name LIKE 'T%' -- conditions -- 
UNION -- no duplicates in union of above and below sets --
SELECT c.first_name, c.last_name -- columns selected -- 
FROM sakila.customer c -- schema.table -- 
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'; -- conditions -- 
-- 6 rows returned 

