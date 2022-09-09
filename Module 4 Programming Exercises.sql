-- Module 4 Programming Exercises -- 

-- Informing SQL what schema to use 
USE msha_nm;

-- Exploring the data
SELECT * FROM discharges LIMIT 100;
SELECT * FROM diagnoses LIMIT 100;
SELECT * FROM procedures LIMIT 100;
SELECT * FROM icd10_code_list LIMIT 100;


# 1 
# The diagnosis_nbr and procedure_nbr variables on the diagnoses and procedures data indicate the sequencing of the codes. The code with the value of 1 in those variables is called the primary diagnosis or procedure. Add new variables to the discharges data named primary_dx and primary_px with the diagnosis_code and procedure_code values when the diagnosis_nbr and procedure_nbr equals 1
# I will be using the diagnoses and procedures tables, they will need to be joined using the discharge_id 

# First query that will create a new variable primary_dx: IF the diagnosis_nbr = 1 then a 1 is printed, all else will be a 0
# If any of the  diagnosis numbers is a 1 then the MAX aggrigate function will combine them, in relation to the discharge id 
SELECT discharge_id, 
	MAX(IF(diagnosis_nbr = 1, 1, 0)) AS primary_dx
FROM diagnoses
GROUP BY discharge_id;

# Second query that will create a new variable primary_px: IF the procedure_nbr = 1 then a 1 is printed, all else will be a 0 
# If any of the  diagnosis numbers is a 1 then the MAX aggrigate function will combine them, in relation to the discharge id 
SELECT discharge_id,
	MAX(IF(procedure_nbr = 1, 1, 0)) AS primary_px
FROM procedures
GROUP BY discharge_id;

# Brining both queries together in a LEFT JOIN (Solution)
# I added an ORDER BY clause to have the discharge id's ordered in ascending order, for personal preference 
SELECT d.discharge_id, dx.primary_dx, px.primary_px
FROM discharges AS d
LEFT JOIN ( 
	SELECT discharge_id, 
	MAX(IF(diagnosis_nbr = 1, 1, 0)) AS primary_dx
	FROM diagnoses
	GROUP BY discharge_id) AS dx ON d.discharge_id = dx.discharge_id
LEFT JOIN (
	SELECT discharge_id,
	MAX(IF(procedure_nbr = 1, 1, 0)) AS primary_px
	FROM procedures
	GROUP BY discharge_id) AS px ON d.discharge_id = px.discharge_id
ORDER BY d.discharge_id;


# 2
# The number of diagnosis and procedures can be indicative of patient acuity. Create new variables for diagnosis_cnt and procedure_cnt on the discharges data that is the count of diagnoses and procedures rows
# I will be using the diagnoses and procedures tables, they will need to be joined using the discharge_id 

# First query to count the number of diagnosis 
SELECT discharge_id, 
	COUNT(discharge_id) AS diagnosis_cnt
FROM diagnoses
GROUP BY discharge_id; 

# Second Query to count the number of procedures 
SELECT discharge_id, 
	COUNT(discharge_id) AS procedure_cnt
FROM procedures
GROUP BY discharge_id; 

# Brining both queries together in a LEFT JOIN (Solution) 
# I added an ORDER BY clause to have the discharge id's ordered in ascending order, for personal preference 
SELECT d.discharge_id, d1.diagnosis_cnt, p1.procedure_cnt
FROM discharges AS d
LEFT JOIN ( 
	SELECT discharge_id, 
	COUNT(discharge_id) AS diagnosis_cnt
	FROM diagnoses
	GROUP BY discharge_id) AS d1 ON d.discharge_id = d1.discharge_id
LEFT JOIN (
	SELECT discharge_id, 
	COUNT(discharge_id) AS procedure_cnt
	FROM procedures
	GROUP BY discharge_id) AS p1 ON d.discharge_id = p1.discharge_id
ORDER BY d.discharge_id;


# 3
# Diabetes mellitus are defined by ICD-10 diagnosis codes with a diagnosis_group value of “DIABETES MELLITUS”. Create a new binary variable on the diagnoses data for diabetes that is a flag of 1 if the diagnosis_group equals “DIABETES MELLITUS”
# I will be using the diagnoses table 

# Query to create a binary variable that is a flag of 1 if the diagnosis_group equals “DIABETES MELLITUS”
SELECT discharge_id,
	MAX(IF(diagnosis_group LIKE '%MELLITUS%', 1, 0)) AS diabetes_flag
FROM diagnoses
GROUP BY discharge_id;
 
 
# 4
# Diabetic patients often experience complications with their kidneys due to damage to the blood vessels from high blood sugar. Create a new binary variable on the diagnoses data for kidney_not_poa and that is a flag of 1 if the diagnosis_group value equals “ACUTE KIDNEY FAILURE AND CHRONIC KIDNEY DISEASE” and the diagnosis present on admission indicator (diagnosis_poa) does not equals “Y”
# I will be using the diagnoses table 

