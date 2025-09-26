-- Query to confirm if the auditors report and the surveyors report align.
WITH records AS(
SELECT
	ar.location_id,
    ws.type_of_water_source AS surveyor_source_type,
    wq.subjective_quality_score AS surveyor_score,
    ar.type_of_water_source AS auditor_source_type,
    ar.true_water_source_score AS auditor_score
FROM 
	water_quality AS wq
JOIN
	visits AS v
    ON
		v.record_id = wq.record_id
JOIN
	auditor_report AS ar
    ON
		ar.location_id = v.location_id
JOIN
	water_source AS ws
	ON
		ws.source_id = v.source_id
WHERE
	v.visit_count = 1
    AND
		 wq.subjective_quality_score <> ar.true_water_source_score),
-- The auditor visited 1620 locations
-- 1518 surveyor score match the auditor score.
-- There 102 conflicting scores between the auditor & surveyor reports 


-- Query to check the names of the employees and the number of times the made an incorrect input
Incorrect_records AS(
SELECT
	ar.location_id,
    e.employee_name AS surveyor_name,
    wq.subjective_quality_score AS surveyor_score,
    ar.type_of_water_source AS auditor_source_type,
    ar.true_water_source_score AS auditor_score,
    ar.statements AS auditor_statement
FROM 
	water_quality AS wq
JOIN
	visits AS v
    ON
		v.record_id = wq.record_id
JOIN
	auditor_report AS ar
    ON
		ar.location_id = v.location_id
JOIN
	employee AS e
    ON
		e.assigned_employee_id = v.assigned_employee_id
WHERE
	v.visit_count = 1
    AND
		 wq.subjective_quality_score <> ar.true_water_source_score),

-- This CTE Query is to find employee with above average number of mistakes
Suspected_employees AS(
SELECT
	surveyor_name,
    COUNT(surveyor_name) AS number_of_mistakes,
    ROUND(AVG(COUNT(surveyor_name)) OVER()) average_mistake
FROM
	Incorrect_records
GROUP BY
	surveyor_name
ORDER BY
	number_of_mistakes DESC),
Top_suspects AS(
SELECT
	surveyor_name,
    number_of_mistakes
FROM
	Suspected_employees
WHERE
	number_of_mistakes > average_mistake)
-- Bello Azibo, Malachi Mavuso, Zuriel Matembo and Lalitha Kaburi, made 26, 21, 17 and 7 incorrect inputs respectively

-- This query further narrows down the suspected employees with descriptions like cash in the auditor statements
SELECT
	location_id,
    surveyor_name,
    auditor_statement
FROM
	Incorrect_records
WHERE
	auditor_statement LIKE ('%cash%')
    AND
		surveyor_name IN (SELECT
								surveyor_name
							FROM
								Top_suspects)
-- Bello Azibo, Lalitha Kaburi, Zuriel Matembo, and Malachi Mavuso made more mistakes than average
-- they all have incriminating statements made against them, and only them.
	