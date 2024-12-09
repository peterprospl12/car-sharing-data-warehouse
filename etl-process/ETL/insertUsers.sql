USE CarSharing
GO

-- ETL Date
DECLARE @ETLDate DATETIME = '2025-01-01';

-- Extract data from relational database into Temp tables
IF (OBJECT_ID('dbo.Staging_Users') IS NOT NULL) 
    DROP TABLE dbo.Staging_Users;

CREATE TABLE Staging_Users (
    UserBK char(11),
    FirstName nvarchar(50),
    LastName nvarchar(50),
    Nationality nvarchar(50),
    DrivingLicenseID nvarchar(20),
    LicenseReceivingDate date,
    BirthDate date
);

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

-- Update existing records by setting DisactivationDate
MERGE INTO [User] AS Target
USING Staging_Users AS Source
ON Target.PESELBK = Source.UserBK
WHEN MATCHED AND (Target.NameAndSurname != Source.FirstName + ' ' + Source.LastName OR Target.Nationality != Source.Nationality) THEN
    UPDATE SET DisactivationDate = @ETLDate;

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
        WHEN DATEDIFF(YEAR, Source.LicenseReceivingDate, @ETLDate) <= 2 THEN 'Beginner'
        WHEN DATEDIFF(YEAR, Source.LicenseReceivingDate, @ETLDate) <= 5 THEN 'Intermediate'
        WHEN DATEDIFF(YEAR, Source.LicenseReceivingDate, @ETLDate) <= 10 THEN 'Experienced'
        ELSE 'Advanced'
    END AS DrivingExperienceCategory,
    CASE 
        WHEN DATEDIFF(YEAR, Source.BirthDate, @ETLDate) BETWEEN 18 AND 24 THEN 'Young'
        WHEN DATEDIFF(YEAR, Source.BirthDate, @ETLDate) BETWEEN 25 AND 34 THEN 'Young adult'
        WHEN DATEDIFF(YEAR, Source.BirthDate, @ETLDate) BETWEEN 35 AND 60 THEN 'Adult'
        ELSE 'Elderly'
    END AS AgeCategory,
    @ETLDate
FROM Staging_Users AS Source
LEFT JOIN [User] AS Target
ON Target.PESELBK = Source.UserBK
WHERE Target.PESELBK IS NULL OR Target.DisactivationDate IS NOT NULL;

-- Drop temporary tables
DROP TABLE dbo.Staging_Users;