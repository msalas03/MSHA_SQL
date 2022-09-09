-- Final MYSQL Exercise -- 
-- Utilizing the healthcare dataset I will be to using the diagnoses and discharges tables to investigate patient discharges --

-- Looking at the tables of interest 
DESC healthcare.diagnoses; -- description of the diagnoses table -- 
DESC healthcare.discharges; -- description of the discharges table -- 

-- 1. The diagnosis that are most common for males and females (diagnosis_desc and diagnosis_code)
-- Males 
SELECT gender, MAX(diagnosis_desc), MAX(diagnosis_code) -- selecting the gender column, calculating the highest value in the diagnosis_desc column, and the highest value in the diagnosis_code column -- 
FROM healthcare.discharges -- schema.table containing the gender column -- 
	INNER JOIN healthcare.diagnoses -- using an inner join to retrieve the diagnosis_desc, and diagnosis_code columns -- 
    ON discharges.discharge_id = diagnoses.discharge_id -- joining the discharges and diagnoses columns using the discharge_id -- 
WHERE gender = 'M' -- filter condition, I want only the male gender to be shown -- 
GROUP BY gender; -- grouping the results by gender -- 
-- 1 row returned
-- Most common diagnosis_desc is Zoster without complications, most common diagnosis_code is Z99.89

-- Next I will find the count for diagnosis_desc Zoster without complications, and diagnosis_code Z99.89 for the males 
SELECT gender, diagnosis_desc -- gender and diagnosis_desc are the columns I am selecting -- 
FROM healthcare.discharges -- schema.table where the gender column is located -- 
	INNER JOIN healthcare.diagnoses -- using an inner join to retrieve the diagnosis_desc column -- 
    ON discharges.discharge_id = diagnoses.discharge_id -- joining the discharges and diagnoses tables using the discharge_id -- 
WHERE gender = 'M' AND diagnosis_desc = 'Zoster without complications' -- filter condition, only the male gender and the diagnosis_desc Zoster without complications are shown -- 
ORDER BY gender; -- ordering the results by gender -- 
-- 6 rows returned 
SELECT gender, diagnosis_code -- gender and diagnosis_code are the columns I am selecting -- 
FROM healthcare.discharges -- schema.table where the gender column is located -- 
	INNER JOIN healthcare.diagnoses -- using an inner join to retrieve the diagnosis_code column -- 
    ON discharges.discharge_id = diagnoses.discharge_id -- joining the discharges and diagnoses tables using the discharge_id -- 
WHERE gender = 'M' AND diagnosis_code = 'Z99.89' -- filter condition, only the male gender and the diagnosis_code Z99.89 are shown -- 
ORDER BY gender; -- ordering the results by gender -- 
-- 2 rows returned 

-- Females 
SELECT gender, MAX(diagnosis_desc), MAX(diagnosis_code) -- selecting the gender column, calculating the highest value in the diagnosis_desc column, and the highest value in the diagnosis_code column -- 
FROM healthcare.discharges -- schema.table containing the gender column -- 
	INNER JOIN healthcare.diagnoses -- using an inner join to retrieve the diagnosis_desc, and diagnosis_code columns -- 
    ON discharges.discharge_id = diagnoses.discharge_id -- joining the discharges and diagnoses columns using the discharge_id -- 
WHERE gender = 'F' -- filter condition, I want only the female gender to be shown -- 
GROUP BY gender; -- grouping the results by gender -- 
-- 1 row returned
-- Most common diagnosis_desc is Zoster without complications, most common diagnosis_code is Z99.89 (same reaults as male)

-- Next I will find the count for diagnosis_desc is Zoster without complications, diagnosis_code Z99.89 
SELECT gender, diagnosis_desc -- gender and diagnosis_desc are the columns I am selecting -- 
FROM healthcare.discharges -- schema.table where the gender column is located -- 
	INNER JOIN healthcare.diagnoses -- using an inner join to retrieve the diagnosis_desc column -- 
    ON discharges.discharge_id = diagnoses.discharge_id -- joining the discharges and diagnoses tables using the discharge_id -- 
