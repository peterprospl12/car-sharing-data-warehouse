-- Set all Active fields to FALSE before importing new data
UPDATE CarsStates
SET Active = FALSE;

UPDATE Users
SET Nationality = CASE
                      WHEN User_ID IN (SELECT User_ID FROM Users ORDER BY RANDOM() LIMIT 1) THEN 'France'
                      WHEN User_ID IN (SELECT User_ID FROM Users ORDER BY RANDOM() LIMIT 2) THEN 'Greece'
                      ELSE 'England'
    END
WHERE User_ID IN (
    SELECT User_ID FROM Users ORDER BY RANDOM() LIMIT 4
);

-- Import additional data into the Users table
COPY Users (User_ID, First_name, Last_name, PESEL, Driving_license_ID, License_receiving_date, Nationality, Email, Password)
    FROM '/tmp/data/users_additional.csv'
    DELIMITER ','
    CSV HEADER;

-- Import additional data into the Cars table
COPY Cars (Car_ID, Brand, Model, Engine_power, Manual, License_plate_number)
    FROM '/tmp/data/cars_additional.csv'
    DELIMITER ','
    CSV HEADER;

-- Import additional data into the Pricelists table
COPY Pricelists (Pricelist_ID, Starting_price, Layover_price, Price_per_km)
    FROM '/tmp/data/pricelists_additional.csv'
    DELIMITER ','
    CSV HEADER;

-- Import additional data into the CarsStates table
COPY CarsStates (CarState_ID, Is_broken, Is_used, Location, Active, Car_ID, Pricelist_ID)
    FROM '/tmp/data/cars_states_additional.csv'
    DELIMITER ','
    CSV HEADER;

-- Import additional data into the Rentals table
COPY Rentals (Rental_ID, Rental_date_start, Rental_date_end, Start_location, End_location, Driven_km, Layover_time, Total_cost, Car_State_ID, User_ID)
    FROM '/tmp/data/rentals_additional.csv'
    DELIMITER ','
    CSV HEADER;