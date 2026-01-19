CREATE DATABASE healthcare_stroke

--DEMOGRAPHICS & PATIENTS OVERVIEW--
--How many patients were admitted?
SELECT COUNT(*) id
FROM [dbo].[healthcare_stroke]

--what is the age and gender distribution of patients at highest risk of stroke--
SELECT gender,
CASE WHEN age <= 17 THEN 'Children'
	 WHEN age BETWEEN 18 AND 35 THEN 'Adult'
	 WHEN age BETWEEN 36 AND 53 THEN 'Elders' 
	 ELSE 'Seniors' END AS AgeGroup,
COUNT(*) AS StrokePatients
FROM [dbo].[healthcare_stroke]
WHERE stroke = 'yes'
GROUP BY gender,
	 CASE WHEN age <= 17 THEN 'Children'
	 WHEN age BETWEEN 18 AND 35 THEN 'Adult'
	 WHEN age BETWEEN 36 AND 53 THEN 'Elders' 
	 ELSE 'Seniors' END

--Does marital status influence stroke occurance among patients?--
SELECT ever_married, COUNT(*) as TotalPatients,
SUM(CASE WHEN stroke = 'Yes' THEN 1 ELSE 0 END) as StrokeCases,
CAST(SUM(CASE WHEN stroke = 'Yes' THEN 1 ELSE 0 END) *100/COUNT(*) AS DECIMAL (5,2)) AS PercentageStrokeCases
FROM [dbo].[healthcare_stroke]
GROUP BY ever_married

--Are stroke cases more prevalent in urban or rural populations--
SELECT residence_type, COUNT(*) AS TotalPatients, 
SUM(CASE WHEN stroke = 'yes' THEN 1 ELSE 0 END) AS stroke,
CAST(SUM(CASE WHEN stroke = 'yes' THEN 1 ELSE 0 END) *100/COUNT(*) AS DECIMAL (4,2)) PercentageStrokeCases
FROM [dbo].[healthcare_stroke]
GROUP BY residence_type

--what work types are associated with higher stroke risk?--
SELECT work_type, COUNT(*) AS TotalPatients, 
SUM(CASE WHEN stroke = 'yes' THEN 1 ELSE 0 END) AS StrokePatients,
CAST(SUM(CASE WHEN stroke = 'yes' THEN 1 ELSE 0 END) *100/COUNT(*) AS DECIMAL (3,1)) AS PercentageStroke
FROM [dbo].[healthcare_stroke]
GROUP BY work_type

--Are children or elderly populations more vulnerable to specific health conditions?--
SELECT CASE WHEN age <= 18 THEN 'Children' ELSE 'Elderly' END AS Population,
COUNT(*) AS TotalPatients,
SUM(CASE WHEN stroke = 'yes' THEN 1 else 0 end) as stroke,
SUM(CASE WHEN heart_disease ='yes' then 1 else 0 end) as heartDisease,
SUM(CASE WHEN hypertension = 'yes' then 1 else 0 end) as hypertention 
FROM [dbo].[healthcare_stroke]
GROUP BY CASE WHEN age <= 18 THEN 'Children' ELSE 'Elderly' END 
	 

--HEALTH CONDITIONS AND COMORBIDITIES--
--How does having hypertension affect the likelihood of stroke--
SELECT hypertension, COUNT(*) AS TotalPatients,
SUM(CASE WHEN stroke = 'yes' THEN 1 ELSE 0 END) AS stroke
FROM [dbo].[healthcare_stroke]
GROUP BY hypertension

--How does heart disease influence stroke risk in different age groups--
SELECT 
CASE WHEN age <= 19 THEN 'Children'
	 WHEN age <=40 THEN 'Adult'
	 WHEN  age <= 61 THEN 'Elderly' ELSE 'Senior' END AS AgeGroup,
SUM(CASE WHEN heart_disease = 'yes' THEN 1 ELSE 0 END) AS HeartDisease,
SUM(CASE WHEN stroke = 'yes' AND heart_disease = 'yes'THEN 1 ELSE 0 END) AS StrokeWithHeartDisease
FROM [dbo].[healthcare_stroke]
GROUP BY 
CASE WHEN age <= 19 THEN 'Children'
	 WHEN age <=40 THEN 'Adult'
	 WHEN  age <= 61 THEN 'Elderly' ELSE 'Senior' END 

