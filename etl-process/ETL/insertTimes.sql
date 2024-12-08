USE CarSharing
GO


-- Inserting all possible Times in a Day (00:00 - 23:59) to Time table
INSERT INTO Time (TimeBK, Hour, Minute)
SELECT 
    RIGHT('00' + CONVERT(varchar, h), 2) + ':' + RIGHT('00' + CONVERT(varchar, m), 2) AS TimeBK, -- Format HH:mm
    h AS Hour,
	m AS Minute
FROM (
    SELECT TOP (24) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS h FROM sys.objects
) AS hours
CROSS JOIN (
    SELECT TOP (60) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS m FROM sys.objects
) AS minutes;