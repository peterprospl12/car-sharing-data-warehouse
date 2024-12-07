-- Update existing records by setting DisactivationDate
MERGE INTO Car AS Target
USING Staging_Cars AS Source
ON Target.LicensePlateNumberBK = Source.CarBK
WHEN MATCHED AND (Target.Brand != Source.Brand OR Target.Model != Source.Model) THEN
    UPDATE SET DisactivationDate = GETDATE();

-- Insert new records
INSERT INTO Car (LicensePlateNumberBK, Brand, Model, Class, EnginePowerCategory, Transmission, InsertionDate)
SELECT Source.CarBK, Source.Brand, Source.Model, 'Luxury', 
       CASE WHEN Source.EnginePower < 100 THEN 'Low' ELSE 'High' END,
       Source.Transmission, GETDATE()
FROM Staging_Cars AS Source
LEFT JOIN Car AS Target
ON Target.LicensePlateNumberBK = Source.CarBK
WHERE Target.LicensePlateNumberBK IS NULL OR Target.DisactivationDate IS NOT NULL;

-- Update existing records by setting DisactivationDate
MERGE INTO [User] AS Target
USING Staging_Users AS Source
ON Target.PESELBK = Source.UserBK
WHEN MATCHED AND (Target.NameAndSurname != Source.FirstName + ' ' + Source.LastName OR Target.Nationality != Source.Nationality) THEN
    UPDATE SET DisactivationDate = GETDATE();

-- Insert new records
INSERT INTO [User] (PESELBK, NameAndSurname, Nationality, Gender, DrivingExperienceCategory, AgeCategory, InsertionDate)
SELECT 
    Source.UserBK, 
    Source.FirstName + ' ' + Source.LastName, 
    Source.Nationality, 
    CASE 
        WHEN CAST(SUBSTRING(Source.UserBK, 10, 1) AS INT) % 2 = 0 THEN 'Woman'
        ELSE 'Man'
    END AS Gender,
    CASE 
        WHEN DATEDIFF(YEAR, Source.LicenseReceivingDate, GETDATE()) <= 2 THEN 'Beginner'
        WHEN DATEDIFF(YEAR, Source.LicenseReceivingDate, GETDATE()) <= 10 THEN 'Experienced'
        ELSE 'Advanced'
    END AS DrivingExperienceCategory,
    CASE 
        WHEN DATEDIFF(YEAR, Source.BirthDate, GETDATE()) BETWEEN 18 AND 24 THEN 'Young'
        WHEN DATEDIFF(YEAR, Source.BirthDate, GETDATE()) BETWEEN 25 AND 34 THEN 'Young adult'
        WHEN DATEDIFF(YEAR, Source.BirthDate, GETDATE()) BETWEEN 35 AND 60 THEN 'Adult'
        ELSE 'Unknown'
    END AS AgeCategory,
    GETDATE()
FROM Staging_Users AS Source
LEFT JOIN [User] AS Target
ON Target.PESELBK = Source.UserBK
WHERE Target.PESELBK IS NULL OR Target.DisactivationDate IS NOT NULL;