USE TraficarDefaultDatabase;

-- Import danych do tabeli Users
BULK INSERT Users
FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\sql\users.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Cars
BULK INSERT Cars
FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\sql\cars.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Pricelists
BULK INSERT Pricelists
FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\sql\pricelists.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli CarsStates
BULK INSERT CarsStates
FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\sql\cars_states.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Rentals
BULK INSERT Rentals
FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\sql\rentals.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);
