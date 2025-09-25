/* This query is to update the email column on 
employee table from Null to the official email */
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');

/*This query will remove extra spaces from the 
phone number column of the employee table */
SELECT
	phone_number,
    LENGTH(phone_number) AS Length,
    LENGTH(TRIM(phone_number)) AS New_length
FROM
	employee;
    
-- Updating the phone number column
UPDATE employee
SET phone_number = (TRIM(phone_number));

/*This query counts the number of employes per town. Some town
have same names, so the Province_name column differentiates them*/
SELECT
	province_name,
    town_name,
    COUNT(assigned_employee_id) AS Employee_per_town
FROM
	employee
GROUP BY
	town_name,
    province_name;
    
/*Query to find the information top 3 employees with the highest number of locations visited
This query is to find the top 3 visiting employees*/
WITH Top_visiting_employees AS(
SELECT
	assigned_employee_id,
    COUNT(visit_count) AS Number_of_visits,
    DENSE_RANK() OVER (ORDER BY COUNT(visit_count) DESC) AS Top_employees
FROM
	visits
GROUP BY
	assigned_employee_id
LIMIT 3)
-- This query is to extract the information of the top visiting employees
SELECT
	t.assigned_employee_id,
    e.employee_name,
    e.phone_number,
    e.email,
    t.Number_of_visits
FROM
	Top_visiting_employees AS t
JOIN
	employee AS e
    ON
		t.assigned_employee_id = e.assigned_employee_id;
-- Their names are 'Bello Azibo', 'Pili Zola', 'Rudo Imani' 


-- Query that counts the number of records per town and Province
SELECT
	province_name,
    town_name,
    COUNT(town_name) AS records_per_town
FROM
	location
GROUP BY
	province_name,
    town_name
ORDER BY
	province_name,
    records_per_town DESC;
    
/*Query that counts the number of records per location_type in percentages
This CTE calculates the aggregated sum of the location type*/
WITH location_type_record AS(
SELECT
	location_type,
    COUNT(location_type) AS records_per_location,
    SUM(COUNT(location_type)) OVER () AS total_records
FROM
	location
GROUP BY
	location_type
ORDER BY
	 records_per_location DESC)
-- This query extracts values from the CTE to calculate the percentages
SELECT
	location_type,
    records_per_location,
    ROUND(records_per_location*100/total_records) AS pct_records_per_location
FROM
	location_type_record;
-- Rural population accounts for about 60% of the records 

  
-- Query to get the number of survyed participants
SELECT
	SUM(number_of_people_served) AS Total_people_served
FROM
	water_source;


-- Query to count the number of water sources
SELECT
	type_of_water_source,
    COUNT(type_of_water_source) AS Number_of_water_sources,
    ROUND(AVG(number_of_people_served)) AS Avg_number_of_people_served
FROM
	water_source
GROUP BY
	type_of_water_source
ORDER BY
	Number_of_water_sources DESC;
-- There are more wells in Majo Ndogo than other sources 


-- Query to count the number of people served per source
SELECT
	type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS Avg_number_of_people_served
FROM
	water_source
GROUP BY
	type_of_water_source
ORDER BY
	Avg_number_of_people_served DESC;
-- Shared tap is the highest with an average of 2000 persons/tap


-- Query to get the percentage and rank by population of water source
SELECT
	type_of_water_source,
    SUM(number_of_people_served) AS people_served_per_source,
    ROUND(
		SUM(number_of_people_served) * 100/SUM(SUM(number_of_people_served)) OVER()
        ) AS pct_people_served_per_source,
	RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS Rank_by_population
FROM
	water_source
GROUP BY
	type_of_water_source
ORDER BY
	people_served_per_source DESC;
-- shared tap is 43% and it is serving the highest number of persons 


-- Query to get the priority rank level of each source_id
SELECT
	source_id,
    type_of_water_source,
    SUM(number_of_people_served) AS people_served_per_source,
    DENSE_RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS Priority_rank
FROM
	water_source
GROUP BY
	source_id,
    type_of_water_source
