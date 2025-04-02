USE Team2_FinalProject_DMDD_v2;
GO

-- Create view for Registered Users with Admin details
CREATE VIEW vw_RegisteredUsersWithAdmin AS
SELECT RU.UserID, RU.FirstName, RU.LastName, RU.EmailID, RU.PhoneNumber, RU.Type, 
       A.AdminID, A.FirstName AS AdminFirstName, A.LastName AS AdminLastName
FROM RegisteredUsers RU
JOIN Admin A ON RU.AdminID = A.AdminID;
GO

-- Select data from vw_RegisteredUsersWithAdmin
SELECT * FROM vw_RegisteredUsersWithAdmin;
GO

-- Create view for Admin User Count
CREATE VIEW vw_AdminUserCount AS
SELECT A.AdminID, A.FirstName, A.LastName, COUNT(RU.UserID) AS UserCount
FROM Admin A
LEFT JOIN RegisteredUsers RU ON A.AdminID = RU.AdminID
GROUP BY A.AdminID, A.FirstName, A.LastName;
GO

-- Select data from vw_AdminUserCount
SELECT * FROM vw_AdminUserCount;
GO

-- Create view for Active Drivers Overview
CREATE VIEW vw_ActiveDriversOverview AS
SELECT 
    d.DriverID,
    ru.FirstName + ' ' + ru.LastName AS DriverName,
    d.LicenseNo,
    d.AvailabilityStatus,
    d.TotalCompletedRides,
    d.TotalEarnings,
    d.Rating,
    dl.GeohashID AS CurrentLocation,
    l.City,
    l.State
FROM Driver d
JOIN RegisteredUsers ru ON d.UserID = ru.UserID
JOIN DriverLocation dl ON d.DriverID = dl.DriverID
JOIN Location l ON dl.GeohashID = l.GeohashID;
GO

-- Select data from vw_ActiveDriversOverview
SELECT * FROM vw_ActiveDriversOverview;
GO

-- Create view for Car Rental Performance
CREATE VIEW vw_CarRentalPerformance AS
SELECT 
    r.RenterID,
    ru.FirstName + ' ' + ru.LastName AS RenterName,
    r.CompanyName,
    r.TotalRentedCars,
    r.TotalEarnings,
    r.TotalRentalTime,
    COUNT(rc.CarID) AS CurrentlyRentedCars
FROM Renter r
JOIN RegisteredUsers ru ON r.UserID = ru.UserID
LEFT JOIN Renter_Car rc ON r.RenterID = rc.RenterID
GROUP BY 
    r.RenterID,
    ru.FirstName,
    ru.LastName,
    r.CompanyName,
    r.TotalRentedCars,
    r.TotalEarnings,
    r.TotalRentalTime;
GO

-- Select data from vw_CarRentalPerformance
SELECT * FROM vw_CarRentalPerformance;
GO

-- Create view for Payment Invoice Summary
CREATE VIEW vw_PaymentInvoiceSummary AS
SELECT 
    pr.PaymentID,
    pr.InvoiceID,
    r.RiderID,
    ru.FirstName + ' ' + ru.LastName AS RiderName,
    pr.MethodOfPayment,
    pr.Amount,
    pr.Status AS PaymentStatus,
    i.Distance,
    i.Price AS InvoicePrice,
    tr.RequestTime,
    tr.Status AS TripStatus
FROM PaymentRequest pr
JOIN Invoice i ON pr.InvoiceID = i.InvoiceID
JOIN TripRequest tr ON i.TripRequestID = tr.TripRequestID
JOIN Rider r ON pr.RiderID = r.RiderID
JOIN RegisteredUsers ru ON r.UserID = ru.UserID;
GO

-- Select data from vw_PaymentInvoiceSummary
SELECT * FROM vw_PaymentInvoiceSummary;


SELECT * FROM Location