--Cleaning Documentation--


--CAST dates and intensities correctly, it loaded all columns as varchar(50). Number columns need to be FLOAT (decimal) or INT
--Daily Activity Merged tables--
SELECT * FROM bellabeat..dailyActivity_merged
--Unique IDs check
SELECT 
DISTINCT Id 
FROM bellabeat..dailyActivity_merged
--33 when metadata said 30. Listed explanation in overall document.
--check length of ID
SELECT 
DISTINCT LEN(Id) AS id_length
FROM bellabeat..dailyActivity_merged
--no irregularities found
--check length of date
SELECT 
DISTINCT LEN(ActivityDate) AS date_length
FROM bellabeat..dailyActivity_merged
--no irregularities found
--check unique dates
SELECT 
DISTINCT CAST(ActivityDate AS DATE)
FROM bellabeat..dailyActivity_merged
ORDER BY CAST(ActivityDate AS DATE)
--no irregularities found, 31 unique days
--Check for irregularities in minutes, no minutes should be over 1440
SELECT CAST(sedentaryminutes AS INT)
FROM bellabeat..dailyActivity_merged
ORDER BY CAST(sedentaryminutes AS INT)
--no irregularities sedentary
SELECT CAST(LightlyActiveMinutes AS INT)
FROM bellabeat..dailyActivity_merged
ORDER BY CAST(LightlyActiveMinutes AS INT)
--no irregularities lightly active
SELECT CAST(FairlyActiveMinutes AS INT)
FROM bellabeat..dailyActivity_merged
ORDER BY CAST(FairlyActiveMinutes AS INT)
--no irregularities fairly active
SELECT CAST(VeryActiveMinutes AS INT)
FROM bellabeat..dailyActivity_merged
ORDER BY CAST(VeryActiveMinutes AS INT)
--no irregularities very active
--Check to make sure total minutes is not > 1440 minutes in a day
SELECT id, activitydate, sedentaryminutes, lightlyactiveminutes, fairlyactiveminutes, veryactiveminutes, 
CAST(sedentaryminutes AS INT) + CAST(FairlyActiveMinutes AS INT) + CAST(LightlyActiveMinutes AS INT) +
CAST(VeryActiveMinutes AS INT) AS minutes_total
FROM bellabeat..dailyActivity_merged
ORDER BY minutes_total
--some entries =1440, but many are less. Leftover minutes could be in sleep minutes instead
--check length of calories
SELECT 
DISTINCT LEN(Calories) AS date_length
FROM bellabeat..dailyActivity_merged
--2 digit calories seems unreasonable. 1 digit could be 0, which could mean the tracker wasn't used that day.
--calories with only 2 digits
SELECT * 
FROM bellabeat..dailyActivity_merged
WHERE LEN(Calories) = 2
--entries with only 2 digit calorie burn for the day match with low activity, may have not worn tracker much that day. 
--calories with only 1 digit
SELECT * 
FROM bellabeat..dailyActivity_merged
WHERE LEN(Calories) = 1
--when it is 1 character, it is 0 calories, tracker may not have been worn that day
--calories with only 3 digits
SELECT * 
FROM bellabeat..dailyActivity_merged
WHERE LEN(Calories) = 3
--LOOKING AT: overall smart device usage
SELECT id, CAST(COUNT(id) AS DECIMAL) AS id_count, CAST(COUNT(id) AS DECIMAL)/31 AS usage_percentage
FROM bellabeat..dailyActivity_merged
GROUP BY id
--ID #4057192912 has only 4 dates of data, which is ~13% usage. May drop for more accurate calculations.

--QUESTION: what should we do about data points that are so scewed that it must mean the tracker wasn't worn all day?
--Not using the tracker is valuable data. For additional data, we may need a base line of how many minutes in a day so we can choose
--the metrics for those who used the tracker consistently, who didn't, and how we know it's not just light/sedentary activity.


--Daily Intensities Merged cleaning
SELECT * FROM bellabeat..dailyIntensities_merged
--check ID 
SELECT DISTINCT(Id)
FROM bellabeat..dailyIntensities_merged
--33 Ids
--Id length check
SELECT 
DISTINCT LEN(Id) AS id_length
FROM bellabeat..dailyIntensities_merged
--no irregularities found
--check unique dates
SELECT 
DISTINCT CAST(ActivityDay AS DATE)
FROM bellabeat..dailyIntensities_merged
ORDER BY CAST(ActivityDay AS DATE)
--no irregularities found, 31 unique days
--Check for irregularities in minutes, no minutes should be over 1440
SELECT CAST(sedentaryminutes AS INT)
FROM bellabeat..dailyIntensities_merged
ORDER BY CAST(sedentaryminutes AS INT)
--no irregularities sedentary
SELECT CAST(LightlyActiveMinutes AS INT)
FROM bellabeat..dailyIntensities_merged
ORDER BY CAST(LightlyActiveMinutes AS INT)
--no irregularities lightly active
SELECT CAST(FairlyActiveMinutes AS INT)
FROM bellabeat..dailyIntensities_merged
ORDER BY CAST(FairlyActiveMinutes AS INT)
--no irregularities fairly active
SELECT CAST(VeryActiveMinutes AS INT)
FROM bellabeat..dailyIntensities_merged
ORDER BY CAST(VeryActiveMinutes AS INT)
--no irregularities very active
--Check to make sure total minutes is not > 1440 minutes in a day
SELECT id, activityday, sedentaryminutes, lightlyactiveminutes, fairlyactiveminutes, veryactiveminutes, 
CAST(sedentaryminutes AS INT) + CAST(FairlyActiveMinutes AS INT) + CAST(LightlyActiveMinutes AS INT) +
CAST(VeryActiveMinutes AS INT) AS minutes_total
FROM bellabeat..dailyIntensities_merged
ORDER BY minutes_total
--some entries =1440, but many do not. Will keep since may be in sleep.


