USE CarSharing


-- Inserting all dates from 2020-01-01 to 2024-12-31 to Date table
INSERT INTO Date (DateID, DateBK, Day, Year, Month, MonthNo, DayOfWeek, DayOfWeekNo)
SELECT 
    ROW_NUMBER() OVER (ORDER BY d) AS DateID,
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


-- Inserting all possible Times in a Day (00:00 - 23:59) to Time table
INSERT INTO Time (TimeID, TimeBK, Hour, Minute)
SELECT 
    ROW_NUMBER() OVER (ORDER BY h, m) AS TimeID,
    RIGHT('00' + CONVERT(varchar, h), 2) + ':' + RIGHT('00' + CONVERT(varchar, m), 2) AS TimeBK, -- Format HH:mm
    h AS Hour,
	m AS Minute
FROM (
    SELECT TOP (24) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS h FROM sys.objects
) AS hours
CROSS JOIN (
    SELECT TOP (60) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS m FROM sys.objects
) AS minutes;


-- Inserting sample locations for Location table
INSERT INTO Location (LocationID, City, District)
VALUES 
    (1, 'Warszawa', 'Centrum'),
    (2, 'Warszawa', 'Bemowo'),
    (3, 'Warszawa', 'Mokotów'),
    (4, 'Warszawa', 'Praga Pó³noc'),
    (5, 'Warszawa', 'Praga Po³udnie'),
    (6, 'Warszawa', 'Ochota'),
    (7, 'Warszawa', 'Wola'),
    (8, 'Warszawa', 'Bielany'),
    (9, 'Warszawa', '¯oliborz'),
    (10, 'Kraków', 'Stare Miasto'),
    (11, 'Kraków', 'Kazimierz'),
    (12, 'Kraków', 'Nowa Huta'),
    (13, 'Kraków', 'Podgórze'),
    (14, 'Kraków', 'Grzegórzki'),
    (15, 'Kraków', 'Dêbniki'),
    (16, 'Gdañsk', 'Wrzeszcz'),
    (17, 'Gdañsk', 'Œródmieœcie'),
    (18, 'Gdañsk', 'Oliwa'),
    (19, 'Gdañsk', 'Przymorze'),
    (20, 'Gdañsk', 'Zaspa'),
    (21, 'Gdañsk', 'Osowa'),
    (22, 'Wroc³aw', 'Stare Miasto'),
    (23, 'Wroc³aw', 'Krzyki'),
    (24, 'Wroc³aw', 'Fabryczna'),
    (25, 'Wroc³aw', 'Œródmieœcie'),
    (26, 'Wroc³aw', 'Psie Pole'),
    (27, 'Wroc³aw', 'Bielany Wroc³awskie'),
    (28, 'Poznañ', 'Stare Miasto'),
    (29, 'Poznañ', 'Je¿yce'),
    (30, 'Poznañ', 'Wilda'),
    (31, 'Poznañ', '£azarz'),
    (32, 'Poznañ', 'Grunwald'),
    (33, 'Poznañ', 'Rataje'),
    (34, '£ódŸ', 'Œródmieœcie'),
    (35, '£ódŸ', 'Widzew'),
    (36, '£ódŸ', 'Ba³uty'),
    (37, '£ódŸ', 'Polesie'),
    (38, '£ódŸ', 'Górna'),
    (39, '£ódŸ', 'Anders'),
    (40, '£ódŸ', 'Retkinia');
