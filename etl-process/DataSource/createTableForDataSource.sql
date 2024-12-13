USE TraficarDefaultDatabase;
/*
USE TraficarDefaultDatabase;
DELETE FROM Rentals;
DELETE FROM CarsStates;
DELETE FROM Cars;
DELETE FROM Pricelists;
DELETE FROM [Users];
DBCC CHECKIDENT ('Rentals', RESEED, 0);
DBCC CHECKIDENT ('CarsStates', RESEED, 0);
DBCC CHECKIDENT ('Cars', RESEED, 0);
DBCC CHECKIDENT ('Pricelists', RESEED, 0);
DBCC CHECKIDENT ('[Users]', RESEED, 0);

DROP TABLE IF EXISTS Rentals;
DROP TABLE IF EXISTS CarsStates;
DROP TABLE IF EXISTS Cars;
DROP TABLE IF EXISTS Pricelists;
DROP TABLE IF EXISTS Users;
*/
CREATE TABLE Users (
    User_ID INT IDENTITY(1,1) PRIMARY KEY,
    First_name NVARCHAR(50) NOT NULL,
    Last_name NVARCHAR(50) NOT NULL,
    PESEL CHAR(11) UNIQUE NOT NULL,
    Driving_license_ID NVARCHAR(20) UNIQUE,
    License_receiving_date DATE,
    Nationality NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Password NVARCHAR(100) NOT NULL
);

CREATE TABLE Cars (
    Car_ID INT IDENTITY(1,1) PRIMARY KEY,
    Brand NVARCHAR(50) NOT NULL,
    Model NVARCHAR(50) NOT NULL,
    Engine_power INT,
    Manual BIT,
    License_plate_number NVARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE Pricelists (
    Pricelist_ID INT IDENTITY(1,1) PRIMARY KEY,
    Starting_price DECIMAL(10, 2) NOT NULL,
    Layover_price DECIMAL(10, 2),
    Price_per_km DECIMAL(10, 2)
);

CREATE TABLE CarsStates (
    CarState_ID INT IDENTITY(1,1) PRIMARY KEY,
    Is_broken BIT DEFAULT 0,
    Is_used BIT DEFAULT 0,
    Location NVARCHAR(100),
    Active BIT DEFAULT 1,
    Car_ID INT NULL FOREIGN KEY REFERENCES Cars(Car_ID) ON DELETE SET NULL,
    Pricelist_ID INT NULL FOREIGN KEY REFERENCES Pricelists(Pricelist_ID) ON DELETE SET NULL
);

CREATE TABLE Rentals (
    Rental_ID INT IDENTITY(1,1) PRIMARY KEY,
    Rental_date_start DATETIME NOT NULL,
    Rental_date_end DATETIME,
    Start_location NVARCHAR(255) NOT NULL,
    End_location NVARCHAR(255),
    Driven_km DECIMAL(10, 2),
    Layover_time DECIMAL(5, 2),
    Total_cost DECIMAL(10, 2),
    Car_State_ID INT FOREIGN KEY REFERENCES CarsStates(CarState_ID),
    User_ID INT FOREIGN KEY REFERENCES Users(User_ID)
);