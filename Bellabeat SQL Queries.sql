-- User Verification 
-- Checked for No.of participants by counting number of distinct Ids in each dataset.

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM dbo.dailyActivity_merged

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM dbo.heartrate_seconds_merged

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM dbo.hourlyCalories_merged

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM dbo.hourlyIntensities_merged

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM dbo.hourlySteps_merged

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM dbo.sleepDay_merged

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM dbo.weightLogInfo_merged

-- User Insights 
-- User Usage of Wearables 
-- Checking how many days each of the users wore/used the FitBit tracker:

SELECT Id,
COUNT(Id) AS Total_Logged_Uses
FROM dbo.dailyActivity_merged
GROUP BY Id

-- Further analysis on users by how much they wore their FitBit Fitness Tracker by dividing them into 3 categories

-- Active User - wore their tracker for 25-31 days
-- Moderate User - wore their tracker for 15-24 days
-- Light User - wore their tracker for 0 to 14 days

SELECT Id,
COUNT (Id) AS Total_Logged_Uses,
CASE
WHEN COUNT (Id) BETWEEN 25 AND 31 THEN 'Active User'
WHEN COUNT (Id) BETWEEN 15 AND 24 THEN 'Moderate User'
WHEN COUNT (Id) BETWEEN 0 AND 14 THEN 'Light User'
END Fitbit_Usage_Type
FROM dbo.dailyActivity_merged
GROUP BY Id

-- User Data Analysis
-- Reviewing the MIN, MAX, & AVG of total steps, total distance, calories and activity levels by Id.

SELECT Id,
MIN(TotalSteps) AS Min_Total_Steps,
MAX(TotalSteps) AS Max_Total_Steps, 
AVG(TotalSteps) AS Avg_Total_Stpes,
MIN(TotalDistance) AS Min_Total_Distance, 
MAX(TotalDistance) AS Max_Total_Distance, 
AVG(TotalDistance) AS Avg_Total_Distance,
MIN(Calories) AS Min_Total_Calories,
MAX(Calories) AS Max_Total_Calories,
AVG(Calories) AS Avg_Total_Calories,
MIN(VeryActiveMinutes) AS Min_Very_Active_Minutes,
MAX(VeryActiveMinutes) AS Max_Very_Active_Minutes,
AVG(VeryActiveMinutes) AS Avg_Very_Active_Minutes,
MIN(FairlyActiveMinutes) AS Min_Fairly_Active_Minutes,
MAX(FairlyActiveMinutes) AS Max_Fairly_Active_Minutes,
AVG(FairlyActiveMinutes) AS Avg_Fairly_Active_Minutes,
MIN(LightlyActiveMinutes) AS Min_Lightly_Active_Minutes,
MAX(LightlyActiveMinutes) AS Max_Lightly_Active_Minutes,
AVG(LightlyActiveMinutes) AS Avg_Lightly_Active_Minutes,
MIN(SedentaryMinutes) AS Min_Sedentary_Minutes,
MAX(SedentaryMinutes) AS Max_Sedentary_Minutes,
AVG(SedentaryMinutes) AS Avg_Sedentary_Minutes
FROM dbo.dailyActivity_merged
Group BY Id


-- Focusing on the AVG results only

SELECT Id, 
avg(VeryActiveMinutes) AS Avg_Very_Active_Minutes,
avg(FairlyActiveMinutes) AS Avg_Fairly_Active_Minutes,
avg(LightlyActiveMinutes) AS Avg_Lightly_Active_Minutes,
avg(SedentaryMinutes) AS Avg_Sedentary_Minutes
FROM dbo.dailyActivity_merged
GROUP BY Id


-- Checking the sum of the average minutes of different active minutes against CDC activity recommendations

SELECT Id, 
avg(VeryActiveMinutes) + avg(FairlyActiveMinutes) + avg(LightlyActiveMinutes) AS Total_Avg_Active_Minutes,
CASE 
WHEN avg(VeryActiveMinutes) + avg(FairlyActiveMinutes) + avg(LightlyActiveMinutes) >= 150 THEN 'Meets CDC Recommendation'
WHEN avg(VeryActiveMinutes) + avg(FairlyActiveMinutes) + avg(LightlyActiveMinutes) <150 THEN 'Does Not Meet CDC Recommendation'
END CDC_Recommendations
FROM dbo.dailyActivity_merged
GROUP BY Id


--- User Types by Total Steps
--- Breaking down activity level by steps into five categories:
-- Inactive -- less than 5,000 steps per day
-- Low Active User -- 5,000 to 7,499 steps
-- Average (somewhat active) -- ranges from 7,500 to 9,999 steps per day
-- Active User -- 10,000 to 12,499 steps
-- Very Active -- more than 12,500 steps per day

SELECT Id,
avg(TotalSteps) AS Avg_Total_Steps,
CASE
WHEN avg(TotalSteps) < 5000 THEN 'Inactive'
WHEN avg(TotalSteps) BETWEEN 5000 AND 7499 THEN 'Low Active User'
WHEN avg(TotalSteps) BETWEEN 7500 AND 9999 THEN 'Average Active User'
WHEN avg(TotalSteps) BETWEEN 10000 AND 12499 THEN 'Active User'
WHEN avg(TotalSteps) >= 12500 THEN 'Very Active User'
END User_Type
FROM dbo.dailyActivity_merged
GROUP BY Id


-- Checking Calories, Steps & Active Minutes by ID

SELECT Id, 
Sum(TotalSteps) AS Sum_total_steps,
SUM(Calories) AS Sum_Calories, 
SUM(VeryActiveMinutes + FairlyActiveMinutes) AS Sum_Active_Minutes
FROM dbo.dailyActivity_merged
GROUP BY Id


-- Total Steps by Hour 
-- Having a look at Total Steps per Hour to see what time of day our users were most active.

SELECT 
ActivityHour,
SUM(StepTotal) AS Total_Steps_By_Hour
FROM dbo.hourlySteps_merged
GROUP BY ActivityHour
ORDER BY Total_Steps_By_Hour DESC


-- Checking Sleep habits of users and comparing it to activity level 

SELECT 
SleepDay,
SUM(TotalMinutesAsleep) AS Total_Minutes_Asleep
FROM dbo.sleepDay_merged
WHERE SleepDay IS NOT NULL
GROUP BY SleepDay;

SELECT a.Id,
avg(a.TotalSteps) AS AvgTotalSteps,
avg(a.Calories) AS AvgCalories,
avg(s.TotalMinutesAsleep) AS AvgTotalMinutesAsleep
FROM dbo.dailyActivity_merged AS a
INNER JOIN dbo.sleepDay_merged AS s ON a.Id=s.Id
GROUP BY a.Id