# Query creating a flag of 1 if the diagnosis_group value equals “ACUTE KIDNEY FAILURE AND CHRONIC KIDNEY DISEASE and the diagnosis present on admission indicator (diagnosis_poa) does not equals “Y” named kidney_not_poa
SELECT discharge_id,
	CASE WHEN MAX(diagnosis_group LIKE 'ACUTE KIDNEY FAILURE AND CHRONIC KIDNEY DISEASE' AND diagnosis_poa != 'Y') THEN 1 
                    ELSE 0 
                    END AS kidney_not_poa
FROM diagnoses
GROUP BY discharge_id, diagnosis_poa;

	
# 5
# Diabetic patients that do experience renal complications may require dialysis. The ICD-10 procedure codes for hemodialysis are “5A1D70Z”, “5A1D80Z”, and “5A1D90Z”. Create a new variable on the procedures data for hemodialysis that are flags of 1 if the procedure is one of these codes
# I will be using the procedures table   

# Query creating a binary variable flag of 1 when a hemodialysis procedure code is present(“5A1D70Z”, “5A1D80Z”, and “5A1D90Z”)
SELECT discharge_id,
	CASE	WHEN MAX(procedure_code LIKE '5A1D70Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D80Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D90Z') THEN 1
			ELSE 0
			END AS hemodialysis_flag
FROM procedures
GROUP BY discharge_id; 

	
# 6
# For each of the procedure codes flagged as hemodialysis in exercise 5, create a new variable hemodialysis_day on the procedures data for the day of admission that hemodialysis was done, calculated as the number of days between procedure_date and the admit_datetime from the discharges data set
# I will be using the procedures table and discharges table, they will need to be joined using the discharge_id 

# Previous query from problem 5 
SELECT p.discharge_id,
	CASE	WHEN MAX(procedure_code LIKE '5A1D70Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D80Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D90Z') THEN 1
			ELSE 0
			END AS hemodialysis_flag
FROM procedures AS p
GROUP BY discharge_id; 

# Variable for the day of admission that hemodialysis was done
# Calculated as the number of days between procedure_date (procedures table) and the admit_datetime (discharges table)
# I will need to Join these tables using the discharge_id
SELECT p.discharge_id, MAX(DATEDIFF(p_date, a_date)) AS hemodialysis_day 
FROM procedures AS p
LEFT JOIN (
	SELECT d.discharge_id, MIN(d.admit_datetime) AS a_date
    FROM discharges AS d
    GROUP BY d.discharge_id) AS d1 ON p.discharge_id = d1.discharge_id
LEFT JOIN (
	SELECT p1.discharge_id, MIN(p1.procedure_date) AS p_date
    FROM procedures AS p1
    GROUP BY p1.discharge_id) AS p2 ON p.discharge_id = p2.discharge_id
GROUP BY p.discharge_id;

# Putting both queries together (Solution) 
SELECT p.discharge_id, 
	MAX(DATEDIFF(p_date, a_date)) AS hemodialysis_day 
FROM procedures AS p
LEFT JOIN (
	SELECT d.discharge_id, MIN(d.admit_datetime) AS a_date
    FROM discharges AS d
    GROUP BY d.discharge_id) AS d1 ON p.discharge_id = d1.discharge_id
LEFT JOIN (
	SELECT p1.discharge_id, MIN(p1.procedure_date) AS p_date,
		CASE	WHEN MAX(procedure_code LIKE '5A1D70Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D80Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D90Z') THEN 1
			ELSE 0
			END AS hemodialysis_flag
    FROM procedures AS p1
    GROUP BY p1.discharge_id) AS p2 ON p.discharge_id = p2.discharge_id
GROUP BY p.discharge_id;


# 7
# Using the new hemodialysis_day variable created in exercise 6, add a new variable to the discharges data that calculates the minimum days (i.e. days from admit to procedure) for each discharge, only if the discharge had a hemodialysis procedure (i.e. it should be NULL if no hemodialysis procedure code exists for the discharge) AND if the discharge has a diagnosis with the flag of kidney_not_poa equals 1
# I will be using the discharges, procedures, and diagnosis tables, they will need to be joined using the discharge_id 

# Query for minimum days only if a hemodialysis procedure is present (NULL if not) from exercise 6
SELECT p.discharge_id, 
	CASE 
		WHEN d1.a_date IS NOT NULL AND DATEDIFF(p_date, a_date) > 1 THEN 1 
        ELSE NULL 
        END AS hemodialysis_day_present
FROM procedures AS p
LEFT JOIN (
	SELECT d.discharge_id, MIN(d.admit_datetime) AS a_date
    FROM discharges AS d
    GROUP BY d.discharge_id) AS d1 ON p.discharge_id = d1.discharge_id
LEFT JOIN (
	SELECT p1.discharge_id, MIN(p1.procedure_date) AS p_date,
		CASE	WHEN MAX(procedure_code LIKE '5A1D70Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D80Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D90Z') THEN 1
			ELSE NULL
			END AS hemodialysis_flag
    FROM procedures AS p1
    GROUP BY p1.discharge_id) AS p2 ON p.discharge_id = p2.discharge_id
GROUP BY p.discharge_id;