ORDER BY
	people_served_per_source DESC;


-- Query to get the start date, end date, and survey duration
SELECT
    MIN(DATE(time_of_record)) AS Survey_start_date,
    MAX(DATE(time_of_record)) AS Survey_end_date,
    DATEDIFF(MAX(DATE(time_of_record)), MIN(DATE(time_of_record))) AS Survey_duration
FROM
    visits;
-- Survey started from 2021 to 2023, lasting 924days 


-- Query to get the average queuing time
SELECT
	ROUND(AVG(NULLIF(time_in_queue, 0))) AS Average_water_queue_time
FROM
	visits;
-- The average queue time is 123 mins 


-- Query to get the average queue time per day
SELECT
	DAYNAME(time_of_record) AS Week_name,
	ROUND(AVG(NULLIF(time_in_queue, 0))) AS Average_water_queue_time
FROM
	visits
GROUP BY
	Week_name
ORDER BY
	Average_water_queue_time DESC;
-- More people spend time in queue on Saturdays, Mondays and Fridays respectively


-- Query to get the average queue time per day
SELECT
	TIME_FORMAT(time_of_record, '%H:00') AS Time_period,
	ROUND(AVG(NULLIF(time_in_queue, 0))) AS Average_water_queue_time
FROM
	visits
GROUP BY
	Time_period
ORDER BY
	Average_water_queue_time DESC;
-- Most queuing time are between 5pm to 7pm, and 6am to 8am 


-- Query that further breaks down the queue time per day, hour by hour
SELECT
	TIME_FORMAT(time_of_record, '%H:00') AS Time_period,
    ROUND(AVG(CASE
		WHEN DAYNAME(time_of_record) = 'Sunday'
        THEN time_in_queue
        ELSE NULL
	END), 0) AS 'Sunday',
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Monday'
        THEN time_in_queue
        ELSE NULL
	END), 0) AS 'Monday',
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Tuesday'
        THEN time_in_queue
        ELSE NULL
	END), 0) AS 'Tuesday',
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Wednesday'
        THEN time_in_queue
        ELSE NULL
	END), 0) AS 'Wednesday',
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Thursday'
        THEN time_in_queue
        ELSE NULL 
	END), 0) AS 'Thursday',
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Friday'
        THEN time_in_queue
        ELSE NULL 
	END), 0) AS 'Friday',
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Saturday'
        THEN time_in_queue
        ELSE NULL 
	END), 0) AS 'Saturday'
FROM
	visits
WHERE 
	time_in_queue <> 0 -- this excludes other sources with zero queue time
GROUP BY
	Time_period
ORDER BY
	Time_period;
-- Wednesdays have the lowest queue time during weekdays, but long queue on Wednesday evenings
-- Sundays have the shortest queues generally 


/*
Insights
1. Most water sources are rural.
2. 43% of our people are using shared taps. 2000 people often share one tap.
3. 31% of our population has water infrastructure in their homes, but within that group, 45% face non-functional systems due to issues with pipes,
pumps, and reservoirs.
4. 18% of our people are using wells of which, but within that, only 28% are clean..
5. Our citizens often face long wait times for water, averaging more than 120 minutes.
6. In terms of queues:
- Queues are very long on Saturdays.
- Queues are longer in the mornings and evenings.
- Wednesdays and Sundays have the shortest queues.


The plan
I have started thinking about a plan:
1. I want us to focus our efforts on improving the water sources that affect the most people.
- Most people will benefit if we improve the shared taps first.
- Wells are a good source of water, but many are contaminated. Fixing this will benefit a lot of people.
- Fixing existing infrastructure will help many people. If they have running water again, they won't have to queue, thereby shorting queue times for
others. So we can solve two problems at once.
- Installing taps in homes will stretch our resources too thin, so for now, if the queue times are low, we won't improve that source.
2. Most water sources are in rural areas. We need to ensure our teams know this as this means they will have to make these repairs/upgrades in
rural areas where road conditions, supplies, and labour are harder challenges to overcome.*/
