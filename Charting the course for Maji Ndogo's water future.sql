/* This query combines data from various tables like 
location table, water sources table and visitis table*/
WITH Combined_analysis_table AS(
SELECT
	loc.province_name,
    loc.town_name,
    loc.location_type,
    ws.type_of_water_source,
    ws.number_of_people_served,
    v.time_in_queue
FROM
	location AS loc
JOIN
	visits AS v
	ON
		v.location_id = loc.location_id
JOIN
	water_source AS ws
    ON
		ws.source_id = v.source_id
LEFT JOIN
	well_pollution AS wp
    ON
		wp.source_id = ws.source_id
WHERE
	visit_count = 1),

-- This query calculates total per province    
province_totals AS(
SELECT
	province_name,
    SUM(number_of_people_served) AS total_people_served
FROM
	Combined_analysis_table
GROUP BY
	province_name
),

-- This CTE query calculates the types of  water sources per province
province_aggregated_water_access AS(
SELECT
	ct.province_name,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'river'
		THEN
			number_of_people_served*100/pt.total_people_served
		ELSE 0
	END),0) AS river,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'well'
		THEN
			number_of_people_served*100/pt.total_people_served
		ELSE 0
	END),0) AS well,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'shared_tap'
		THEN
			number_of_people_served*100/pt.total_people_served
		ELSE 0
	END),0) AS shared_tap,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'tap_in_home'
		THEN
			number_of_people_served*100/pt.total_people_served
		ELSE 0
	END),0) AS tap_in_home,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'tap_in_home_broken'
		THEN
			number_of_people_served*100/pt.total_people_served
		ELSE 0
	END),0) AS tap_in_home_broken
FROM
	Combined_analysis_table AS ct
JOIN
	province_totals AS pt
    ON
		pt.province_name = ct.province_name
GROUP BY
	ct.province_name
ORDER BY
	ct.province_name),

-- This query calculates total per town
town_totals AS(
SELECT
	province_name,
    town_name,
    SUM(number_of_people_served) AS total_people_served
FROM
	Combined_analysis_table
GROUP BY
	province_name,
    town_name
),
-- -- This CTE query calculates the types of  water sources per town
Town_aggregated_water_access AS(
SELECT
	ct.province_name,
    ct.town_name,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'river'
		THEN
			number_of_people_served*100/tt.total_people_served
		ELSE 0
	END),0) AS river,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'well'
		THEN
			number_of_people_served*100/tt.total_people_served
		ELSE 0
	END),0) AS well,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'shared_tap'
		THEN
			number_of_people_served*100/tt.total_people_served
		ELSE 0
	END),0) AS shared_tap,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'tap_in_home'
		THEN
			number_of_people_served*100/tt.total_people_served
		ELSE 0
	END),0) AS tap_in_home,
    ROUND(SUM(CASE
		WHEN
			type_of_water_source = 'tap_in_home_broken'
		THEN
			number_of_people_served*100/tt.total_people_served
		ELSE 0
	END),0) AS tap_in_home_broken
    
FROM
	Combined_analysis_table AS ct
JOIN
	town_totals AS tt
    ON
		tt.province_name = ct.province_name
	AND
		tt.town_name = ct.town_name
GROUP BY
	ct.province_name,
    ct.town_name
ORDER BY
	ct.town_name),
/* 1. The table shows that a large percentage of people are drinking river water in sokoto in rural areas,
while the urban areas have more people with taps in their homes. 
Large disparities like this shows that the wealth distribution in sokoto is very unequal. 
Drilling teams should be sent to sokoto to drill some wells in rural areas, specifically Bahari where they're drinking river water.
2. More than half the people in Amina have taps in their homes, but only 3% of those taps are working. 
Teams should be sent to Amina to fix the broken infrastructure. This should drastically reduce the queuing time in Amina. */

-- Query calculates the town with taps, but have their infrastructure broken.
pct_broken_infrastructure AS(
SELECT
	province_name,
    town_name,
    ROUND(tap_in_home_broken * 100/(tap_in_home_broken + tap_in_home)) AS pct_broken_taps
FROM
	Town_aggregated_water_access),

/*Query to create Maji Ndogo project progress table, so we can 
properly documents and track improvment process */
CREATE TABLE project_progress (
	Project_id SERIAL PRIMARY KEY, -- Unique key for sources, incase we visit a source multuple times in thr future.
    source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
    Address VARCHAR(50),
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50),
    Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    /*Source_status -- We want to limit the type of information engineers can give us,
    so we limit Source_status.
		- By DEFAULT all projects are in 'backlog', which is like todo list.
        - Check() ensures only those three options are accepted. */
	Date_of_completion DATE, 
    Comments TEXT)
  
/* The below query sort out areas of improvements and insert the data
into the Project progress table*/
INSERT INTO project_progress (Address, Town, Province, source_id, 
								Source_type, Improvement)
-- query to sort out areas of improvments
SELECT
	loc.address AS Address,
    loc.town_name AS Town,
    loc.province_name AS Province,
    ws.source_id,
    ws.type_of_water_source AS Source_type,
    CASE
		WHEN
			wp.results = 'Contaminated: Biological'
		THEN
			'Install UV and RO filter'
		WHEN
			wp.results = 'Contaminated: Chemical'
		THEN
			'RO filter'
		WHEN
			ws.type_of_water_source = 'shared_tap'
		THEN
			CONCAT('Install ', FLOOR(v.time_in_queue/30), ' tap(s) nearby')
		WHEN
			ws.type_of_water_source = 'river'
		THEN
			'Drill wells'
		WHEN
			ws.type_of_water_source = 'tap_in_home_broken'
		THEN
			'Diagnose local infrastructure'
		ELSE NULL 
	END AS Improvement
FROM
	water_source AS ws
LEFT JOIN
	well_pollution  AS wp
    ON
		wp.source_id = ws.source_id
JOIN
	visits AS v
    ON
		ws.source_id = v.source_id
JOIN
	location AS loc
	ON
		v.location_id = loc.location_id
WHERE
	v.visit_count = 1
    AND (
		wp.results <> 'Clean' 
		OR (v.time_in_queue >= 30 AND ws.type_of_water_source = 'shared_tap')
        OR ws.type_of_water_source IN ('river', 'tap_in_home_broken')
        );
    