--Sleep Day Merged tables--
SELECT * FROM bellabeat..sleepDay_merged
--check Ids
SELECT DISTINCT Id
FROM bellabeat..sleepDay_merged
--no irregularities found
--check Id length
SELECT DISTINCT len(Id)
FROM bellabeat..sleepDay_merged
--no irregularities found
--check date length
SELECT DISTINCT len(sleepday)
FROM bellabeat..sleepDay_merged
--no irregularities found
--check unique dates
SELECT 
DISTINCT CAST(SleepDay AS DATE)
FROM bellabeat..sleepDay_merged
ORDER BY CAST(SleepDay AS DATE)
--no irregularities found
--see sleep records #
SELECT DISTINCT TotalSleepRecords
FROM bellabeat..sleepDay_merged
--no irregularities found
--check for realistic sleep minutes using order by
SELECT *
FROM bellabeat..sleepDay_merged
ORDER BY CAST(TotalMinutesAsleep AS INT)
--30 sleep records are less than 4 hours of sleep, which seems like an error or very concerning health-wise. 
--QUESTION are these incomplete/low sleep numbers the same individuals who have incomplete activty data?

--Weight Log Info tables--
--See which participants are included in weight log
SELECT * FROM bellabeat..weightLogInfo_merged
SELECT DISTINCT Id
FROM bellabeat..weightLogInfo_merged
--Only 8 participants are in the weight log, won't be helpful for our purposes

--Join to use for sleep minutes into daily activities, some users do not have sleep records so those are NULL
SELECT *
FROM 
bellabeat..dailyActivity_merged
LEFT JOIN 
bellabeat..sleepDay_merged
ON dailyActivity_merged.Id = sleepDay_merged.Id 
AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE)
--CTE
--had to rename sleep id since it had an error when used in a CTE, couldn't have 2 ID columns
WITH all_daily_merged AS (
	SELECT dailyActivity_merged.Id AS id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, 
	VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, 
	FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, sleepDay_merged.Id AS s_id, SleepDay, TotalSleepRecords, 
	TotalMinutesAsleep, TotalTimeInBed
	FROM 
	bellabeat..dailyActivity_merged
	LEFT JOIN 
	bellabeat..sleepDay_merged
	ON dailyActivity_merged.Id = sleepDay_merged.Id 
	AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE)
)
SELECT *
FROM all_daily_merged
--943 rows
--did not clean out nulls or 100% sedentary days because non-use is also important information. Will filter through later.


--Hourly Intensities tables--
SELECT * FROM bellabeat..hourlyIntensities_merged
--Unique IDs check
SELECT 
DISTINCT Id 
FROM bellabeat..hourlyIntensities_merged
--33 listed
--check length of ID
SELECT 
DISTINCT LEN(Id) AS id_length
FROM bellabeat..hourlyIntensities_merged
--no irregularities found
--check length of date/time
SELECT 
DISTINCT LEN(ActivityHour) AS date_length
FROM bellabeat..hourlyIntensities_merged
--no irregularities found
--check unique dates
SELECT 
DISTINCT CAST(ActivityHour AS DATETIME)
FROM bellabeat..hourlyIntensities_merged
ORDER BY CAST(ActivityHour AS DATETIME)
--no irregularities found, 736 unique ActivyHour listed
--check unique intensity rates
SELECT 
DISTINCT CAST(TotalIntensity AS INT)
FROM bellabeat..hourlyIntensities_merged
ORDER BY CAST(TotalIntensity AS INT)
--range from 0-180, no irregularities. 
--Checking averages
SELECT CAST(TotalIntensity AS INT), CAST(AverageIntensity AS FLOAT)
FROM bellabeat..hourlyIntensities_merged
WHERE CAST(AverageIntensity AS FLOAT) > CAST(TotalIntensity AS INT)
--no results, all averages entries are rational


--Hourly Steps Merged tables--
SELECT * FROM bellabeat..hourlySteps_merged
----Unique IDs check
SELECT 
DISTINCT Id 
FROM bellabeat..hourlySteps_merged
--33 listed
--check length of ID
SELECT 
DISTINCT LEN(Id) AS id_length
FROM bellabeat..hourlySteps_merged
--no irregularities found
--check length of date/time
SELECT 
DISTINCT LEN(ActivityHour) AS date_length
FROM bellabeat..hourlySteps_merged
--no irregularities found
--check unique dates
SELECT 
DISTINCT CAST(ActivityHour AS DATETIME)
FROM bellabeat..hourlySteps_merged
ORDER BY CAST(ActivityHour AS DATETIME)
--no irregularities found, 736 unique ActivyHour listed, same as Hourly Intensities table
--check steps range
SELECT 
DISTINCT CAST(StepTotal AS INT)
FROM bellabeat..hourlySteps_merged
ORDER BY CAST(StepTotal AS INT)
--entries are rational

--
SELECT CAST(activityhour AS TIME), StepTotal
FROM bellabeat..hourlySteps_merged