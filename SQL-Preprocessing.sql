-- Step 1: Load the data from the Excel file into a temporary table
CREATE TEMPORARY TABLE temp_wh_data (
    Country_name TEXT,
    Year INT,
    Life_Ladder FLOAT,
    Log_GDP_per_capita FLOAT,
    Social_support FLOAT,
    Healthy_life_expectancy_at_birth FLOAT,
    Freedom_to_make_life_choices FLOAT,
    Generosity FLOAT,
    Perceptions_of_corruption FLOAT,
    Positive_affect FLOAT,
    Negative_affect FLOAT
);

-- Load data from Excel file
INSERT INTO temp_wh_data
SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
                         'Excel 12.0;Database=/Applications/FILES/STUDY/SQL/WHData2023.xlsx', 
                         'SELECT * FROM [Sheet1$]');

-- Step 2: Data Cleaning and Preprocessing

-- Remove duplicates if any
DELETE FROM temp_wh_data WHERE ROWID NOT IN (
    SELECT MIN(ROWID) FROM temp_wh_data GROUP BY Country_name, Year
);

-- Replace NULL values with appropriate defaults or averages
UPDATE temp_wh_data
SET 
    Life_Ladder = COALESCE(Life_Ladder, 0),
    Log_GDP_per_capita = COALESCE(Log_GDP_per_capita, 0),
    Social_support = COALESCE(Social_support, 0),
    Healthy_life_expectancy_at_birth = COALESCE(Healthy_life_expectancy_at_birth, 0),
    Freedom_to_make_life_choices = COALESCE(Freedom_to_make_life_choices, 0),
    Generosity = COALESCE(Generosity, 0),
    Perceptions_of_corruption = COALESCE(Perceptions_of_corruption, 0),
    Positive_affect = COALESCE(Positive_affect, 0),
    Negative_affect = COALESCE(Negative_affect, 0);

-- Step 3: Summary Statistics

-- Calculate summary statistics
SELECT 
    MIN(Life_Ladder) AS Min_Life_Ladder,
    MAX(Life_Ladder) AS Max_Life_Ladder,
    AVG(Life_Ladder) AS Avg_Life_Ladder,
    MIN(Log_GDP_per_capita) AS Min_Log_GDP_per_capita,
    MAX(Log_GDP_per_capita) AS Max_Log_GDP_per_capita,
    AVG(Log_GDP_per_capita) AS Avg_Log_GDP_per_capita,
    MIN(Social_support) AS Min_Social_support,
    MAX(Social_support) AS Max_Social_support,
    AVG(Social_support) AS Avg_Social_support,
    MIN(Healthy_life_expectancy_at_birth) AS Min_Healthy_life_expectancy_at_birth,
    MAX(Healthy_life_expectancy_at_birth) AS Max_Healthy_life_expectancy_at_birth,
    AVG(Healthy_life_expectancy_at_birth) AS Avg_Healthy_life_expectancy_at_birth,
    MIN(Freedom_to_make_life_choices) AS Min_Freedom_to_make_life_choices,
    MAX(Freedom_to_make_life_choices) AS Max_Freedom_to_make_life_choices,
    AVG(Freedom_to_make_life_choices) AS Avg_Freedom_to_make_life_choices,
    MIN(Generosity) AS Min_Generosity,
    MAX(Generosity) AS Max_Generosity,
    AVG(Generosity) AS Avg_Generosity,
    MIN(Perceptions_of_corruption) AS Min_Perceptions_of_corruption,
    MAX(Perceptions_of_corruption) AS Max_Perceptions_of_corruption,
    AVG(Perceptions_of_corruption) AS Avg_Perceptions_of_corruption,
    MIN(Positive_affect) AS Min_Positive_affect,
    MAX(Positive_affect) AS Max_Positive_affect,
    AVG(Positive_affect) AS Avg_Positive_affect,
    MIN(Negative_affect) AS Min_Negative_affect,
    MAX(Negative_affect) AS Max_Negative_affect,
    AVG(Negative_affect) AS Avg_Negative_affect
FROM temp_wh_data;

-- Step 4: Data Exploration

-- View the first 10 rows of the data
SELECT * FROM temp_wh_data LIMIT 10;

-- Get the number of rows in the dataset
SELECT COUNT(*) AS Total_rows FROM temp_wh_data;

-- Check for missing values in each column
SELECT 
    SUM(CASE WHEN Life_Ladder IS NULL THEN 1 ELSE 0 END) AS Missing_Life_Ladder,
    SUM(CASE WHEN Log_GDP_per_capita IS NULL THEN 1 ELSE 0 END) AS Missing_Log_GDP_per_capita,
    SUM(CASE WHEN Social_support IS NULL THEN 1 ELSE 0 END) AS Missing_Social_support,
    SUM(CASE WHEN Healthy_life_expectancy_at_birth IS NULL THEN 1 ELSE 0 END) AS Missing_Healthy_life_expectancy_at_birth,
    SUM(CASE WHEN Freedom_to_make_life_choices IS NULL THEN 1 ELSE 0 END) AS Missing_Freedom_to_make_life_choices,
    SUM(CASE WHEN Generosity IS NULL THEN 1 ELSE 0 END) AS Missing_Generosity,
    SUM(CASE WHEN Perceptions_of_corruption IS NULL THEN 1 ELSE 0 END) AS Missing_Perceptions_of_corruption,
    SUM(CASE WHEN Positive_affect IS NULL THEN 1 ELSE 0 END) AS Missing_Positive_affect,
    SUM(CASE WHEN Negative_affect IS NULL THEN 1 ELSE 0 END) AS Missing_Negative_affect
FROM temp_wh_data;

-- Check for unique values in categorical columns
SELECT DISTINCT Country_name, COUNT(*) AS Count FROM temp_wh_data GROUP BY Country_name ORDER BY Count DESC;
SELECT DISTINCT Year, COUNT(*) AS Count FROM temp_wh_data GROUP BY Year ORDER BY Year;
