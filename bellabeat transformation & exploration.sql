-- DATA EXPLORATION AND SUMMARY STATISTICS --

--joining sleep with daily activity
SELECT *
FROM 
bellabeat..dailyActivity_merged
LEFT JOIN 
bellabeat..sleepDay_merged
ON dailyActivity_merged.Id = sleepDay_merged.Id 
AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE)

--CTE 
WITH all_daily_merged AS (
	SELECT dailyActivity_merged.Id AS id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, 
	VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, 
	FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, sleepDay_merged.Id AS s_id, SleepDay, TotalSleepRecords, 
	TotalMinutesAsleep, TotalTimeInBed FROM bellabeat..dailyActivity_merged LEFT JOIN bellabeat..sleepDay_merged
	ON dailyActivity_merged.Id = sleepDay_merged.Id AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE)
)
SELECT *
FROM all_daily_merged

--how many times was 100% sedentary minutes reported?
WITH all_daily_merged AS (
	SELECT dailyActivity_merged.Id AS id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, 
	VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, 
	FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, sleepDay_merged.Id AS s_id, SleepDay, TotalSleepRecords, 
	TotalMinutesAsleep, TotalTimeInBed FROM bellabeat..dailyActivity_merged LEFT JOIN bellabeat..sleepDay_merged
	ON dailyActivity_merged.Id = sleepDay_merged.Id AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE)
)
SELECT COUNT(id)
FROM all_daily_merged
WHERE sedentaryminutes > 1439
--79, will add to analysis notes


--How many of the participants have sleep data?
WITH all_daily_merged AS (
	SELECT dailyActivity_merged.Id AS id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, 
	VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, 
	FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, sleepDay_merged.Id AS s_id, SleepDay, TotalSleepRecords, 
	TotalMinutesAsleep, TotalTimeInBed FROM bellabeat..dailyActivity_merged LEFT JOIN bellabeat..sleepDay_merged
	ON dailyActivity_merged.Id = sleepDay_merged.Id AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE))
SELECT DISTINCT Id
FROM all_daily_merged
WHERE sleepDay IS NULL
--Only 3 participants have sleep data for every day of the study
WITH all_daily_merged AS (
	SELECT dailyActivity_merged.Id AS id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, 
	VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, 
	FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, sleepDay_merged.Id AS s_id, SleepDay, TotalSleepRecords, 
	TotalMinutesAsleep, TotalTimeInBed FROM bellabeat..dailyActivity_merged LEFT JOIN bellabeat..sleepDay_merged
	ON dailyActivity_merged.Id = sleepDay_merged.Id AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE))
SELECT DISTINCT Id
FROM all_daily_merged
WHERE sleepDay IS NOT NULL
--24/33 participants have at least 1 day of sleep data, sleep can be automatically tracked or manually logged, but does not specify. 
--It does specify how many times sleep was recorded (naps, breaks in sleep)
--TREND tracking sleep isn't a main priority among these participants, or it is too difficult

--LOOKING AT: when sleep is tracked, what is the average, min, and max of sleep among participants?
WITH all_daily_merged AS (
	SELECT dailyActivity_merged.Id AS id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, 
	VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, 
	FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, sleepDay_merged.Id AS s_id, SleepDay, TotalSleepRecords, 
	TotalMinutesAsleep, TotalTimeInBed FROM bellabeat..dailyActivity_merged LEFT JOIN bellabeat..sleepDay_merged
	ON dailyActivity_merged.Id = sleepDay_merged.Id AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE))
SELECT s_id, CAST(SleepDay AS DATE) AS 'date', TotalSleepRecords, CAST(TotalMinutesAsleep as INT) AS 'TotalMinutesAsleep'
FROM all_daily_merged
WHERE sleepDay IS NOT NULL
ORDER BY id, date
--413/943 sleep date entries
--average sleep minutes 419, min 58, max 796
WITH all_daily_merged AS (
	SELECT dailyActivity_merged.Id AS id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, 
	VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, 
	FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, sleepDay_merged.Id AS s_id, SleepDay, TotalSleepRecords, 
	TotalMinutesAsleep, TotalTimeInBed FROM bellabeat..dailyActivity_merged LEFT JOIN bellabeat..sleepDay_merged
	ON dailyActivity_merged.Id = sleepDay_merged.Id AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE))
