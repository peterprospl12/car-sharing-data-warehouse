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
    (3, 'Warszawa', 'Mokot�w'),
    (4, 'Warszawa', 'Praga P�noc'),
    (5, 'Warszawa', 'Praga Po�udnie'),
    (6, 'Warszawa', 'Ochota'),
    (7, 'Warszawa', 'Wola'),
    (8, 'Warszawa', 'Bielany'),
    (9, 'Warszawa', '�oliborz'),
    (10, 'Krak�w', 'Stare Miasto'),
    (11, 'Krak�w', 'Kazimierz'),
    (12, 'Krak�w', 'Nowa Huta'),
    (13, 'Krak�w', 'Podg�rze'),
    (14, 'Krak�w', 'Grzeg�rzki'),
    (15, 'Krak�w', 'D�bniki'),
    (16, 'Gda�sk', 'Wrzeszcz'),
    (17, 'Gda�sk', '�r�dmie�cie'),
    (18, 'Gda�sk', 'Oliwa'),
    (19, 'Gda�sk', 'Przymorze'),
    (20, 'Gda�sk', 'Zaspa'),
    (21, 'Gda�sk', 'Osowa'),
    (22, 'Wroc�aw', 'Stare Miasto'),
    (23, 'Wroc�aw', 'Krzyki'),
    (24, 'Wroc�aw', 'Fabryczna'),
    (25, 'Wroc�aw', '�r�dmie�cie'),
    (26, 'Wroc�aw', 'Psie Pole'),
    (27, 'Wroc�aw', 'Bielany Wroc�awskie'),
    (28, 'Pozna�', 'Stare Miasto'),
    (29, 'Pozna�', 'Je�yce'),
    (30, 'Pozna�', 'Wilda'),
    (31, 'Pozna�', '�azarz'),
    (32, 'Pozna�', 'Grunwald'),
    (33, 'Pozna�', 'Rataje'),
    (34, '��d�', '�r�dmie�cie'),
    (35, '��d�', 'Widzew'),
    (36, '��d�', 'Ba�uty'),
    (37, '��d�', 'Polesie'),
    (38, '��d�', 'G�rna'),
    (39, '��d�', 'Anders'),
    (40, '��d�', 'Retkinia');
