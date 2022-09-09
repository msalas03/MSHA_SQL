-- 412 Final Project -- 
-- Assume the analytical objective is to predict the existence of cardiovascular disease (which can take many forms) in the diabetic patients in our datasets. 
-- The final analytical dataset produced should be at the discharge level, meaning the unique identifier of the final dataset should be discharge_id. 
-- All of the columns in the dataset should be features that may be relevant and correlated to the analytical objective 
-- of identifying cardiovascular disease. 
-- That could be from the diagnosis, procedure, lab results, medication administration, or echocardiogram reports data we have analyzed so far in the course.

-- Chosing the schema of the assignment 
USE msha_nm;

-- Exploring the data
SELECT * FROM diagnoses LIMIT 200;
SELECT * FROM discharges LIMIT 200;
SELECT * FROM echo_rpts LIMIT 200;
SELECT * FROM icd10_code_list LIMIT 200;
SELECT * FROM labs LIMIT 200;
SELECT * FROM meds LIMIT 200;
SELECT * FROM procedures LIMIT 200;

-- Information for features (References) 
-- National Institute of Diabetes and Digestive and Kidney Disease. (n.d.). Diabetes, Heart Disease, &amp; Stroke. National Institute of Diabetes and Digestive and Kidney Diseases. Retrieved November 29, 2021, from https://www.niddk.nih.gov/health-information/diabetes/overview/preventing-problems/heart-disease-stroke. 


# Feature 1 
# Hyoerglycemia can damage arteries and the nerves of the heart and the circulatory system. 
# Over time this damage can lead to heart disease.
# Feature one will categorize glucose levels of 1-3 in acccordance to glucose reading: normal (80-100), impared glucose (101-125), and diabetic (126+)
# Table utilized: labs 
SELECT discharge_id,
	CASE WHEN result_value_num BETWEEN 80 AND 100 THEN '1: Normal'
		 WHEN result_value_num BETWEEN 101 AND 125 THEN '2: Impared Glucose'
		 WHEN result_value_num > 126 THEN '3: Diabetic'
		 ELSE NULL 
         END AS Glucose_cat
FROM labs
WHERE component_name LIKE "%GLUCOSE%";

# Feature 2 
# People with diabetes tend to develop heart disease at a younger age than people without it. 
# Feature two will categorize the age of the patient, younger age will be labeled as at risk to develop heart disease 
# For patients with the dx of Diabetes Mellitus
# Tables utilized: discharges and diagnoses 
SELECT d.discharge_id,
	CASE WHEN age_at_admit < 14 THEN 'Child: At Risk'
		 WHEN age_at_admit BETWEEN 15 AND 24 THEN 'Youth: At Risk'
		 WHEN age_at_admit BETWEEN 25 AND 64 THEN 'Adult: Monitor'
         WHEN age_at_admit > 65 THEN 'Senior: Monitor'
		 ELSE NULL 
         END AS Heart_disease_age