SELECT AVG(CAST(totalminutesasleep AS INT)) AS sleep_average, MIN(CAST(totalminutesasleep AS INT)) AS sleep_min, 
MAX(CAST(totalminutesasleep AS INT)) AS sleep_max
FROM all_daily_merged
WHERE TotalMinutesAsleep IS NOT NULL AND TotalMinutesAsleep > '0'
--avg, max, min for each user
WITH all_daily_merged AS (
	SELECT dailyActivity_merged.Id AS id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, 
	VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, 
	FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, sleepDay_merged.Id AS s_id, SleepDay, TotalSleepRecords, 
	TotalMinutesAsleep, TotalTimeInBed FROM bellabeat..dailyActivity_merged LEFT JOIN bellabeat..sleepDay_merged
	ON dailyActivity_merged.Id = sleepDay_merged.Id AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE))
SELECT id, AVG(CAST(totalminutesasleep AS INT)) AS sleep_average, MIN(CAST(totalminutesasleep AS INT)) AS sleep_min, 
MAX(CAST(totalminutesasleep AS INT)) AS sleep_max
FROM all_daily_merged
WHERE TotalMinutesAsleep IS NOT NULL AND TotalMinutesAsleep > '0'
GROUP BY id

--LOOKING AT: overall smart device usage, taking out days that are 100% sedentary since that would be a day the device is 
--turned on, but not worn
SELECT id, CAST(COUNT(id) AS DECIMAL) AS id_count, CAST(COUNT(id) AS DECIMAL)/31 AS usage_percentage
FROM bellabeat..dailyActivity_merged
WHERE CAST(totalsteps AS INT) + CAST(calories AS INT) > '0'
GROUP BY id
--Splitting users into high, medium, low usage
SELECT id, COUNT(id) AS total_date_entries,
CASE
WHEN COUNT(id) BETWEEN 0 AND 18 THEN 'low'
WHEN COUNT(id) BETWEEN 19 AND 26 THEN 'medium'
WHEN COUNT(id) BETWEEN 27 AND 32 THEN 'high'
END usage
FROM bellabeat..dailyActivity_merged
WHERE CAST(totalsteps AS INT) + CAST(calories AS INT) > '0'
GROUP BY id


