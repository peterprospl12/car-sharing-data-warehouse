USE TraficarDefaultDatabase;

-- Import danych do tabeli Users
BULK INSERT Users
FROM 'C:\Users\peter\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\users.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Cars
BULK INSERT Cars
FROM 'C:\Users\peter\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\cars.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Pricelists
BULK INSERT Pricelists
FROM 'C:\Users\peter\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\pricelists.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli CarsStates
BULK INSERT CarsStates
FROM 'C:\Users\peter\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\cars_states.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Rentals
BULK INSERT Rentals
FROM 'C:\Users\peter\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\rentals.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);
