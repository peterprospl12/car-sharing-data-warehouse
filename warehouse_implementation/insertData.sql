USE CarSharing

-- Inserting all dates from 2020-01-01 to 2024-12-31 to Date table
INSERT INTO Date (DateID, Day, Year, Month, MonthNo, DayOfWeek, DayOfWeekNo)
SELECT 
    ROW_NUMBER() OVER (ORDER BY d) AS DateID,
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

-- Inserting all possible Times in a Day (00:00 - 23:59)
INSERT INTO Time (TimeID, Hour, Minute)
SELECT 
    ROW_NUMBER() OVER (ORDER BY h, m) AS TimeID,
    h AS Hour,
    m AS Minute
FROM (
    SELECT TOP (24) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS h FROM sys.objects
) AS hours
CROSS JOIN (
    SELECT TOP (60) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS m FROM sys.objects
) AS minutes;

-- Inserting 3 sample cars for Car table
INSERT INTO Car (CarID, Brand, Model, Class, EnginePowerCategory, Transmission, LicensePlateNumber, InsertionDate, DisactivationDate)
VALUES 
    (1, 'Toyota', 'Corolla', 'Basic', 'Avarage', 'Automatic', 'GD517GK', '2022-01-01', NULL),
    (2, 'BMW', 'X5', 'Luxury', 'Big', 'Automatic', 'WB12F87', '2023-06-01', NULL),
    (3, 'Audi', 'A5', 'Comfort', 'Avarage', 'Manual', 'W0W1MAL', '2021-03-15', NULL);

-- Inserting 4 sample locations for Location table
INSERT INTO Location (LocationID, City, District)
VALUES 
    (1, 'Warszawa', 'Centrum'),
    (2, 'Warszawa', 'Bemowo'),
    (3, 'Gdañsk', 'Wrzeszcz'),
	(4, 'Gdañsk', 'G³ówny');

-- Inserting 3 sample users for User table
INSERT INTO [User] (UserID, PESEL, NameAndSurname, Nationality, Gender, DrivingExperienceCategory, AgeCategory, InsertionDate, DisactivationDate)
VALUES 
    (1, 12345678901, 'Piotr Sulewski', 'Polska', 'male', 'Advanced', 'Elderly', '2020-01-01', NULL),
    (2, 23456789012, 'Tomasz Sankowski', 'Polska', 'male', 'Intermediate', 'Adult', '2021-05-10', NULL),
    (3, 34567890123, 'Anna Sysoeva', 'Rosja', 'female', 'Beginner', 'Young', '2022-09-20', NULL);

-- Inserting 5 sample facts of rentals to Rental table
INSERT INTO Rental (StartDateID, StartTimeID, UserID, CarID, StartLocationID, EndLocationID, WasDamaged, RepairCost, RentalCost, DrivenKm, LayoverTime, RentalDuration, DriverAge, YearsOfDrivingExperience)
VALUES
    (1700, 360, 1, 1, 1, 2, 'No', 0, 100.00, 45, 30, 60, 62, 40),
    (1600, 735, 2, 2, 4, 3, 'No', 0, 200.00, 100, 0, 120, 38, 7),
    (1500, 1200, 3, 3, 3, 4, 'No', 0, 50.00, 20, 10, 75, 20, 2),
    (1550, 1297, 1, 2, 1, 2, 'No', 0, 78.00, 32, 5, 120, 62, 40),
    (1800, 270, 2, 3, 2, 1, 'Yes', 2500.00, 15.50, 5, 30, 41, 38, 7);
