-- Import danych do tabeli Users
COPY Users (User_ID, First_name, Last_name, PESEL, Driving_license_ID, License_receiving_date, Nationality, Email, Password)
    FROM '/tmp/data/users.csv'
    DELIMITER ','
    CSV HEADER;

-- Import danych do tabeli Cars
COPY Cars (Car_ID, Brand, Model, Engine_power, Manual, License_plate_number)
    FROM '/tmp/data/cars.csv'
    DELIMITER ','
    CSV HEADER;

-- Import danych do tabeli Pricelists
COPY Pricelists (Pricelist_ID, Starting_price, Layover_price, Price_per_km)
    FROM '/tmp/data/pricelists.csv'
    DELIMITER ','
    CSV HEADER;

-- Import danych do tabeli CarsStates
COPY CarsStates (CarState_ID, Is_broken, Is_used, Location, Active, Car_ID, Pricelist_ID)
    FROM '/tmp/data/cars_states.csv'
    DELIMITER ','
    CSV HEADER;

-- Import danych do tabeli Rentals
COPY Rentals (Rental_ID, Rental_date_start, Rental_date_end, Start_location, End_location, Driven_km, Layover_time, Total_cost, Car_State_ID, User_ID)
    FROM '/tmp/data/rentals.csv'
    DELIMITER ','
    CSV HEADER;