--LOOKING AT: steps trends from Hourly Steps Merged table
--total steps hourly
SELECT DISTINCT CAST(ActivityHour AS DATETIME), SUM(CAST(steptotal AS INT)) AS sum_steps, AVG(CAST(steptotal AS DECIMAL)) AS avg_steps
FROM bellabeat..hourlySteps_merged
GROUP BY CAST(ActivityHour AS DATETIME)
ORDER BY CAST(ActivityHour AS DATETIME)
--steps by day of week
SELECT DISTINCT DATENAME(dw, activityhour) AS day_of_week, SUM(CAST(steptotal AS INT)) AS sum_steps, AVG(CAST(steptotal AS DECIMAL)) AS avg_steps
FROM bellabeat..hourlySteps_merged
GROUP BY DATENAME(dw, activityhour)
ORDER BY DATENAME(dw, activityhour)
--steps by day of week for each user
SELECT DISTINCT DATENAME(dw, activityhour) AS day_of_week, id, SUM(CAST(steptotal AS INT)) AS sum_steps, 
AVG(CAST(steptotal AS DECIMAL)) AS avg_steps
FROM bellabeat..hourlySteps_merged
GROUP BY id, DATENAME(dw, activityhour)
ORDER BY id, DATENAME(dw, activityhour)
--total and avg steps by time of day
SELECT DISTINCT CAST(DATENAME(hh, activityhour) AS INT) AS hour, SUM(CAST(steptotal AS INT)) AS sum_steps, 
AVG(CAST(steptotal AS DECIMAL)) AS avg_steps
FROM bellabeat..hourlySteps_merged
GROUP BY DATENAME(hh, activityhour)
ORDER BY CAST(DATENAME(hh, activityhour) AS INT)
--total and avg steps by time of day for each user
SELECT DISTINCT CAST(DATENAME(hh, activityhour) AS INT) AS hour, id, SUM(CAST(steptotal AS INT)) AS sum_steps, 
AVG(CAST(steptotal AS DECIMAL)) AS avg_steps
FROM bellabeat..hourlySteps_merged
GROUP BY id, DATENAME(hh, activityhour)
ORDER BY id, CAST(DATENAME(hh, activityhour) AS INT)
--steps by weekday vs weekend
SELECT DISTINCT CASE
WHEN DATENAME(dw, activityhour) = 'Saturday' OR DATENAME(dw, activityhour) = 'Sunday' THEN 'Weekend'
WHEN DATENAME(dw, activityhour) = 'Monday' OR DATENAME(dw, activityhour) = 'Tuesday' OR DATENAME(dw, activityhour) = 'Wednesday' 
OR DATENAME(dw, activityhour) = 'Thursday' OR DATENAME(dw, activityhour) = 'Friday' THEN 'Weekday'
END AS part_of_week, SUM(CAST(steptotal AS INT)) AS sum_steps
FROM bellabeat..hourlySteps_merged
GROUP BY DATENAME(dw, activityhour)
ORDER BY part_of_week
--Why the large drop in SUM steps towards end of study? Are there less records?
SELECT DISTINCT CAST(activityhour AS DATE), COUNT (CAST(activityhour AS DATE))
FROM bellabeat..hourlySteps_merged
GROUP BY CAST(activityhour AS DATE)
ORDER BY CAST(ActivityHour AS DATE)
--Yes, there is a drop in records towards the end of the study. This is valuable data!
--What is we filter out low and medium users? Is that still the trend?
SELECT DISTINCT CAST(activityhour AS DATE), COUNT (CAST(activityhour AS DATE))
FROM bellabeat..hourlySteps_merged
WHERE NOT id= '2347167796' AND NOT id= '3372868164' AND NOT id= '4057192912' AND NOT id= '6775888955' AND NOT id= '7007744171'
GROUP BY CAST(activityhour AS DATE)
ORDER BY CAST(ActivityHour AS DATE)
--Yes, the trend still exists.


--overall intensities by hour for each user
SELECT id, DATENAME(hh, activityhour) AS 'hour', SUM(CAST(totalintensity AS INT)) AS 'intensity_totals_by_hour', 
AVG(CAST(totalintensity AS DECIMAL)) AS avg_intensities_by_hour
FROM bellabeat..hourlyIntensities_merged
GROUP BY id, DATENAME(hh, activityhour)
ORDER BY id, CAST(DATENAME(hh, activityhour) AS INT)
--overall intensities by day of week
SELECT DISTINCT DATENAME(dw, activityday) AS day_of_week, SUM(CAST(FairlyActiveMinutes AS INT) + CAST(veryactiveminutes AS INT)) 
AS fairly_and_active_minutes_sum
FROM bellabeat..dailyIntensities_merged
GROUP BY DATENAME(dw, activityday)
ORDER BY DATENAME(dw, activityday)



-- CREATING VIEWS FOR TABLEAU IMPORT --

CREATE VIEW sleep_trends_by_user AS
WITH all_daily_merged AS (
	SELECT dailyActivity_merged.Id AS id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, 
	VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, 
	FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, sleepDay_merged.Id AS s_id, SleepDay, TotalSleepRecords, 
	TotalMinutesAsleep, TotalTimeInBed FROM bellabeat..dailyActivity_merged LEFT JOIN bellabeat..sleepDay_merged
	ON dailyActivity_merged.Id = sleepDay_merged.Id AND CAST(dailyActivity_merged.ActivityDate AS DATE) = CAST(sleepDay_merged.SleepDay AS DATE))
