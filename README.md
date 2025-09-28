# Maji Ndogo Water Source Analysis and Improvement Project

## Overview
This repository contains SQL scripts for analyzing and managing water source data in Maji Ndogo. The scripts focus on data cleaning, employee performance evaluation, water source distribution, queue time analysis, and project planning to improve water access and infrastructure.

## Files and Descriptions

### 1. `Begining_my_Data_Driven_Journey_in_Maji_Ndogo.sql`
This script performs initial exploration and cleaning of the Maji Ndogo water services database:
- Retrieves unique water source types and data from `employee`, `location`, `visits`, `water_quality`, `water_source`, and `well_pollution` tables.
- Identifies records with queue times exceeding 500 minutes and specific source IDs with high queue times (e.g., shared taps).
- Analyzes water quality for home taps with a subjective quality score of 10 on repeat visits.
- Corrects inconsistencies in the `well_pollution` table where wells marked as 'Clean' have biological contamination (>0.01 ppm), updating descriptions and results accordingly.

**Key Insights**:
- Shared taps are associated with the highest queue times.
- 38 wells were incorrectly labeled as 'Clean' despite biological contamination.
- Home taps with high quality scores were identified for further validation.

### 2. `Clustering_data_to_unveil_Maji_Ndogo_water_crisis.sql`
This script performs initial data cleaning and analysis of employee performance:
- Updates the `employee` table by generating official email addresses and trimming extra spaces from phone numbers.
- Analyzes employee distribution across towns and provinces.
- Identifies top-performing employees based on the number of locations visited.
- Aggregates water source data, including counts, percentages, and population served per source type.
- Examines survey duration, queue times by day and hour, and key insights about water source usage.

**Key Insights**:
- 43% of the population relies on shared taps, with an average of 2,000 people per tap.
- 31% have home water infrastructure, but 45% of these systems are non-functional.
- 18% use wells, of which only 28% are clean.
- Queue times average 123 minutes, with peaks on Saturdays, mornings, and evenings.

### 3. `Weaving_the_data_threads_of_maji_ndogo_narrative.sql`
This script compares surveyor and auditor reports to identify discrepancies:
- Aligns auditor and surveyor reports to verify water source quality scores.
- Identifies employees with above-average incorrect inputs, focusing on potential errors or misconduct (e.g., mentions of "cash" in auditor statements).
- Highlights specific employees (e.g., Bello Azibo, Malachi Mavuso) for further investigation due to high error rates.

**Key Insights**:
- 1,518 surveyor scores match auditor scores out of 1,620 locations visited.
- 102 conflicting scores were identified, with four employees making significantly more errors than average.


### 4. `Charting the course for Maji Ndogo's water future.sql`
This script aggregates water source data and sets up a project progress tracking system:
- Combines data from `location`, `water_source`, `visits`, and `well_pollution` tables to analyze water access by province and town.
- Calculates the percentage of water source types (e.g., river, well, shared tap) per province and town.
- Identifies areas with high percentages of broken infrastructure (e.g., Amina, where only 3% of home taps are functional).
- Creates a `project_progress` table to track improvement projects, including source status and required interventions (e.g., installing filters, drilling wells, fixing infrastructure).
- Proposes practical solutions like deploying water tankers, installing filters, and prioritizing infrastructure repairs in high-impact areas.

**Key Insights**:
- Rural areas, especially in Sokoto, rely heavily on river water, indicating unequal wealth distribution.
- Towns like Amina and rural Amanzi have significant broken infrastructure, requiring urgent repairs.
- Proposed interventions prioritize shared taps, contaminated wells, and broken infrastructure to maximize impact.

## Project Goals
- **Improve Water Access**: Prioritize shared taps, contaminated wells, and broken infrastructure to reduce queue times and improve water quality.
- **Target Rural Areas**: Focus on rural regions like Sokoto for well-drilling and filter installations.
- **Track Progress**: Use the `project_progress` table to monitor and prioritize interventions systematically.
- **Address Discrepancies**: Investigate employee errors to ensure data accuracy and integrity.

## How to Use
1. Run the scripts in the order they are numbered to ensure data dependencies are met.
2. Review the insights and proposed solutions in each script to guide water infrastructure improvement efforts.
3. Use the `project_progress` table to track ongoing and future interventions.

## Future Work
- Expand analysis to include additional data sources or metrics (e.g., cost estimates for repairs).
- Automate error detection for surveyor reports.
- Develop dashboards for real-time visualization of water source and project progress data.