WHERE gender = 'F' AND diagnosis_desc = 'Zoster without complications' -- filter condition, only the female gender and the diagnosis_desc Zoster without complications are shown -- 
ORDER BY gender; -- ordering the results by gender -- 
-- 11 rows returned 
SELECT gender, diagnosis_code -- gender and diagnosis_code are the columns I am selecting -- 
FROM healthcare.discharges -- schema.table where the gender column is located -- 
	INNER JOIN healthcare.diagnoses -- using an inner join to retrieve the diagnosis_code column -- 
    ON discharges.discharge_id = diagnoses.discharge_id -- joining the discharges and diagnoses tables using the discharge_id -- 
WHERE gender = 'F' AND diagnosis_code = 'Z99.89' -- filter condition, only the female gender and the diagnosis_code Z99.89 are shown -- 
ORDER BY gender; -- ordering the results by gender -- 
-- 2 rows returned 


-- 2. Counting the number of age groups for discharges: Infants, Children, Teens, Adults, Older Adults (I will be using the age_at_admit column making the assumption the patient is the same age when they admit as when they discharge)
SELECT
    sum(CASE WHEN age_at_admit < '1' THEN 1 ELSE 0 END) 'Infants', -- conditional that if the age_at_admit is < 1, then add 1, if not then add a zero -- 
    sum(CASE WHEN age_at_admit BETWEEN '1' AND '11' THEN 1 ELSE 0 END) 'Children', -- conditional that if the age_at_admit is between 1 and 11, then add 1, if not then add a zero -- 
    sum(CASE WHEN age_at_admit BETWEEN '12' AND '17' THEN 1 ELSE 0 END) 'Teens', -- conditional that if the age_at_admit is between 12 and 17, then add 1, if not then add a zero -- 
    sum(CASE WHEN age_at_admit BETWEEN '18' AND '64' THEN 1 ELSE 0 END) 'Adults', -- conditional that if the age_at_admit is between 18 and 64, then add 1, if not then add a zero -- 
    sum(CASE WHEN age_at_admit > '65' THEN 1 ELSE 0 END) 'Older Adults' -- conditional that if the age_at_admit is greater than 65, then add 1, if not then add a zero -- 
FROM healthcare.discharges; -- schema.table containing the age_at_admit column -- 
-- 1 row returned 
-- 4 Infants, 0 Children, 0 Teens, 4108 Adults, 4118 Older Adults 


-- 3. The specialty provider that has the most discharges (discharge_provider_specialty)
SELECT discharge_provider_specialty, -- column of interest is the discharge_provider_specialty --
  COUNT(discharge_provider_specialty) AS occurances -- counting the most discharges for the discharge_provider_specialty per occurance -- 
FROM healthcare.discharges -- schema.table where the discharge_provider_specialty column is located -- 
GROUP BY discharge_provider_specialty -- grouping the results by the discharge_provider_specialty -- 
ORDER BY occurances DESC -- ordering the occurances is descending order -- 
LIMIT 0, 1; -- limiting how many rows are returned in the query -- 
-- 1 row returned 
-- Hospital Medicine with 2833 occurances 


-- 4. Most common insurance types (insurance_type)
SELECT insurance_type, -- insurance_type is the column I am selecting -- 
	COUNT(insurance_type) Total -- counting the number of insurance types and their total -- 
FROM healthcare.discharges -- schema.table where insurance_type column is located -- 
GROUP BY insurance_type -- grouping the results by the insruance type -- 
ORDER BY Total DESC; -- ordering the total in descending order -- 
-- 9 rows returned 
-- Medicare 4220, BCBS 1428, Medicare Advantage 895, Medicaid Replacement 848, Commercial/Managed Care 752, Self-pay 148, Medicaid 126, Pending Medicaid 56, Worker's Comp 18
