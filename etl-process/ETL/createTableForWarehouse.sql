USE CarSharing
GO

/*
DROP TABLE IF EXISTS Car;
DROP TABLE IF EXISTS Date;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS [User];
DROP TABLE IF EXISTS Time;
DROP TABLE IF EXISTS Rental;
*/

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2024-11-10 15:00:36.016

-- tables
-- Table: Car (DT, SCD 2)
CREATE TABLE Car (
    CarID int IDENTITY(1,1) NOT NULL,
	LicensePlateNumberBK varchar(15)  NOT NULL UNIQUE,
    Brand varchar(30)  NOT NULL,
    Model varchar(30)  NOT NULL,
    Class varchar(10)  NOT NULL,
    EnginePowerCategory varchar(10)  NOT NULL,
    Transmission varchar(10)  NOT NULL,
    InsertionDate date  NOT NULL,
    DisactivationDate date,
    CONSTRAINT Car_pk PRIMARY KEY (CarID)
);

-- Table: Date (DT)
CREATE TABLE Date (
    DateID int IDENTITY(1,1) NOT NULL,
	DateBK varchar(10) NOT NULL,
    Day int  NOT NULL,
    Year int  NOT NULL,
    Month varchar(10)  NOT NULL,
    MonthNo int  NOT NULL,
    DayOfWeek varchar(10)  NOT NULL,
    DayOfWeekNo int  NOT NULL,
    CONSTRAINT Date_pk PRIMARY KEY (DateID),
	CONSTRAINT Date_bk UNIQUE (Year, MonthNo, Day)
);

-- Table: Location (DT)
CREATE TABLE Location (
    LocationID int IDENTITY(1,1) NOT NULL,
    City varchar(30)  NOT NULL,
    District varchar(30)  NOT NULL,
    CONSTRAINT Location_pk PRIMARY KEY (LocationID)
);

-- Table: Rental (FT)
CREATE TABLE Rental ( 
    RentalID int IDENTITY(1,1) NOT NULL,
	StartDateID int NOT NULL,
	StartTimeID int NOT NULL,
	UserID int NOT NULL,
	CarID int NOT NULL,
	StartLocationID int NOT NULL,
	EndLocationID int NOT NULL,
	WasDamaged varchar(10) NOT NULL,
	RepairCost money NOT NULL, 
	RentalCost money NOT NULL,
	DrivenKm int NOT NULL,
	LayoverTime int NOT NULL,
	RentalDuration int NOT NULL,
	DriverAge int NOT NULL,
	YearsOfDrivingExperience int NOT NULL, 
	CONSTRAINT Rental_pk UNIQUE (UserID, CarID, StartLocationID, EndLocationID, StartTimeID, StartDateID)
);

-- Table: Time (DT)
CREATE TABLE Time (
    TimeID int IDENTITY(1,1) NOT NULL,
	TimeBK varchar(5) NOT NULL,
    Hour int  NOT NULL,
    Minute int  NOT NULL,
    CONSTRAINT Time_pk PRIMARY KEY (TimeID),
	CONSTRAINT Time_bk UNIQUE (Hour, Minute)
);

-- Table: User (DT, SCD 2)
CREATE TABLE [User] (
    UserID int IDENTITY(1,1) NOT NULL,
    PESELBK varchar(11) NOT NULL UNIQUE,
    NameAndSurname varchar(60) NOT NULL,
    Nationality varchar(30) NOT NULL,
    Gender varchar(10) NOT NULL,
    DrivingExperienceCategory varchar(15) NOT NULL,
    AgeCategory varchar(15) NOT NULL,
    InsertionDate date NOT NULL,
    DisactivationDate date,
    CONSTRAINT User_pk PRIMARY KEY (UserID)
);


-- foreign keys
-- Reference: Rental (FT)_Car (DT) (table: Rental (FT))
ALTER TABLE Rental ADD CONSTRAINT Rental_Car
    FOREIGN KEY (CarID)
    REFERENCES Car (CarID)  
;

-- Reference: Rental (FT)_End_Location (DT) (table: Rental (FT))
ALTER TABLE Rental ADD CONSTRAINT Rental_EndLocation
    FOREIGN KEY (EndLocationID)
    REFERENCES Location (LocationID)  
;

-- Reference: Rental (FT)_Start_Date (DT) (table: Rental (FT))
ALTER TABLE Rental ADD CONSTRAINT Rental_StartDate
    FOREIGN KEY (StartDateID)
    REFERENCES Date (DateID)  
;

-- Reference: Rental (FT)_Start_Location (DT) (table: Rental (FT))
ALTER TABLE Rental ADD CONSTRAINT Rental_Start_Location
    FOREIGN KEY (StartLocationID)
    REFERENCES Location (LocationID)  
;

-- Reference: Rental (FT)_Start_Time (DT) (table: Rental (FT))
ALTER TABLE Rental ADD CONSTRAINT Rental_StartTime
    FOREIGN KEY (StartTimeID)
    REFERENCES Time (TimeID)  
;

-- Reference: Rental (FT)_User (DT, SCD 2) (table: Rental (FT))
ALTER TABLE Rental ADD CONSTRAINT Rental_User
    FOREIGN KEY (UserID)
    REFERENCES [User] (UserID)  
;

-- End of file.