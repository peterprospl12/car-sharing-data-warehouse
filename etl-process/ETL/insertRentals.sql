USE CarSharing;
GO

IF OBJECT_ID('dbo.DamageTemp') IS NOT NULL 
    DROP TABLE dbo.DamageTemp;

IF OBJECT_ID('dbo.CityLocations') IS NOT NULL
    DROP TABLE dbo.CityLocations;

CREATE TABLE dbo.DamageTemp (
    Car_id INT,
    Car_brand VARCHAR(100),
    Car_model VARCHAR(100),
    Damage_report_date DATETIME,
    User_id INT,
    Rental_id INT,
    Repair_cost MONEY,
    Description VARCHAR(100)
);
GO

DECLARE @ETLDate DATETIME = '2025-01-01';

BULK INSERT dbo.DamageTemp
--FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\damages.csv'
FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\etl-process\DataSource\t2\damages.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

CREATE TABLE CityLocations (
    LocationID INT PRIMARY KEY,
    City VARCHAR(100),
    Latitude FLOAT,
    Longitude FLOAT
);

INSERT INTO CityLocations (LocationID, City, Latitude, Longitude)
VALUES
    (1, 'Warszawa', 52.2297, 21.0122),
    (2, 'Kraków', 50.0647, 19.9450),
    (3, 'Gdañsk', 54.3520, 18.6466),
    (4, 'Wroc³aw', 51.1079, 17.0385),
    (5, 'Poznañ', 52.4064, 16.9252),
    (6, '£ódŸ', 51.7592, 19.4560);

WITH AggregatedDamages AS (
    SELECT 
        Rental_id,
        SUM(Repair_cost) AS TotalRepairCost
    FROM dbo.DamageTemp
    GROUP BY Rental_id
),
ParsedLocations AS (
    SELECT 
        r.Rental_ID,
        -- Wydzielanie StartLatitude (pierwsza liczba przed spacj¹)
        CAST(SUBSTRING(r.Start_location, 1, CHARINDEX(' ', r.Start_location) - 1) AS FLOAT) AS StartLatitude,
        -- Wydzielanie StartLongitude (druga liczba po spacji)
        CAST(SUBSTRING(r.Start_location, CHARINDEX(' ', r.Start_location) + 1, LEN(r.Start_location)) AS FLOAT) AS StartLongitude,
        -- Wydzielanie EndLatitude (pierwsza liczba przed spacj¹)
        CAST(SUBSTRING(r.End_location, 1, CHARINDEX(' ', r.End_location) - 1) AS FLOAT) AS EndLatitude,
        -- Wydzielanie EndLongitude (druga liczba po spacji)
        CAST(SUBSTRING(r.End_location, CHARINDEX(' ', r.End_location) + 1, LEN(r.End_location)) AS FLOAT) AS EndLongitude
    FROM TraficarDefaultDatabase.dbo.Rentals AS r
),
MatchedCities AS (
    SELECT 
        pl.Rental_ID,
        locStart.City AS StartCity,
        locEnd.City AS EndCity
    FROM ParsedLocations AS pl
    LEFT JOIN CityLocations AS locStart 
        ON ABS(pl.StartLatitude - locStart.Latitude) <= 0.2
        AND ABS(pl.StartLongitude - locStart.Longitude) <= 0.2
    LEFT JOIN CityLocations AS locEnd 
        ON ABS(pl.EndLatitude - locEnd.Latitude) <= 0.2
        AND ABS(pl.EndLongitude - locEnd.Longitude) <= 0.2
),
RandomLocations AS (
    SELECT 
        City,
        LocationID,
        ROW_NUMBER() OVER (PARTITION BY City ORDER BY NEWID()) AS RandomOrder
    FROM CarSharing.dbo.Location
),
SelectedLocations AS (
    SELECT 
        mc.Rental_ID,
        startLoc.LocationID AS StartLocationID,
        endLoc.LocationID AS EndLocationID
    FROM MatchedCities AS mc
    LEFT JOIN RandomLocations AS startLoc 
        ON startLoc.City = mc.StartCity AND startLoc.RandomOrder = 1
    LEFT JOIN RandomLocations AS endLoc 
        ON endLoc.City = mc.EndCity AND endLoc.RandomOrder = 1
)

