-- Module 2 Programming Exercise --

-- Informing SQL what schema to use 
USE msha_nm;

-- Exploring the data
SELECT * FROM discharges LIMIT 100;

-- Problem 1
-- Create a new variable age_at_admit_cat that bins the age_at_admit variable into the following categories: “0-18”, “19-39”, “40-59”, “60-79”, “80+”.
SELECT d.discharge_id,
 
	# The following code is creating a bin for the age at admit, breaking the ages down into categories
    # SQL will evaluve the first WHEN statement and if TRUE then it will stop, but if it is not TRUE then it will go to the next WHEN and so on
	CASE 	WHEN d.age_at_admit < 18 THEN '0 - 18'
			WHEN d.age_at_admit < 39 THEN '19 - 39'
			WHEN d.age_at_admit < 59 THEN '40 - 59'
			WHEN d.age_at_admit < 79 THEN '60-79'
			ELSE '80+' END							
			AS age_at_admit_cat
            
FROM discharges AS d;

-- Problem 2
-- Create a new variable named los_days that calculates the patients’s length of stay in the hospital as the number of days between admit_datetime and discharge_datetime.
SELECT d.discharge_id, 

	# The following code is subtracting admit_datetime from the the discharge_datetime and the result is a new variable named los_days
    # This is accomplished by using DATEDIFF, discharge_datetime minus admit_datetime 
	DATEDIFF(d.discharge_datetime,admit_datetime) AS los_days
    
FROM discharges AS d;

-- Problem 3
-- Create a new variable that is a dummy variable named “emergent” that is a 1 if admit_type is “Emergency” OR patient was admitted through the emergency department (ed_arrival_datetime is populated if the patient came through the ED).
SELECT d.discharge_id, 

	# WHEN the admit_type is Emergency then a 1 is added, if not then a zero
    # Adding an OR statement to account for if the patient was admitted through the emergency department, if the result is NOT NULL (there is a datetime recorded) then a 1 is added, if not a zero 
    CASE d.admit_type WHEN 'Emergency' THEN 1 ELSE 0 OR ed_arrival_datetime IS NOT NULL 
    END						
    AS emergent

FROM discharges AS d;

-- Problem 4
-- Create a new variable named arrival_date that is just the date of admit or date of ED arrival (whichever is first), without the time.
-- Will need the use of a subquery
# Query to return which date occured first, this will be placed in the subquery  
SELECT d.discharge_id,
	CASE WHEN ed_arrival_datetime IS NULL THEN admit_datetime ELSE (CASE WHEN ed_arrival_datetime < admit_datetime THEN ed_arrival_datetime ELSE admit_datetime END) END AS arrival_date1
FROM discharges AS d;
# Query to only show the date from the new variable arrival_date1m, removing the time 
SELECT d.discharge_id, 
	DATE (arrival_date1) AS arrival_date 
FROM discharges AS d;

# Final product to satisfy both criteria   
SELECT d.discharge_id,
	DATE (arrival_date1) AS arrival_date
FROM discharges AS d
LEFT JOIN	(
			SELECT d1.discharge_id,
				CASE WHEN ed_arrival_datetime IS NULL THEN admit_datetime ELSE (CASE WHEN ed_arrival_datetime < admit_datetime THEN ed_arrival_datetime ELSE admit_datetime END) END AS arrival_date1 
			FROM discharges AS d1
			) AS r ON d.discharge_id = r.discharge_id
; 	

-- Problem 5
-- Create a new variable that is a dummy variable named “transferred” that is a 1 if the admit_department is not the same value as the discharge_department.
SELECT d.discharge_id, 

	# CASE WHEN the admit_department does not equal (!=) the discharge_department then a 1 will be displayed, if the two are equal then a zero is displayed 
	CASE WHEN admit_department != discharge_department THEN 1 ELSE 0 
    END						
    AS transferred
    
FROM discharges AS d; 