--which combination of comorbidities (hypertension/heart disease) leads to the highest stroke probabaility--
SELECT SUM(CASE WHEN stroke ='yes' and hypertension ='yes' and heart_disease ='yes' THEN 1 ELSE 0 END) AS CasesWithComorbidities,
CAST(SUM(CASE WHEN stroke ='yes' and hypertension ='yes' and heart_disease ='yes' THEN 1 ELSE 0 END)*100/COUNT(*) AS DECIMAL (4,1)) AS Percentagecomorditites
FROM [dbo].[healthcare_stroke]
WHERE hypertension = 'yes' or heart_disease ='yes'

--what is the relationship between BMI and stroke occurance--
SELECT ROUND(AVG(bmi),2) AS bmi,
	   ROUND(AVG(CASE WHEN stroke = 'no' THEN BMI END),2) AS AvgbmiNoStroke
FROM [dbo].[healthcare_stroke]

--Does high average glucose level increase stroke risk independently of other factors--
SELECT stroke, 
ROUND(AVG(avg_glucose_level),2) AS AvgGlucose
FROM [dbo].[healthcare_stroke]
GROUP BY stroke

--How many patients fall into high-risk health categories requiring urgent intervention--
SELECT COUNT(*) AS TotalPatients
FROM [dbo].[healthcare_stroke]
WHERE hypertension = 'yes'
OR heart_disease = 'yes'
OR BMI >=30
OR avg_glucose_level >=140


--LIFESTYLE & BEHAVIORIAL RISK FACTORS--
--Does smoking status significantly influence stroke risk?--
SELECT smoking_status, 
COUNT(*) AS TotalPatients,
SUM(CASE WHEN stroke = 'yes' THEN 1 ELSE 0 END) AS stroke
FROM [dbo].[healthcare_stroke]
GROUP BY smoking_status
--Which smoking categories (current, former, never) are most associated with high BMI or glucose levels--
SELECT smoking_status,
ROUND(AVG(bmi),2) AS AvgBmi,
ROUND(AVG(avg_glucose_level),2) AS AvgGlucose
FROM [dbo].[healthcare_stroke]
GROUP BY smoking_status

--Does employment type affect access to healthcare and thus stroke incidence--
SELECT work_type,
SUM(CASE WHEN stroke = 'yes' THEN 1 ELSE 0 END) AS stroke 
FROM [dbo].[healthcare_stroke]
GROUP BY work_type

--Are there correlations between sedentary work types and stroke prevalence--
SELECT work_type,
COUNT(*) AS TotalPatients,
SUM(CASE WHEN stroke = 'yes' THEN 1 ELSE 0 END) AS Stroke
FROM [dbo].[healthcare_stroke]
WHERE work_type IN  ('private', 'govt_job', 'self_employed')
GROUP BY work_type

--How does obesity prevalence differ across work types and residence areas--
SELECT work_type, residence_type,
COUNT(*) AS ObessedPatients
FROM [dbo].[healthcare_stroke]
WHERE bmi >= 30
GROUP BY work_type, Residence_type


--STROKE-SPECIFIC ANALYSIS & PREDICTION--
--which comorbidity profiles predict the highest probability of stroke--
SELECT heart_disease, hypertension,
COUNT(*) AS StrokeCases
FROM [dbo].[healthcare_stroke]
WHERE stroke = 'yes'
GROUP BY heart_disease, hypertension

--are there geographic patterns(urban vs rural) in stroke occurance--
SELECT residence_type,
COUNT(*) AS StrokeCases
FROM [dbo].[healthcare_stroke]
WHERE stroke = 'yes'
GROUP BY Residence_type

--how do BMI  and glucose levels correlate with stroke outcomes--
SELECT ROUND(AVG(bmi),2) AS BMI,
	   ROUND(AVG(avg_glucose_level),2) AS AverageGlucose
FROM [dbo].[healthcare_stroke]
WHERE stroke = 'yes'

--what is the trend of stroke cases by age group overtime--
SELECT 
CASE WHEN age <= 19 THEN 'Children'
	 WHEN age <=40 THEN 'Adult'
	 WHEN  age <= 61 THEN 'Elderly' ELSE 'Senior' END AS AgeGroup,
COUNT(*) AS TotalPatients
FROM [dbo].[healthcare_stroke]
WHERE stroke = 'yes'
GROUP BY 
CASE WHEN age <= 19 THEN 'Children'
	 WHEN age <=40 THEN 'Adult'
	 WHEN  age <= 61 THEN 'Elderly' ELSE 'Senior' END 