SELECT id, AVG(CAST(totalminutesasleep AS INT)) AS sleep_average, MIN(CAST(totalminutesasleep AS INT)) AS sleep_min, 
MAX(CAST(totalminutesasleep AS INT)) AS sleep_max
FROM all_daily_merged
WHERE TotalMinutesAsleep IS NOT NULL AND TotalMinutesAsleep > '0'
GROUP BY id

CREATE VIEW device_usage AS
SELECT id, CAST(COUNT(id) AS DECIMAL) AS id_count, CAST(COUNT(id) AS DECIMAL)/31 AS usage_percentage
FROM bellabeat..dailyActivity_merged
WHERE CAST(totalsteps AS INT) + CAST(calories AS INT) > '0'
GROUP BY id

CREATE VIEW device_usage_categorized AS 
SELECT id, COUNT(id) AS total_date_entries,
CASE
WHEN COUNT(id) BETWEEN 0 AND 18 THEN 'low'
WHEN COUNT(id) BETWEEN 19 AND 26 THEN 'medium'
WHEN COUNT(id) BETWEEN 27 AND 32 THEN 'high'
END usage
FROM bellabeat..dailyActivity_merged
WHERE CAST(totalsteps AS INT) + CAST(calories AS INT) > '0'
GROUP BY id

CREATE VIEW overall_steps_by_day_of_week AS
SELECT DISTINCT DATENAME(dw, activityhour) AS day_of_week, SUM(CAST(steptotal AS INT)) AS sum_steps, AVG(CAST(steptotal AS DECIMAL)) AS avg_steps
FROM bellabeat..hourlySteps_merged
GROUP BY DATENAME(dw, activityhour)

CREATE VIEW steps_by_hour_over_month AS 
SELECT DISTINCT CAST(ActivityHour AS DATETIME) AS 'date_time', SUM(CAST(steptotal AS INT)) AS sum_steps, AVG(CAST(steptotal AS DECIMAL)) AS avg_steps
FROM bellabeat..hourlySteps_merged
GROUP BY CAST(ActivityHour AS DATETIME)


CREATE VIEW overall_steps_by_hour AS
SELECT DISTINCT CAST(DATENAME(hh, activityhour) AS INT) AS hour, SUM(CAST(steptotal AS INT)) AS sum_steps, 
AVG(CAST(steptotal AS DECIMAL)) AS avg_steps
FROM bellabeat..hourlySteps_merged
GROUP BY DATENAME(hh, activityhour)

CREATE VIEW steps_by_hour_per_user AS
SELECT DISTINCT CAST(DATENAME(hh, activityhour) AS INT) AS hour, id, SUM(CAST(steptotal AS INT)) AS sum_steps, 
AVG(CAST(steptotal AS DECIMAL)) AS avg_steps
FROM bellabeat..hourlySteps_merged
GROUP BY id, DATENAME(hh, activityhour)


CREATE VIEW intensities_by_hour_per_user AS
SELECT id, DATENAME(hh, activityhour) AS 'hour', SUM(CAST(totalintensity AS INT)) AS 'intensity_totals_by_hour', 
AVG(CAST(totalintensity AS DECIMAL)) AS avg_intensities_by_hour
FROM bellabeat..hourlyIntensities_merged
GROUP BY id, DATENAME(hh, activityhour)

CREATE VIEW intensities_by_day_of_week AS
SELECT DISTINCT DATENAME(dw, activityday) AS day_of_week, SUM(CAST(FairlyActiveMinutes AS INT) + CAST(veryactiveminutes AS INT)) 
AS fairly_and_active_minutes_sum
FROM bellabeat..dailyIntensities_merged
GROUP BY DATENAME(dw, activityday)