FROM discharges AS d
LEFT JOIN (  
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON d.discharge_id = dx.discharge_id;

# Feature 3 
# The risk for heart disease is greater if you are male, rather than female
# Feature three will flag the gender: Male for at risk of developing heart diasease 
# For patients with the dx of Diabetes Mellitus 
# Tables utilied: discharges and diagnoses
SELECT d.discharge_id, 
	IF (gender LIKE 'M', 1, 0) AS Gender_risk_male 
FROM discharges AS d
LEFT JOIN (  
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON d.discharge_id = dx.discharge_id;

# Feature 4 
# Hypertension can damage heart, kidneys, eyes, producing heart attack, stroke, kidney failure, blindness, etc.
# Lisinopril is one of the most commonly used medications to manage blood pressure
# Feature four will be creating a flag of 1 for patients taking Lisinopril that have the diagnoses of Diabetes Mellitus 
# Tables utilized: meds and diagnoses 
SELECT m.discharge_id,
	IF(generic_name LIKE '%lisinopril%', 1, 0) AS High_bp_med_flag
FROM meds AS m
LEFT JOIN (  
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON m.discharge_id = dx.discharge_id;

# Feature 5 
# Heart disease is closely linked with chronic kidney disease, a condition in which kidneys cannot get rid of waste products. 
# Having diabetes is a risk factor for developing kidney disease, which affects about 40% of people with diabetes. 
# Feature 5 will create a flag for patients that have been diagnosed with Diabetes Mellitus AND Acute Kidney Failure and CKD
# Tables utililzed: diagnoses and diagnoses 
SELECT d.discharge_id, 
	CASE WHEN diagnosis_group LIKE 'ACUTE KIDNEY FAILURE AND CHRONIC KIDNEY DISEASE' THEN '1'
    ELSE NULL
    END AS CKD_diabetes_flag 
FROM diagnoses AS d
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON d.discharge_id = dx.discharge_id;

# Feature 6  
# Buildup in cholesterol levels in arteries can result in heart attack or stroke.
# Patients over the age of 40 may require drugs to assist in lowering their cholesterol levels
# Statins are the most commonly family of drug used 
# Feature six will categorize patients over the age of 40, who are taking a Statin medication as at risk for heart attack/stroke
# With the Dx of Diabetes Mellitus
# Tables utilized: discharges, meds, and diagnoses
SELECT d.discharge_id, 
	CASE WHEN age_at_admit > 40 THEN '1'
    ELSE NULL
    END AS Cholesterol_age_flag  
FROM discharges AS d
LEFT JOIN ( 
	SELECT discharge_id 
	FROM meds
	WHERE therapeutic_class LIKE '%STATIN%') AS dx ON d.discharge_id = dx.discharge_id
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx1 ON d.discharge_id = dx1.discharge_id;

# Feature 7  
# A normal blood pressure level in adults between 18-65 years of age is less than or equal to 120/80 mmHg
# Taking the information stored in the echo_rpts table, utilizing text mining to extract the Blood pressure for each corresponding discharge_id
# This is important in understanding if the patient will require prevantative measures 
# Feature seven will extract the blood pressure readings from text data 
# Table utilized: echo_rpts
SELECT discharge_id,
	REGEXP_SUBSTR(narrative, 'Blood pressure[:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]mmHg') AS bp_reading
FROM echo_rpts;

# Feature 8  
# Smoking can produce arterial vasoconstriction, leading to heart and periferal vascular disease
# Patients can take SMOKING DETERRENTS in order to assist with the processes of quitting to smoke
# Feature eight will flag a discharge_id if a smoking deterrent is being taken for patients with the dx of Diabetes Mellitus 
# Table utilized: meds 
SELECT m.discharge_id, 
	IF (therapeutic_class LIKE 'SMOKING DETERRENTS', 1, 0) AS Smoking_heart_risk 
FROM meds as m
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON m.discharge_id = dx.discharge_id;

# Feature 9 
# Elevated Creatinine levels indicate that the patient may have CKD or at risk of AKI 
# Feature 9 will flag if the Creatine levels are abnormal for patients also Dx with Diabetes Mellitus 
# Tables utilized: labs and diagnoses
SELECT l.discharge_id, 
	CASE WHEN result_value_num < ref_low THEN 'Abnormal' 
		 WHEN result_value_num > ref_high THEN 'Abnormal'
         WHEN result_value_num BETWEEN ref_low AND ref_high THEN 'Normal'
    ELSE NULL
    END AS AKI_CKD_Creatinine_flag
FROM labs AS l
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON l.discharge_id = dx.discharge_id
WHERE component_name LIKE 'CREATININE';

# Feature 10  
# Another indicator of the presernce of the dx of AKI/CKD is BUN levels 
# Feature 10 will flag if the BUN levels are abnormal for patients also Dx with Diabetes Mellitus 
# Tables utilized: labs and diagnoses
SELECT l.discharge_id, 
	CASE WHEN result_value_num < ref_low THEN 'Abnormal' 
		 WHEN result_value_num > ref_high THEN 'Abnormal'
         WHEN result_value_num BETWEEN ref_low AND ref_high THEN 'Normal'
    ELSE NULL
    END AS AKI_CKD_BUN_flag
FROM labs AS l
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON l.discharge_id = dx.discharge_id
WHERE component_name LIKE 'BUN';

# Putting all the features together
# Query 1 to combine (feature 6, 1, 7)
SELECT d.discharge_id, 
	CASE WHEN age_at_admit > 40 THEN '1'
    ELSE NULL
    END AS Cholesterol_age_flag,
    Glucose_cat,
    bp_reading
FROM discharges AS d
LEFT JOIN ( 
	SELECT discharge_id 
	FROM meds
	WHERE therapeutic_class LIKE '%STATIN%') AS dx ON d.discharge_id = dx.discharge_id
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx1 ON d.discharge_id = dx1.discharge_id
LEFT JOIN (
	SELECT discharge_id,
		CASE WHEN result_value_num BETWEEN 80 AND 100 THEN '1: Normal'
			 WHEN result_value_num BETWEEN 101 AND 125 THEN '2: Impared Glucose'
			 WHEN result_value_num > 126 THEN '3: Diabetic'
			 ELSE NULL 
			 END AS Glucose_cat
	FROM labs
	WHERE component_name LIKE "%GLUCOSE%") AS l ON d.discharge_id = l.discharge_id
LEFT JOIN (
	SELECT discharge_id,
		REGEXP_SUBSTR(narrative, 'Blood pressure[:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]mmHg') AS bp_reading
	FROM echo_rpts) AS e ON d.discharge_id = e.discharge_id;

# Query 2 to combine (feature 2 and 3)
SELECT d.discharge_id,
	CASE WHEN age_at_admit < 14 THEN 'Child: At Risk'
		 WHEN age_at_admit BETWEEN 15 AND 24 THEN 'Youth: At Risk'
		 WHEN age_at_admit BETWEEN 25 AND 64 THEN 'Adult: Monitor'
         WHEN age_at_admit > 65 THEN 'Senior: Monitor'
		 ELSE NULL 
         END AS Heart_disease_age,
		IF (gender LIKE 'M', 1, 0) AS Gender_risk_male 
FROM discharges AS d
LEFT JOIN (  
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON d.discharge_id = dx.discharge_id;

# Query 3 to combine (feature 4, 8) 
SELECT m.discharge_id,
	IF(generic_name LIKE '%lisinopril%', 1, 0) AS High_bp_med_flag,
    IF (therapeutic_class LIKE 'SMOKING DETERRENTS', 1, 0) AS Smoking_heart_risk 
FROM meds AS m
LEFT JOIN (  
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON m.discharge_id = dx.discharge_id;

# Query 4 to combine (feature 5)
SELECT d.discharge_id, 
	CASE WHEN diagnosis_group LIKE 'ACUTE KIDNEY FAILURE AND CHRONIC KIDNEY DISEASE' THEN '1'
    ELSE NULL
    END AS CKD_diabetes_flag 
FROM diagnoses AS d
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON d.discharge_id = dx.discharge_id;

# Query 5 to combine (feature 9)
SELECT l.discharge_id, 
	CASE WHEN result_value_num < ref_low THEN 'Abnormal' 
		 WHEN result_value_num > ref_high THEN 'Abnormal'
         WHEN result_value_num BETWEEN ref_low AND ref_high THEN 'Normal'
    ELSE NULL
    END AS AKI_CKD_Creatinine_flag
FROM labs AS l
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON l.discharge_id = dx.discharge_id
WHERE component_name LIKE 'CREATININE';

# Query 6 to combine (feature 10)
SELECT l.discharge_id, 
	CASE WHEN result_value_num < ref_low THEN 'Abnormal' 
		 WHEN result_value_num > ref_high THEN 'Abnormal'
         WHEN result_value_num BETWEEN ref_low AND ref_high THEN 'Normal'
    ELSE NULL
    END AS AKI_CKD_BUN_flag
FROM labs AS l
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON l.discharge_id = dx.discharge_id
WHERE component_name LIKE 'BUN';

# Combining the queries by creating temp tables for each necessary data set
CREATE TEMPORARY TABLE feature617
SELECT d.discharge_id, 
	CASE WHEN age_at_admit > 40 THEN '1'
    ELSE NULL
    END AS Cholesterol_age_flag,
    Glucose_cat,
    bp_reading
FROM discharges AS d
LEFT JOIN ( 
	SELECT discharge_id 
	FROM meds
	WHERE therapeutic_class LIKE '%STATIN%') AS dx ON d.discharge_id = dx.discharge_id
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx1 ON d.discharge_id = dx1.discharge_id
LEFT JOIN (
	SELECT discharge_id,
		CASE WHEN result_value_num BETWEEN 80 AND 100 THEN '1: Normal'
			 WHEN result_value_num BETWEEN 101 AND 125 THEN '2: Impared Glucose'
			 WHEN result_value_num > 126 THEN '3: Diabetic'
			 ELSE NULL 
			 END AS Glucose_cat
	FROM labs
	WHERE component_name LIKE "%GLUCOSE%") AS l ON d.discharge_id = l.discharge_id
LEFT JOIN (
	SELECT discharge_id,
		REGEXP_SUBSTR(narrative, 'Blood pressure[:blank:]*[:digit:]*[:punct:][:digit:]*[:blank:]mmHg') AS bp_reading
	FROM echo_rpts) AS e ON d.discharge_id = e.discharge_id;

CREATE TEMPORARY TABLE feature23 
SELECT d.discharge_id,
	CASE WHEN age_at_admit < 14 THEN 'Child: At Risk'
		 WHEN age_at_admit BETWEEN 15 AND 24 THEN 'Youth: At Risk'
		 WHEN age_at_admit BETWEEN 25 AND 64 THEN 'Adult: Monitor'
         WHEN age_at_admit > 65 THEN 'Senior: Monitor'
		 ELSE NULL 
         END AS Heart_disease_age,
		IF (gender LIKE 'M', 1, 0) AS Gender_risk_male 
FROM discharges AS d
LEFT JOIN (  
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON d.discharge_id = dx.discharge_id;
    
CREATE TEMPORARY TABLE feature48
SELECT m.discharge_id,
	IF(generic_name LIKE '%lisinopril%', 1, 0) AS High_bp_med_flag,
    IF (therapeutic_class LIKE 'SMOKING DETERRENTS', 1, 0) AS Smoking_heart_risk 
FROM meds AS m
LEFT JOIN (  
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON m.discharge_id = dx.discharge_id;
    
CREATE TEMPORARY TABLE feature5
SELECT d.discharge_id, 
	CASE WHEN diagnosis_group LIKE 'ACUTE KIDNEY FAILURE AND CHRONIC KIDNEY DISEASE' THEN '1'
    ELSE NULL
    END AS CKD_diabetes_flag 
FROM diagnoses AS d
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON d.discharge_id = dx.discharge_id;
    
CREATE TEMPORARY TABLE feature9
SELECT l.discharge_id, 
	CASE WHEN result_value_num < ref_low THEN 'Abnormal' 
		 WHEN result_value_num > ref_high THEN 'Abnormal'
         WHEN result_value_num BETWEEN ref_low AND ref_high THEN 'Normal'
    ELSE NULL
    END AS AKI_CKD_Creatinine_flag
FROM labs AS l
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON l.discharge_id = dx.discharge_id
WHERE component_name LIKE 'CREATININE';

CREATE TEMPORARY TABLE feature10
SELECT l.discharge_id, 
	CASE WHEN result_value_num < ref_low THEN 'Abnormal' 
		 WHEN result_value_num > ref_high THEN 'Abnormal'
         WHEN result_value_num BETWEEN ref_low AND ref_high THEN 'Normal'
    ELSE NULL
    END AS AKI_CKD_BUN_flag
FROM labs AS l
LEFT JOIN ( 
	SELECT discharge_id 
	FROM diagnoses
	WHERE diagnosis_group LIKE '%DIABETES MELLITUS%') AS dx ON l.discharge_id = dx.discharge_id
WHERE component_name LIKE 'BUN';

# Final query
USE msha_nm;
SELECT 		d.discharge_id, 
			feature617.Cholesterol_age_flag, feature617.Glucose_cat, feature617.bp_reading,
		 	feature23.Heart_disease_age, feature23.Gender_risk_male,
			feature48.High_bp_med_flag, feature48.Smoking_heart_risk, 
        	feature5.CKD_diabetes_flag,
        	feature9.AKI_CKD_Creatinine_flag,
			feature10.AKI_CKD_BUN_flag
FROM	discharges AS d
LEFT JOIN	feature617 ON d.discharge_id = feature617.discharge_id
LEFT JOIN	feature23 ON d.discharge_id = feature23.discharge_id
LEFT JOIN	feature48 ON d.discharge_id = feature48.discharge_id
LEFT JOIN	feature5 ON d.discharge_id = feature5.discharge_id
LEFT JOIN	feature9 ON d.discharge_id = feature9.discharge_id
LEFT JOIN	feature10 ON d.discharge_id = feature10.discharge_id;