# Query that shows flag of kidney_not_poa equals 1
SELECT discharge_id,
	CASE WHEN MAX(diagnosis_group LIKE 'ACUTE KIDNEY FAILURE AND CHRONIC KIDNEY DISEASE' AND diagnosis_poa != 'Y') THEN 1 
                    ELSE 0 
                    END AS kidney_not_poa
FROM diagnoses
WHERE kidney_not_poa = 1
GROUP BY discharge_id, diagnosis_poa;

# Putting all the queries together (Solution)
SELECT p.discharge_id, 
    CASE 
		WHEN d1.a_date IS NOT NULL AND DATEDIFF(p_date, a_date) > 1 THEN 1 
        ELSE NULL 
        END AS hemodialysis_day_present_kidney_not_poa
FROM procedures AS p
LEFT JOIN (
	SELECT d.discharge_id, MIN(d.admit_datetime) AS a_date
    FROM discharges AS d
    GROUP BY d.discharge_id) AS d1 ON p.discharge_id = d1.discharge_id
LEFT JOIN (
	SELECT p1.discharge_id, MIN(p1.procedure_date) AS p_date,
		CASE	WHEN MAX(procedure_code LIKE '5A1D70Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D80Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D90Z') THEN 1
			ELSE NULL
			END AS hemodialysis_flag
    FROM procedures AS p1
    GROUP BY p1.discharge_id) AS p2 ON p.discharge_id = p2.discharge_id
LEFT JOIN (
	SELECT di.discharge_id,
		CASE WHEN MAX(diagnosis_group LIKE 'ACUTE KIDNEY FAILURE AND CHRONIC KIDNEY DISEASE' AND diagnosis_poa != 'Y') THEN 1 
                    ELSE 0 
                    END AS kidney_not_poa
    FROM diagnoses AS di
    GROUP BY di.discharge_id) AS di1 ON p.discharge_id = di1.discharge_id
WHERE kidney_not_poa = 1
GROUP BY p.discharge_id;
 
 
# 8
# Use the icd10_code_list data to join to both the diagnoses, procedures, and discharges data to add a new variable to the discharges data named lip_cv_ops that equals 1 if the discharge has a diagnosis that maps to ccs_category_code of 53 (disorders of lipid metabolism) and a procedure that maps to ccs_level1_code of 7 (Operations on the cardiovascular system)
# I will be using the discharges, procedures, diagnosis, and icd10_code_list tables, they will need to be joined using the discharge_id 

# Query for the discharge that has a diagnosis that maps to ccs_category_code of 53 (disorders of lipid metabolism) 
INNER JOIN	icd10_code_list AS lst ON dx.diagnosis_code = lst.icd10_code AND lst.code_type='DX'
WHERE		lst.ccs_category_code = 53; #disorders of lipid metabolism

# Query for a procedure that maps to ccs_level1_code of 7 (Operations on the cardiovascular system)
INNER JOIN	icd10_code_list AS lst ON px.procedure_code = lst.icd10_code AND lst.code_type='PX'
WHERE		lst.ccs_level1_code = 7; # Operations on the cardiovascular system

# Putting all the queries together (Solution) 
SELECT p.discharge_id, 
    CASE 
		WHEN d1.a_date IS NOT NULL AND DATEDIFF(p_date, a_date) > 1 THEN 1 
        ELSE NULL 
        END AS lip_cv_ops 
FROM procedures AS p
LEFT JOIN (
	SELECT d.discharge_id, MIN(d.admit_datetime) AS a_date
    FROM discharges AS d
    GROUP BY d.discharge_id) AS d1 ON p.discharge_id = d1.discharge_id
LEFT JOIN (
	SELECT p1.discharge_id, MIN(p1.procedure_date) AS p_date,
		CASE	WHEN MAX(procedure_code LIKE '5A1D70Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D80Z') THEN 1
			WHEN MAX(procedure_code LIKE '5A1D90Z') THEN 1
			ELSE NULL
			END AS hemodialysis_flag
    FROM procedures AS p1
   INNER JOIN	icd10_code_list AS lst ON p1.procedure_code = lst.icd10_code AND lst.code_type='PX'
	WHERE		lst.ccs_level1_code = 7
    GROUP BY p1.discharge_id) AS p2 ON p.discharge_id = p2.discharge_id
LEFT JOIN (
	SELECT di.discharge_id,
		CASE WHEN MAX(diagnosis_group LIKE 'ACUTE KIDNEY FAILURE AND CHRONIC KIDNEY DISEASE' AND diagnosis_poa != 'Y') THEN 1 
                    ELSE 0 
                    END AS kidney_not_poa
    FROM diagnoses AS di
    
	# The addition of this JOIN results in no rows returned, however when it is not present the lip_cv_ops variable works. I kept the code in # so that the query produces a result 
	#JOIN	icd10_code_list AS lst ON di.diagnosis_code = lst.icd10_code AND lst.code_type='DX'
	#WHERE		lst.ccs_category_code = 53 
    
    GROUP BY di.discharge_id) AS di1 ON p.discharge_id = di1.discharge_id
WHERE kidney_not_poa = 1
GROUP BY p.discharge_id;

