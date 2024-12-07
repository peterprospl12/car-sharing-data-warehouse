-- Load data into the Rental fact table
INSERT INTO Rental (
    StartDateID, 
    StartTimeID, 
    UserID, 
    CarID, 
    StartLocationID, 
    EndLocationID, 
    WasDamaged, 
    RepairCost, 
    RentalCost, 
    DrivenKm, 
    LayoverTime, 
    RentalDuration, 
    DriverAge, 
    YearsOfDrivingExperience
)
SELECT 
    d.DateID AS StartDateID,
    t.TimeID AS StartTimeID,
    u.UserID,
    c.CarID,
    sl.LocationID AS StartLocationID,
    el.LocationID AS EndLocationID,
    CASE WHEN rs.Is_broken = 1 THEN 'Yes' ELSE 'No' END AS WasDamaged,
    0 AS RepairCost, -- Assuming no repair cost data available
    r.Total_cost AS RentalCost,
    r.Driven_km AS DrivenKm,
    r.Layover_time AS LayoverTime,
    DATEDIFF(MINUTE, r.Rental_date_start, r.Rental_date_end) AS RentalDuration,
    DATEDIFF(YEAR, su.BirthDate, GETDATE()) AS DriverAge,
    DATEDIFF(YEAR, su.LicenseReceivingDate, GETDATE()) AS YearsOfDrivingExperience
FROM TraficarDefaultDatabase.dbo.Rentals AS r
JOIN Date AS d ON d.DateBK = CONVERT(varchar, YEAR(r.Rental_date_start)) + '-' + RIGHT('00' + CONVERT(varchar, MONTH(r.Rental_date_start)), 2) + '-' + RIGHT('00' + CONVERT(varchar, DAY(r.Rental_date_start)), 2)
JOIN Time AS t ON t.TimeBK = RIGHT('00' + CONVERT(varchar, DATEPART(HOUR, r.Rental_date_start)), 2) + ':' + RIGHT('00' + CONVERT(varchar, DATEPART(MINUTE, r.Rental_date_start)), 2)
JOIN [User] AS u ON u.UserID = r.User_ID
JOIN Staging_Users AS su ON su.UserBK = u.PESELBK
JOIN Car AS c ON c.CarID = r.Car_State_ID
JOIN Location AS sl ON sl.City = r.Start_location -- Assuming Start_location contains city name
JOIN Location AS el ON el.City = r.End_location -- Assuming End_location contains city name
JOIN TraficarDefaultDatabase.dbo.CarsStates AS rs ON rs.CarState_ID = r.Car_State_ID;