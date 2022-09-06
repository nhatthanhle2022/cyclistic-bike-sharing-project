-- PROCESSING DATA

-- Filter out unnecessary data and merge all dataset into one table
DROP TABLE IF EXISTS #divvy_tripdata
CREATE TABLE #divvy_tripdata
(
ride_id nvarchar(255), rideable_type nvarchar(255), 
started_at datetime, ended_at datetime, start_station_name nvarchar(255), end_station_name nvarchar(255), 
start_lat float, start_lng float, end_lat float, end_lng float, 
member_casual nvarchar(255), ride_length datetime, day_of_week float
)

INSERT INTO #divvy_tripdata 
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202107-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202108-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202109-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202110-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202111-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202112-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202201-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202202-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202203-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202204-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202205-divvy-tripdata]
UNION

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, 
		start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
FROM [cyclistic-bike-sharing-project].[dbo].[202206-divvy-tripdata]


--Inspect the new table for statistical summary.
SELECT TOP 10 *
FROM #divvy_tripdata

--Exclude the NULL values in start_station_name and end_station_name columns for further analysis with stations
SELECT * 
FROM #divvy_tripdata
WHERE start_station_name IS NOT NULL AND end_station_name IS NOT NULL

-- Inspect anomalies in data
SELECT DISTINCT(rideable_type)
FROM #divvy_tripdata

SELECT DISTINCT(start_station_name)
FROM #divvy_tripdata
ORDER BY start_station_name

SELECT DISTINCT(end_station_name)
FROM #divvy_tripdata
ORDER BY end_station_name

SELECT 
		MIN(start_lat)as min_start_lat,
		MAX(start_lat) as max_start_lat,
		MIN(start_lng) as min_start_lng,
		MAX(start_lng) as max_start_lng
FROM #divvy_tripdata

SELECT 
		MIN(end_lat) as min_end_lat,
		MAX(end_lat) as max_end_lat,
		MIN(end_lng)as min_end_lng,
		MAX(end_lng) as max_end_lng
FROM #divvy_tripdata

SELECT DISTINCT(member_casual)
FROM #divvy_tripdata

SELECT 
		MIN(ride_length) as min_ride_length,
		MAX(ride_length) as max_ride_length
FROM #divvy_tripdata

SELECT DISTINCT(day_of_week)
FROM #divvy_tripdata
ORDER BY day_of_week

--Notice that the ride_length format was incorrect after importing data into SQL, this code chunk will fix the time format.
SELECT FORMAT (ride_length, 'HH:mm:ss') as correct_ride_length
FROM #divvy_tripdata
WHERE start_station_name IS NOT NULL AND end_station_name IS NOT NULL
ORDER BY correct_ride_length

-- ANALYZING DATA

-- Analysis 1: Total count of bikes borrowed per day of the week. 1 = Sunday to 7 = Saturday 
SELECT
	day_of_week,
	COUNT(day_of_week) as total_count
FROM #divvy_tripdata
GROUP BY day_of_week 
ORDER BY day_of_week

-- Statistical Summary:
SELECT
	member_casual,
	COUNT(ride_id) AS total
FROM #divvy_tripdata
GROUP BY member_casual

-- Comparing member vs. casual on how many bikes borrowed per day of week.
SELECT
	day_of_week,
	member_casual,
	COUNT(day_of_week) as total_count
FROM #divvy_tripdata
GROUP BY day_of_week, member_casual
ORDER BY 2,1

-- Analyze ridable types that people tend to borrow the most on each day of week
SELECT
	rideable_type,
	day_of_week,
	COUNT(day_of_week) as total_count
FROM #divvy_tripdata
WHERE member_casual = 'casual'
--WHERE member_casual = 'member'
GROUP BY day_of_week, rideable_type
ORDER BY 1,2

-- Analysis 2: Ride length 
-- Convert ride_length into minute metrics for later visualizations
-- There is an issue with ride_length format that will cause problem when we make visualizations in the future
-- By observing the data, any borrowing time that less than a day will have result in the date of '1899-12-30'
-- Longest borrowing time is 28 days based on the querry below.

SELECT 
	member_casual,
	started_at, ended_at,
	ride_length, 
	DATEPART(YYYY, ride_length) Year, 
	DATEPART(MM, ride_length) Month, 
	DATEPART(DD, ride_length) Day,
	CASE
	WHEN DATEPART(DD, ride_length) >=1 AND DATEPART(DD, ride_length) < 30 
	THEN DATEPART(DD, ride_length) * 1440 + DATEPART(HH, ride_length) * 60 + DATEPART(MI, ride_length)
	ELSE DATEPART(HH, ride_length) * 60 + DATEPART(MI, ride_length)
	END AS ride_length_in_minute
FROM #divvy_tripdata
ORDER BY ride_length_in_minute DESC

-- Compare the statistical summary of ride length differences between members and casual users during each day of week
WITH CTE_ride_length AS 
(SELECT 
	member_casual,
	day_of_week,
	CASE
	WHEN DATEPART(DD, ride_length) >=1 AND DATEPART(DD, ride_length) < 30 
	THEN DATEPART(DD, ride_length) * 1440 + DATEPART(HH, ride_length) * 60 + DATEPART(MI, ride_length)
	ELSE DATEPART(HH, ride_length) * 60 + DATEPART(MI, ride_length)
	END AS ride_length_in_minute
FROM #divvy_tripdata)
SELECT 
	member_casual, 
	day_of_week,
	AVG(ride_length_in_minute) AS average_ride_length_by_day,
	MAX(ride_length_in_minute) AS max_ride_length,
	MIN(ride_length_in_minute) AS min_ride_length
FROM CTE_ride_length
GROUP BY day_of_week, member_casual
ORDER BY member_casual, day_of_week

-- Analysis 3: Most Used Stations
-- Most used start stations based on 12-months duration
SELECT
	DISTINCT(start_station_name),
	start_lat,
	start_lng,
	COUNT(ride_id) AS total_bikes_borrowed
FROM #divvy_tripdata
WHERE start_station_name IS NOT NULL AND end_station_name IS NOT NULL
GROUP BY start_station_name, start_lat, start_lng
ORDER BY total_bikes_borrowed DESC

-- Most used end stations based on 12-months duration
SELECT
	DISTINCT(end_station_name),
	ride_id,
	end_lat,
	end_lng,
	COUNT(ride_id) AS total_bikes_returned
FROM #divvy_tripdata
WHERE start_station_name IS NOT NULL AND end_station_name IS NOT NULL
GROUP BY ride_id, end_station_name, end_lat, end_lng
ORDER BY total_bikes_returned DESC