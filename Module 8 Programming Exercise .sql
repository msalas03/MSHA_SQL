-- Module 8 Programming Exercise --

-- Specify the MySQL schema to be used
USE msha_nm;

-- Exploring the data
SELECT * FROM discharges LIMIT 200;
SELECT * FROM echo_rpts LIMIT 200;


-- Problem 1
-- Using wildcard searches, find how many ECHO’s (based on distinct order_id) have a narrative line that starts with “Blood pressure”
-- followed by a blood pressure reading, and what percent of the total # of ECHO’s does that represent.

# Utilizing a subquery to first find the blood pressure narrative using the wildcard Blood Pressure% 
# REGEXP_SUBSTR used to create a new variable for the blood pressure reading 
# Took the new variable bp_reading and multiplied by 100 and divided by the SUM of the COUNT of all the bp_reading to get the percent 
SELECT order_id,
	d.bp_reading,
	bp_reading * 100.0/sum(count(bp_reading)) over() AS prcnt_total
FROM
(SELECT distinct(order_id),
	REGEXP_SUBSTR(narrative, '[:digit:]*[:punct:][:digit:]*[:blank:]mmHg') AS bp_reading
FROM echo_rpts 
WHERE narrative LIKE 'Blood pressure%') AS d
GROUP BY order_id, bp_reading;
# 3149 rows returned 


