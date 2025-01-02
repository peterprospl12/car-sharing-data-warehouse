USE CarSharing
GO

IF (OBJECT_ID('dbo.Staging_Cars') IS NOT NULL) 
    DROP TABLE dbo.Staging_Cars;
	
CREATE TABLE Staging_Cars (
    CarBK varchar(15),
    Brand nvarchar(50),
    Model nvarchar(50),
    EnginePower int,
    Transmission nvarchar(10)
);

INSERT INTO Staging_Cars
SELECT License_plate_number, Brand, Model, Engine_power, 
       CASE WHEN Manual = 1 THEN 'Manual' ELSE 'Automatic' END AS Transmission
FROM TraficarDefaultDatabase.dbo.Cars;

IF (OBJECT_ID('dbo.LuxuryTemp') IS NOT NULL) 
    DROP TABLE dbo.LuxuryTemp;

CREATE TABLE dbo.LuxuryTemp (
    Brand VARCHAR(100),
    Model VARCHAR(100),
    Luxury INT  -- 0 = Basic, 1 = Comfort, 2 = Luxury
);
GO

DECLARE @ETLDate DATETIME = '2025-01-01';

BULK INSERT dbo.LuxuryTemp
--FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\ETL\cars_luxury.csv'
FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\etl-process\ETL\cars_luxury.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

MERGE INTO Car AS Target
USING Staging_Cars AS Source
ON Target.LicensePlateNumberBK = Source.CarBK
WHEN MATCHED AND 
     (Target.Brand != Source.Brand 
      OR Target.Model != Source.Model 
      OR Target.EnginePowerCategory != 
         CASE 
             WHEN Source.EnginePower < 110 THEN 'Small' 
             WHEN Source.EnginePower BETWEEN 110 AND 180 THEN 'Average' 
             ELSE 'Big' 
         END) THEN
    UPDATE SET DisactivationDate = @ETLDate;

INSERT INTO Car (LicensePlateNumberBK, Brand, Model, Class, EnginePowerCategory, Transmission, InsertionDate)
SELECT 
    Source.CarBK, 
    Source.Brand, 
    Source.Model, 
    CASE
        WHEN LuxuryTemp.Luxury = 0 THEN 'Basic'
        WHEN LuxuryTemp.Luxury = 1 THEN 'Comfort'
        WHEN LuxuryTemp.Luxury = 2 THEN 'Luxury'
        ELSE 'Unknown'
    END AS Class,
    CASE 
        WHEN Source.EnginePower < 110 THEN 'Small' 
        WHEN Source.EnginePower BETWEEN 110 AND 180 THEN 'Average' 
        ELSE 'Big' 
    END AS EnginePowerCategory,
    Source.Transmission, 
    @ETLDate
FROM Staging_Cars AS Source
LEFT JOIN Car AS Target
    ON Target.LicensePlateNumberBK = Source.CarBK
LEFT JOIN dbo.LuxuryTemp AS LuxuryTemp
    ON Source.Brand = LuxuryTemp.Brand 
    AND Source.Model = LuxuryTemp.Model
WHERE 
    (Target.LicensePlateNumberBK IS NULL 
     OR Target.DisactivationDate IS NOT NULL
     OR Target.EnginePowerCategory != 
         CASE 
             WHEN Source.EnginePower < 110 THEN 'Small' 
             WHEN Source.EnginePower BETWEEN 110 AND 180 THEN 'Average' 
             ELSE 'Big' 
         END)
    AND NOT EXISTS (
        SELECT 1
        FROM Car AS Target2
        WHERE Target2.LicensePlateNumberBK = Source.CarBK
        AND Target2.DisactivationDate IS NULL
    );

GO

DROP TABLE dbo.Staging_Cars;
DROP TABLE dbo.LuxuryTemp;