INSERT INTO Rental (
    StartDateID, 
    StartTimeID, 
    UserID, 
    CarID, 
    StartLocationID, 
    EndLocationID, 
    WasDamaged, 
    RepairCost, 
    RentalCost, 
    DrivenKm, 
    LayoverTime, 
    RentalDuration, 
    DriverAge, 
    YearsOfDrivingExperience
)
SELECT 
    d.DateID AS StartDateID,
    t.TimeID AS StartTimeID,
    u.UserID AS UserID,
    c.CarID AS CarID,
    sel.StartLocationID AS StartLocationID,
    sel.EndLocationID AS EndLocationID,
    CASE 
        WHEN dmg.Rental_id IS NOT NULL THEN 'Damaged'
        ELSE 'Undamaged'
    END AS WasDamaged,
    COALESCE(dmg.TotalRepairCost, 0) AS RepairCost,
    r.Total_cost AS RentalCost,
    r.Driven_km AS DrivenKm,
    r.Layover_time AS LayoverTime,
    DATEDIFF(MINUTE, r.Rental_date_start, r.Rental_date_end) AS RentalDuration,
    DATEDIFF(YEAR, CAST(
        CASE 
            WHEN SUBSTRING(su.PESEL, 3, 2) > 20 THEN '20' + SUBSTRING(su.PESEL, 1, 2) 
            ELSE '19' + SUBSTRING(su.PESEL, 1, 2) 
        END + '-' + 
        RIGHT('00' + CAST(CAST(SUBSTRING(su.PESEL, 3, 2) AS INT) % 20 AS VARCHAR), 2) + '-' + 
        SUBSTRING(su.PESEL, 5, 2) AS DATE
    ), @ETLDate) AS DriverAge,
    DATEDIFF(YEAR, su.License_receiving_date, @ETLDate) AS YearsOfDrivingExperience
FROM TraficarDefaultDatabase.dbo.Rentals AS r
JOIN Date AS d ON d.DateBK = CONVERT(varchar, YEAR(r.Rental_date_start)) + '-' + RIGHT('00' + CONVERT(varchar, MONTH(r.Rental_date_start)), 2) + '-' + RIGHT('00' + CONVERT(varchar, DAY(r.Rental_date_start)), 2)
JOIN Time AS t ON t.TimeBK = RIGHT('00' + CONVERT(varchar, DATEPART(HOUR, r.Rental_date_start)), 2) + ':' + RIGHT('00' + CONVERT(varchar, DATEPART(MINUTE, r.Rental_date_start)), 2)
JOIN TraficarDefaultDatabase.dbo.Users AS su ON su.User_ID = r.User_ID
JOIN [User] AS u ON u.PESELBK = su.PESEL AND u.DisactivationDate IS NULL
JOIN TraficarDefaultDatabase.dbo.CarsStates AS tmp_car_states ON tmp_car_states.CarState_ID = r.Car_State_ID
JOIN TraficarDefaultDatabase.dbo.Cars AS default_car ON default_car.Car_ID = tmp_car_states.Car_ID
JOIN Car AS c ON c.LicensePlateNumberBK = default_car.License_plate_number AND c.DisactivationDate IS NULL
LEFT JOIN AggregatedDamages AS dmg ON dmg.Rental_id = r.Rental_ID
JOIN SelectedLocations AS sel ON sel.Rental_ID = r.Rental_ID
WHERE NOT EXISTS (
    SELECT 1
    FROM RentalSpectator AS rs
    WHERE rs.RentalID = r.Rental_ID
);

INSERT INTO RentalSpectator (RentalID)
SELECT r.Rental_ID
FROM TraficarDefaultDatabase.dbo.Rentals AS r
WHERE NOT EXISTS (
    SELECT 1
    FROM RentalSpectator AS rs
    WHERE rs.RentalID = r.Rental_ID
);

DROP TABLE CityLocations;
DROP TABLE DamageTemp;