-- Problem 2 * 
-- The format of the blood pressure lines is standard and consistent, with the systolic blood pressure reading reported first, 
-- followed by the “/” character, followed by the diastolic blood pressure reading, and then ending with the units of “mmHg”. 
-- Use string pattern matching techniques to extract the systolic and diastolic blood pressure readings as two separate variables 
-- onto the blood pressure line of the echo_rpts dataset. 
-- (Hint: only the lines that matched #1 above will have values while all of the other lines will be NULL).

# Systolic bp/diastolic bp mmHg 
# Systolic bp as one variable
# Diastolic bp as one variable 
# Where clause utilizing wildcard to only show Blood Pressure narrative
SELECT *,
    REGEXP_SUBSTR(narrative, '[0-9]+') AS systolic_bp,
    REGEXP_SUBSTR(narrative, '[0-9]+[:space:]*mmHg') AS diastolic_bp
FROM echo_rpts 
WHERE narrative LIKE 'Blood pressure%';

-- Problem 3 * 
-- Height & weight are also important risk factors for cardiovascular disease.
-- The echo reports also capture these values in standard and consistent formats. 
-- Find these lines and use regular expressions to extract the following elements as distinct numeric variables,
-- similar to the systolic and diastolic blood pressure readings in exercise 2: height, bsa (body surface area), weight, and bmi (body mass index). 
-- You only need to produce SQL that extracts each of the four values into their own columns. 
-- It does not matter if they are in one SELECT statement or multiple.

# Height
SELECT *,
	REGEXP_SUBSTR(narrative, 'Height[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*cm') AS height
FROM echo_rpts;

# BSA
SELECT *,
REGEXP_SUBSTR(narrative, 'BSA[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bsa
FROM echo_rpts;

# Weight
SELECT *,
	REGEXP_SUBSTR(narrative, 'Weight[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*') AS weight
FROM echo_rpts;

# BMI
SELECT *,
REGEXP_SUBSTR(narrative, 'BMI[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bmi
FROM echo_rpts;

# Putting all the SELECT statements together 
SELECT *,
	REGEXP_SUBSTR(narrative, 'Height[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*cm') AS height,
	REGEXP_SUBSTR(narrative, 'BSA[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bsa,
	REGEXP_SUBSTR(narrative, 'Weight[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*') AS weight,
	REGEXP_SUBSTR(narrative, 'BMI[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bmi
FROM echo_rpts;


-- Problem 4
-- Ejection fraction is a measure of how well the heart pumps blood out and is helpful to diagnose heart failure. 
-- Use text mining techniques to extract the ejection fraction % as a numeric value 
-- as well as a second variable that is the method of EF calculation method (e.g. visual est, 2D biplane, 2D 4-ch, etc).

# Finding the narratives for ejection fraction 
SELECT *
FROM echo_rpts 
WHERE (narrative REGEXP 'Ejection Fraction[:space:]*[0-9]') = 1;

# Creating variable for numberic of ejection fraction 
SELECT *,
	REGEXP_SUBSTR(narrative, '[0-9]+') AS EF
FROM echo_rpts
WHERE (narrative REGEXP 'Ejection Fraction[:space:]*[0-9]') = 1;

# Creating variable for method of EF calculation 
SELECT *,
	REGEXP_SUBSTR(narrative, '[0-9]+') AS EF,
    REGEXP_SUBSTR(narrative, '\\(.*\\)') AS EF_calc_method
FROM echo_rpts
WHERE (narrative REGEXP 'Ejection Fraction[:space:]*[0-9]') = 1;


-- Problem 5 
-- Create a new dataset that is at the grain of each echo report (distinct order_id will be the unique identifier in this new data set) 
-- and extract the features built in excerises 1-4 for blood pressure, height, bsa, weight, bmi, and ejection fraction into this new data set 
-- for each echo report (i.e. order_id).

# Problem 1
SELECT order_id,
	d.bp_reading,
	bp_reading * 100.0/sum(count(bp_reading)) over() AS prcnt_total
FROM
(SELECT distinct(order_id),
	REGEXP_SUBSTR(narrative, '[:digit:]*[:punct:][:digit:]*[:blank:]mmHg') AS bp_reading
FROM echo_rpts 
WHERE narrative LIKE 'Blood pressure%') AS d
GROUP BY order_id, bp_reading;

# Problem 2
SELECT *,
    REGEXP_SUBSTR(narrative, '[0-9]+') AS systolic_bp,
    REGEXP_SUBSTR(narrative, '[0-9]+[:space:]*mmHg') AS diastolic_bp
FROM echo_rpts 
WHERE narrative LIKE 'Blood pressure%';

# Problem 3
SELECT *,
	REGEXP_SUBSTR(narrative, 'Height[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*cm') AS height,
	REGEXP_SUBSTR(narrative, 'BSA[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bsa,
	REGEXP_SUBSTR(narrative, 'Weight[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*') AS weight,
	REGEXP_SUBSTR(narrative, 'BMI[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bmi
FROM echo_rpts;

# Problem 4
SELECT *,
	REGEXP_SUBSTR(narrative, '[0-9]+') AS EF,
    REGEXP_SUBSTR(narrative, '\\(.*\\)') AS EF_calc_method
FROM echo_rpts
WHERE (narrative REGEXP 'Ejection Fraction[:space:]*[0-9]') = 1;

# Putting problems 1 and 2 together 
SELECT order_id,
	d.bp_reading,
	bp_reading * 100.0/sum(count(bp_reading)) over() AS prcnt_total,
    d.systolic_bp,
    d.diastolic_bp
FROM
(SELECT distinct(order_id),
	REGEXP_SUBSTR(narrative, '[:digit:]*[:punct:][:digit:]*[:blank:]mmHg') AS bp_reading,
    REGEXP_SUBSTR(narrative, '[0-9]+') AS systolic_bp,
    REGEXP_SUBSTR(narrative, '[0-9]+[:space:]*mmHg') AS diastolic_bp
FROM echo_rpts 
WHERE narrative LIKE 'Blood pressure%') AS d
GROUP BY order_id, d.bp_reading, d.systolic_bp, d.diastolic_bp;

# Joining problem 3 and 4 
SELECT *,
	REGEXP_SUBSTR(e.narrative, 'Height[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*cm') AS height,
	REGEXP_SUBSTR(e.narrative, 'BSA[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bsa,
	REGEXP_SUBSTR(e.narrative, 'Weight[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*') AS weight,
	REGEXP_SUBSTR(e.narrative, 'BMI[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bmi
FROM echo_rpts AS e 
LEFT JOIN ( 
	SELECT *,
		REGEXP_SUBSTR(ex.narrative, '[0-9]+') AS EF,
		REGEXP_SUBSTR(ex.narrative, '\\(.*\\)') AS EF_calc_method
	FROM echo_rpts
	WHERE (ex.narrative REGEXP 'Ejection Fraction[:space:]*[0-9]') = 1) AS ex ON e.discharge_id = ex.discharge_id; 
    
# Joining problems 1 + 2 and the Join from 3 and 4
# distinct order id used prior to join 
# database shows the height, weight, bsa, bmi, EF_calc_method, EF, diastolic_bp, systolic_bp, prcnt_total, bp_reading and narrative per distinct order id
SELECT distinct(e.order_id),e.narrative, systolic_bp, diastolic_bp, bp_reading, prcnt_total, EF, EF_calc_method,  
	REGEXP_SUBSTR(e.narrative, 'Height[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*cm') AS height,
	REGEXP_SUBSTR(e.narrative, 'BSA[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bsa,
	REGEXP_SUBSTR(e.narrative, 'Weight[:punct:][:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]*') AS weight,
	REGEXP_SUBSTR(e.narrative, 'BMI[:punct:][:space:]*[0-9]+[:punct:][0-9]+') AS bmi
FROM echo_rpts AS e 
LEFT JOIN ( 
	SELECT narrative, discharge_id,
		REGEXP_SUBSTR(narrative, '[0-9]+') AS EF,
		REGEXP_SUBSTR(narrative, '\\(.*\\)') AS EF_calc_method
	FROM echo_rpts
	WHERE (narrative REGEXP 'Ejection Fraction[:space:]*[0-9]') = 1) AS ex ON e.discharge_id = ex.discharge_id
LEFT JOIN (SELECT distinct(order_id), d.discharge_id,
	d.bp_reading,
	bp_reading * 100.0/sum(count(bp_reading)) over() AS prcnt_total,
    d.systolic_bp,
    d.diastolic_bp
FROM
(SELECT *,
	REGEXP_SUBSTR(narrative, '[:digit:]*[:punct:][:digit:]*[:blank:]mmHg') AS bp_reading,
    REGEXP_SUBSTR(narrative, '[0-9]+') AS systolic_bp,
    REGEXP_SUBSTR(narrative, '[0-9]+[:space:]*mmHg') AS diastolic_bp
FROM echo_rpts 
WHERE narrative LIKE 'Blood pressure%') AS d
GROUP BY order_id, d.bp_reading, d.systolic_bp, d.diastolic_bp, d.discharge_id) AS xf ON e.discharge_id = xf.discharge_id;
