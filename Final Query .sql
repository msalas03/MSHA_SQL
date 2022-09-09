-- Final Query --
-- Temp Tables -- 

# Final utilizing temp tables in its own query for running  

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