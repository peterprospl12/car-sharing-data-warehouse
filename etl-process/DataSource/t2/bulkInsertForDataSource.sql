USE TraficarDefaultDatabase;


-- Import danych do tabeli Users
BULK INSERT Users
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\users.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
	CODEPAGE = '1250', 
    TABLOCK
);

-- Import danych do tabeli Cars
BULK INSERT Cars
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\cars.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Pricelists
BULK INSERT Pricelists
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\pricelists.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli CarsStates
BULK INSERT CarsStates
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\cars_states.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Rentals
BULK INSERT Rentals
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\rentals.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);
