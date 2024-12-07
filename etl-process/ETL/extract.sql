-- Staging tables
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
    (4, 'Warszawa', 'Praga Północ'),
    (5, 'Warszawa', 'Praga Południe'),
    (6, 'Warszawa', 'Ochota'),
    (7, 'Warszawa', 'Wola'),
    (8, 'Warszawa', 'Bielany'),
    (9, 'Warszawa', 'Żoliborz'),
    (10, 'Kraków', 'Stare Miasto'),
    (11, 'Kraków', 'Kazimierz'),
    (12, 'Kraków', 'Nowa Huta'),
    (13, 'Kraków', 'Podgórze'),
    (14, 'Kraków', 'Grzegórzki'),
    (15, 'Kraków', 'Dębniki'),
    (16, 'Gdańsk', 'Wrzeszcz'),
    (17, 'Gdańsk', 'Śródmieście'),
    (18, 'Gdańsk', 'Oliwa'),
    (19, 'Gdańsk', 'Przymorze'),
    (20, 'Gdańsk', 'Zaspa'),
    (21, 'Gdańsk', 'Osowa'),
    (22, 'Wrocław', 'Stare Miasto'),
    (23, 'Wrocław', 'Krzyki'),
    (24, 'Wrocław', 'Fabryczna'),
    (25, 'Wrocław', 'Śródmieście'),
    (26, 'Wrocław', 'Psie Pole'),
    (27, 'Wrocław', 'Bielany Wrocławskie'),
    (28, 'Poznań', 'Stare Miasto'),
    (29, 'Poznań', 'Jeżyce'),
    (30, 'Poznań', 'Wilda'),
    (31, 'Poznań', 'Łazarz'),
    (32, 'Poznań', 'Grunwald'),
    (33, 'Poznań', 'Rataje'),
    (34, 'Łódź', 'Śródmieście'),
    (35, 'Łódź', 'Widzew'),
    (36, 'Łódź', 'Bałuty'),
    (37, 'Łódź', 'Polesie'),
    (38, 'Łódź', 'Górna'),
    (39, 'Łódź', 'Anders'),
    (40, 'Łódź', 'Retkinia');


-- Staging tables
CREATE TABLE Staging_Users (
    UserBK char(11),
    FirstName nvarchar(50),
    LastName nvarchar(50),
    Nationality nvarchar(50),
    DrivingLicenseID nvarchar(20),
    LicenseReceivingDate date,
    BirthDate date
);

CREATE TABLE Staging_Cars (
    CarBK varchar(15),
    Brand nvarchar(50),
    Model nvarchar(50),
    EnginePower int,
    Transmission nvarchar(10)
);

-- Extract data from relational database
INSERT INTO Staging_Users
SELECT 
    PESEL, 
    First_name, 
    Last_name, 
    Nationality, 
    Driving_license_ID, 
    License_receiving_date,
    CAST(
        CASE 
            WHEN SUBSTRING(PESEL, 3, 2) > 20 THEN '20' + SUBSTRING(PESEL, 1, 2) 
            ELSE '19' + SUBSTRING(PESEL, 1, 2) 
        END + '-' + 
        RIGHT('00' + CAST(CAST(SUBSTRING(PESEL, 3, 2) AS INT) % 20 AS VARCHAR), 2) + '-' + 
        SUBSTRING(PESEL, 5, 2) AS DATE
    ) AS BirthDate
FROM TraficarDefaultDatabase.dbo.Users;

INSERT INTO Staging_Cars
SELECT License_plate_number, Brand, Model, Engine_power, 
       CASE WHEN Manual = 1 THEN 'Manual' ELSE 'Automatic' END AS Transmission
FROM TraficarDefaultDatabase.dbo.Cars;

