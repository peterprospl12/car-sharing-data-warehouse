CREATE TABLE Users (
                       User_ID SERIAL PRIMARY KEY,
                       First_name VARCHAR(50) NOT NULL,
                       Last_name VARCHAR(50) NOT NULL,
                       PESEL VARCHAR(11) UNIQUE NOT NULL,
                       Driving_license_ID VARCHAR(20) UNIQUE,
                       License_receiving_date DATE,
                       Nationality VARCHAR(50),
                       Email VARCHAR(100) UNIQUE NOT NULL,
                       Password VARCHAR(100) NOT NULL
);

CREATE TABLE Cars (
                      Car_ID SERIAL PRIMARY KEY,
                      Brand VARCHAR(50) NOT NULL,
                      Model VARCHAR(50) NOT NULL,
                      Engine_power INTEGER,
                      Manual BOOLEAN,
                      License_plate_number VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE Pricelists (
                            Pricelist_ID SERIAL PRIMARY KEY,
                            Starting_price NUMERIC(10, 2) NOT NULL,
                            Layover_price NUMERIC(10, 2),
                            Price_per_km NUMERIC(10, 2)
);

CREATE TABLE CarsStates (
                            CarState_ID SERIAL PRIMARY KEY,
                            Is_broken BOOLEAN DEFAULT FALSE,
                            Is_used BOOLEAN DEFAULT FALSE,
                            Location VARCHAR(100),
                            Active BOOLEAN DEFAULT TRUE,
                            Car_ID INT REFERENCES Cars(Car_ID) ON DELETE SET NULL,
                            Pricelist_ID INT REFERENCES Pricelists(Pricelist_ID) ON DELETE SET NULL
);

CREATE TABLE Rentals (
                         Rental_ID SERIAL PRIMARY KEY,
                         Rental_date_start TIMESTAMP NOT NULL,
                         Rental_date_end TIMESTAMP,
                         Start_location VARCHAR(255) NOT NULL,
                         End_location VARCHAR(255),
                         Driven_km NUMERIC(10, 2),
                         Layover_time NUMERIC(5, 2),
                         Total_cost NUMERIC(10, 2),
                         Car_State_ID INTEGER REFERENCES CarsStates(CarState_ID),
                         User_ID INTEGER REFERENCES Users(User_ID)
);