-- Problem 6
-- Write a query with a result set where each row is an admit department and an arrival date and includes the following columns:
-- a. admit_department
-- b. arrival_date
-- c. volume = count of records
-- d. prct_emergent = percent of records where emergent = 1
-- e. prct_peds_ger = percent of records where age 0-18 or 80+
-- f. prct_transferred = percent of records where transferred = 1
-- g. alos = average of los_days

	# a. admit_depatment 
	SELECT admit_department
    FROM discharges AS d;
	# b. Code used to create the arrival_date variable 
	SELECT d.discharge_id,
		DATE (arrival_date1) AS arrival_date
	FROM discharges AS d
	LEFT JOIN	(
			SELECT d1.discharge_id,
				CASE WHEN ed_arrival_datetime IS NULL THEN admit_datetime ELSE (CASE WHEN ed_arrival_datetime < admit_datetime THEN ed_arrival_datetime ELSE admit_datetime END) END AS arrival_date1 
			FROM discharges AS d1
			) AS r ON d.discharge_id = r.discharge_id
    ;
	# c. Code used to create volume = count of records
    SELECT COUNT(*) AS volume 
    FROM discharges AS d;
	# d. Code used to create prct_emergent = percent of records where emergent = 1
    SELECT d.discharge_id, 
		CASE d.admit_type WHEN 'Emergency' THEN 1 ELSE 0 OR ed_arrival_datetime IS NOT NULL 
		END						
		AS emergent
	FROM discharges AS d;
    # e. Code used to create prct_peds_ger = percent of records where age 0-18 or 80+
	SELECT d.discharge_id, 	
        CASE 	WHEN d.age_at_admit < 18 THEN '0 - 18'
			WHEN d.age_at_admit < 39 THEN '19 - 39'
			WHEN d.age_at_admit < 59 THEN '40 - 59'
			WHEN d.age_at_admit < 79 THEN '60-79'
			ELSE '80+' END							
			AS age_at_admit_cat
	FROM discharges AS d; 
    # f. Code used to create prct_transferred = percent of records where transferred = 1
	SELECT d.discharge_id, 
		CASE WHEN admit_department != discharge_department THEN 1 ELSE 0 
		END						
		AS transferred    
	FROM discharges AS d;	
    # g. Code used to create alos = average of los_days
	SELECT d.discharge_id, 	
		DATEDIFF(d.discharge_datetime,admit_datetime) AS los_days
	FROM discharges AS d;
        
# Solution 
	# I utilized a subquery to house all the features b through g and then took the features and performed different functions (COUNT, percent, DATE, AVG) on them to create new variables
    # The WHERE clause was used to filter the results to only show when emergent = 1, AND transferred = 1, AND age_at_admit_cat = '0 -18' OR age_at_admit_cat = '80+'
    # Group BY was used at the end of my query in order for results to populate. Wihtout it I was getting an error. 
    SELECT d.admit_department, 
		DATE (arrival_date1) AS arrival_date,
        volume,
        emergent * 100/ emergent AS prct_emergent,
        age_at_admit_cat * 100/ age_at_admit AS prct_peds_ger,
        transferred *100/ transferred AS prct_transferred,
        AVG(los_days) AS alos
	FROM discharges AS d
	LEFT JOIN	(
			SELECT d1.discharge_id,
				CASE WHEN d1.ed_arrival_datetime IS NULL THEN d1.admit_datetime ELSE (CASE WHEN d1.ed_arrival_datetime < d1.admit_datetime THEN d1.ed_arrival_datetime ELSE d1.admit_datetime END) END AS arrival_date1,
                COUNT(*) AS volume,
                CASE d1.admit_type WHEN 'Emergency' THEN 1 ELSE 0 OR d1.ed_arrival_datetime IS NOT NULL 
				END AS emergent,
                CASE WHEN d1.age_at_admit < 18 THEN '0 - 18'
					 WHEN d1.age_at_admit < 39 THEN '19 - 39'
					 WHEN d1.age_at_admit < 59 THEN '40 - 59'
					 WHEN d1.age_at_admit < 79 THEN '60-79'
					 ELSE '80+' END AS age_at_admit_cat,
				CASE WHEN d1.admit_department != d1.discharge_department THEN 1 ELSE 0 
				END AS transferred,
                DATEDIFF(d1.discharge_datetime,d1.admit_datetime) AS los_days
			FROM discharges AS d1
            GROUP BY 1
			) AS r ON d.discharge_id = r.discharge_id
    WHERE emergent = 1
        AND transferred = 1
        AND age_at_admit_cat = '0 -18'
        OR age_at_admit_cat = '80+'
	GROUP BY d.admit_department, arrival_date, volume, prct_emergent, prct_peds_ger, prct_transferred;
# There are NULL values in the prc_emergent and prct_transferred columns    
    
-- Problem 7 
# I performed data manipulation in R last quater, I found using an IF THEN statement to be more complex than using the WHEN THEN statement in SQL. 
# I like the ability to look at the data right in SQL and not having to to a seperate window, this would occur in R when I used the View function.
# Not to mention SQL is a lot faster in returning the results, I was able to look at the data and then modify my code as I see fit. 
# The only issue I faced was creating a new varable in SQL. In R you can create an object and assign an action to it. The object is stored in the session and can be called upon later in your code. 
# This made is very easy to manipulate data that required more complex statements.
# With SQL you needed to utilize a subquery in order to utilize the variable that was created, at least that is what I have used thus far. 
# I tried to use a new variable without using a subquery and SQL could not find the variable to use. 
# I also faced some issues using the COUNT and similar functions in SQL. Without a GROUP BY I would recieve an error. I overcame this ussue by utilizing a subquery. 

