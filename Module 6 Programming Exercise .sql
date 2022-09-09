-- Module 6 Programming Exercise -- 

-- Informing SQL what schema to use 
USE msha_nm;

-- Exploring the data
SELECT * FROM discharges LIMIT 200;
SELECT * FROM labs LIMIT 200;
SELECT * FROM meds LIMIT 200;


# 1: The hemoglobin A1c lab test is used to diagnose diabetes.
# Create a new variable on the discharges data that is the maximum value of result_value_num when the lab test name is “HEMOGLOBIN A1C”.

# Using the MAX function to obtain the maximimum value in the results_value_num column and assigning to a new variable
# WHERE clause to show the lab test named Hemoglobin A1C
# Using a left join for this query on the discharges table by the discharge_id 
SELECT d.discharge_id, Max_Hemoglobin_A1C
FROM discharges AS d
LEFT JOIN ( 
	SELECT l.discharge_id,
	MAX(l.result_value_num) AS Max_Hemoglobin_A1C
	FROM labs AS l
    WHERE l.component_name LIKE "HEMOGLOBIN A1C"
	GROUP BY l.discharge_id) AS l1 ON d.discharge_id = l1.discharge_id;

# 2: An HbA1c value below 5.7 is considered “normal”, 5.7 – 6.4 is considered “pre-diabetes”, and higher than 6.4 is considered “diabetes”.
# Create a new variable on the discharges data that classifies a patient into one of those categories based on the max value of the “HEMOGLOBIN A1C” lab result.
# If a patient does not have an A1C result, classify them as “no HbA1c”.

# Takimg the variable created in problem 1 and using the CASE function to bin the values and assign a classification
# Left Join required for the use of the labs table 
SELECT d.discharge_id,
	CASE WHEN Max_Hemoglobin_A1C < 5.7 THEN "normal"
		 WHEN Max_Hemoglobin_A1C BETWEEN 5.7 AND 6.4 THEN "pre-diabetes"
         WHEN Max_Hemoglobin_A1C > 6.4 THEN "diabetes"
         ELSE "no HbA1c"
         END AS Classification 
FROM discharges AS d
LEFT JOIN ( 
	SELECT l.discharge_id,
	MAX(l.result_value_num) AS Max_Hemoglobin_A1C
	FROM labs AS l
    WHERE l.component_name LIKE "HEMOGLOBIN A1C"
	GROUP BY l.discharge_id) AS l1 ON d.discharge_id = l1.discharge_id;

# 3: The labs data has columns for the reference range of each lab test (ref_low and ref_high). 
# A result is considered to be abnormal is the result is outside of that range. 
# Create a new variable on the labs data that is a flag of 1 if the result is outside the reference range and 0 if within the range.
# If a reference range does not exist, NULL.

# Only one table utilized in this problem, labs
# CASE function to bin the result_value_num values in accordance to if the value falls below, in between, or above the ref_low and ref_high value
# If there is no value, then NULL 
SELECT l.discharge_id, 
	CASE WHEN result_value_num < ref_low THEN 1
		 WHEN result_value_num > ref_high THEN 1
         WHEN result_value_num BETWEEN ref_low AND ref_high THEN 0 
		 ELSE NULL
	END AS Range_flag 
FROM labs AS l; 

# 4:The reference ranges are based on general patient populations, but may not be suitable for patients with certain conditions, like diabetes.
# The "GLUCOSE" lab test (where the component name contains the word "GLUCOSE") is an important result for monitoring glycemic control. 
# While research is limited and conflicting on the appropriate targets of glucose readings, one recommendation for glycemic control is all GLUCOSE readings below 180 mg/dL. 
# Glycemic control is important to monitor every day, so create new result set for each discharge and date during the discharge (so if the patient is in the hospital for three days, they will have three rows in the data set). 
# For each row (patient day), create a new variable named glucose_lt_180 that is a flag of 1 if all GLUCOSE results on that day are < 180 mg/dL. 
# Final result set only needs to have a row if the patient day had a GLUCOSE result for that day.

# component_name LIKE "%GLUCOSE%", wildcard used to find all values that contain the word "GLUCOSE" 
# GLUCOSE levels < 180 mg/dL will be the criteria, flag of 1, else 0, AS glucose_lt_180 
# Tables needed: labs and discharge
# New variable that counts the number of days the patient was in the hospital and each day is its own row AS patient_day 
SELECT d.discharge_id, glucose_lt_180,
	TIMESTAMPDIFF(DAY, admit_datetime, discharge_datetime) AS patient_day
FROM discharges AS d
LEFT JOIN ( 
	SELECT l.discharge_id,
		IF(result_value_num < 180,1,0) AS glucose_lt_180
	FROM labs AS l
    WHERE l.component_name LIKE "%GLUCOSE%"
	) AS l1 ON d.discharge_id = l1.discharge_id;

# 5: One additional criteria for determining glycemic control is a preprandial (before meal) glucose reading. 
# For our purposes, we will consider GLUCOSE readings prior to 8 am to be preprandial. 
# Create a new variable in the data set from exercise 4 named glucose_morning that is the maximum GLUCOSE reading between the hours of 4 am and 8 am. 
# If no result exists between those hours, the value should be NULL.

# new variable: MAX(result_value_num) located in labs table 
# WHERE result_datetime located in labs table BETWEEN 4am and 8am 
#	AND component_name located in labs table LIKE "%GLUCOSE%" AS glucose_morning 
# If no value exists, then NULL

# Query containing new variable 
SELECT MAX(result_value_num) AS glucose_morning
FROM labs as l 
WHERE result_datetime BETWEEN 4 AND 8
	AND component_name LIKE "%GLUCOSE%"
;  
 
# Combining to previous data set from problem 4 
SELECT d.discharge_id, glucose_morning,
	TIMESTAMPDIFF(DAY, admit_datetime, discharge_datetime) AS patient_day
FROM discharges AS d
LEFT JOIN ( 
	SELECT l.discharge_id, MAX(result_value_num) AS glucose_morning 
	FROM labs AS l
    WHERE l.component_name LIKE "%GLUCOSE%"
		AND result_datetime BETWEEN 4 AND 8
	GROUP BY l.discharge_id, result_value_num
	) AS l1 ON d.discharge_id = l1.discharge_id
    ;
    
# 6: Insulin is the typical medication treatment for diabetic patients. 
# Create a new variable on the discharges data that is the taken_time of the first administration of a medication (from meds data) that has the pharmaceutical_class of “INSULINS”.

# Tables needed: discharges, and meds 
# First taken time: MIN(taken_time) AS first_administration_Insulins
# pharmaceutical_class LIKE "INSULINS"
SELECT d.discharge_id, first_administration_Insulins
FROM discharges AS d
LEFT JOIN ( 
	SELECT m.discharge_id,
		MIN(m.taken_time) AS first_administration_Insulins
	FROM meds AS m
    WHERE m.pharmaceutical_class LIKE "INSULINS"
	GROUP BY m.discharge_id) AS m1 ON d.discharge_id = m1.discharge_id; 


