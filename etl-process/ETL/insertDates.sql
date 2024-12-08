USE CarSharing
GO


-- Inserting all dates from 2020-01-01 to 2024-12-31 to Date table
INSERT INTO Date (DateBK, Day, Year, Month, MonthNo, DayOfWeek, DayOfWeekNo)
SELECT 
    CONVERT(varchar, YEAR(d)) + '-' + RIGHT('00' + CONVERT(varchar, MONTH(d)), 2) + '-' + RIGHT('00' + CONVERT(varchar, DAY(d)), 2) AS DateBK, -- Format YYYY-MM-DD
    DAY(d) AS Day,
    YEAR(d) AS Year,
    DATENAME(MONTH, d) AS Month,
    MONTH(d) AS MonthNo,
    DATENAME(WEEKDAY, d) AS DayOfWeek,
    DATEPART(WEEKDAY, d) AS DayOfWeekNo
FROM (
    SELECT DATEADD(DAY, x, '2020-01-01') AS d
    FROM (SELECT TOP (1827) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS x FROM sys.all_objects) AS n
) AS dates;