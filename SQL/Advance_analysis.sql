-- Top 25 Company in terms of launch
SELECT TOP 25 Company, COUNT(*)AS Launch_count FROM space_missions_cleaned GROUP BY Company ORDER BY Launch_count DESC

-- Top 10 Company in terms of their total money spent and the average cost per missiom
SELECT TOP 10 
    Company, 
    SUM(Price) AS Total_Budget_Millions,
    COUNT(*) AS Total_Missions,
    ROUND(AVG(Price), 2) AS Avg_Cost_Per_Mission
FROM space_missions_cleaned
WHERE Price > 0
GROUP BY Company
ORDER BY Total_Budget_Millions DESC;

-- Count of Active & Retired Rockets
SELECT RocketStatus, COUNT(*) as Count
FROM space_missions_cleaned
GROUP BY RocketStatus;

-- Count of successful & Failer missions
SELECT MissionStatus, COUNT(*) as Count
FROM space_missions_cleaned
GROUP BY MissionStatus;

-- Historical success rate (86-05) vs Modern success (06-22) For ISRO & NASA
SELECT 
    CASE 
        WHEN Company = 'NASA' THEN 'NASA (USA)'
        WHEN Company= 'ISRO' THEN 'ISRO'
    END AS Entity,
    -- Historical Success Rate (1986 - 2005)
    ROUND(SUM(CASE WHEN Year BETWEEN 1986 AND 2005 AND MissionStatus = 'Success' THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(SUM(CASE WHEN Year BETWEEN 1986 AND 2005 THEN 1 ELSE 0 END), 0), 2) AS SuccessRate_Historical,
    -- Modern Success Rate (2006 - 2026)
    ROUND(SUM(CASE WHEN Year BETWEEN 2006 AND 2022 AND MissionStatus = 'Success' THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(SUM(CASE WHEN Year BETWEEN 2006 AND 2022 THEN 1 ELSE 0 END), 0), 2) AS SuccessRate_Modern,
    -- Total launches for context
    COUNT(*) AS Lifetime_Missions
FROM space_missions_cleaned
WHERE Company = 'NASA' OR Company = 'ISRO'
GROUP BY 
    CASE 
        WHEN Company = 'NASA' THEN 'NASA (USA)'
        WHEN Company = 'ISRO' THEN 'ISRO'
    END;

-- Peak years in terms of succesfull launches
WITH PeakYears AS (
    SELECT 
        Country, 
        Company, 
        Year, 
        COUNT(*) as Success_Count,
        RANK() OVER (PARTITION BY Company ORDER BY COUNT(*) DESC) as Rank_Success
    FROM space_missions_cleaned
    WHERE MissionStatus = 'Success'
      AND (Country IN ('USA', 'Russian Federation', 'India') OR Company IN ('NASA', 'ISRO'))
    GROUP BY Country, Company, Year
)
SELECT Country, Company, Year, Success_Count
FROM PeakYears
WHERE Rank_Success = 1;

-- Success rate for each time of the day
SELECT 
    CASE 
        WHEN DATEPART(HOUR, DateTime) BETWEEN 0 AND 5 THEN 'Night'
        WHEN DATEPART(HOUR, DateTime) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN DATEPART(HOUR, DateTime) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening' 
    END as TimeOfDay,
    COUNT(*) as Total_Missions,
    ROUND(SUM(CASE WHEN MissionStatus = 'Success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as Success_Rate
FROM space_missions_cleaned
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, DateTime) BETWEEN 0 AND 5 THEN 'Night'
        WHEN DATEPART(HOUR, DateTime) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN DATEPART(HOUR, DateTime) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening' 
    END
ORDER BY Success_Rate DESC;
