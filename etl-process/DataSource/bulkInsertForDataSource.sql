USE TraficarDefaultDatabase;


-- Import danych do tabeli Users
BULK INSERT Users
--FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\users.csv'
--FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\etl-process\DataSource\t2\users.csv'
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\users.csv'
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
--FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\cars.csv'
--FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\etl-process\DataSource\t2\cars.csv'
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\cars.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Pricelists
BULK INSERT Pricelists
--FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\pricelists.csv'
--FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\etl-process\DataSource\t2\pricelists.csv'
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\pricelists.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli CarsStates
BULK INSERT CarsStates
--FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\cars_states.csv'
--FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\etl-process\DataSource\t2\cars_states.csv'
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\cars_states.csv'

WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Import danych do tabeli Rentals
BULK INSERT Rentals
--FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\etl-process\DataSource\t2\rentals.csv'
--FROM 'C:\Users\Tomasz\Desktop\car-sharing-data-warehouse\etl-process\DataSource\t2\rentals.csv'
FROM 'C:\Users\Piotr\PycharmProjects\car-sharing-data-warehouse\rentals.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK
);
