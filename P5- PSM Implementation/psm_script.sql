USE Team2_FinalProject_DMDD;

GO
/**********************STORED PROCEDURE**********************/
/**1. Stored Procedure - AssignDriverToTrip Working Example**/
CREATE PROCEDURE dbo.AssignDriverToTrip
    @TripRequestID VARCHAR(10),
    @DriverID VARCHAR(10),
    @Message VARCHAR(255) OUTPUT
AS
BEGIN
    DECLARE @TripStatus VARCHAR(20);
    DECLARE @PickupGeohash VARCHAR(12);
    DECLARE @DropoffGeohash VARCHAR(12);
    DECLARE @TripState VARCHAR(50);
    DECLARE @DriverAvailabilityStatus VARCHAR(15);
    DECLARE @DriverState VARCHAR(50);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get trip information
        SELECT 
            @TripStatus = Status, 
            @PickupGeohash = PickupGeohashID, 
            @DropoffGeohash = DropoffGeohashID,
            @TripState = State
        FROM TripRequest
        WHERE TripRequestID = @TripRequestID;
        
        -- Get driver information
        SELECT 
            @DriverAvailabilityStatus = AvailabilityStatus
        FROM Driver
        WHERE DriverID = @DriverID;
        
        -- Get driver's current state based on location
        SELECT 
            @DriverState = l.State
        FROM DriverLocation dl
        JOIN Location l ON dl.GeohashID = l.GeohashID
        WHERE dl.DriverID = @DriverID;
        
        -- Process assignment if conditions are met:
        -- 1. Trip is pending
        -- 2. Driver is available
        -- 3. Driver and trip are in the same state
        IF @TripStatus = 'Pending' AND @DriverAvailabilityStatus = 'Available' AND @TripState = @DriverState
        BEGIN
            UPDATE TripRequest
            SET Status = 'Ride-In-Process'
            WHERE TripRequestID = @TripRequestID;
            
            UPDATE Driver
            SET AvailabilityStatus = 'In-Transit'
            WHERE DriverID = @DriverID;
            
            IF EXISTS (SELECT 1 FROM DriverLocation WHERE DriverID = @DriverID)
            BEGIN
                UPDATE DriverLocation
                SET GeohashID = @PickupGeohash, LastUpdated = GETDATE()
                WHERE DriverID = @DriverID;
            END
            ELSE
            BEGIN
                INSERT INTO DriverLocation (DriverID, GeohashID)
                VALUES (@DriverID, @PickupGeohash);
            END
            
            COMMIT TRANSACTION;
            SET @Message = 'Driver'+ @DriverID +'will server the customer for trip'+ @TripRequestID ;
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            IF @TripStatus != 'Pending'
                SET @Message = 'Trip is not in Pending status.';
            ELSE IF @DriverAvailabilityStatus != 'Available'
                SET @Message = 'Driver is not available.';
            ELSE
                SET @Message = 'Driver and trip are not in the same state.';
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
        
        SET @Message = 'Error occurred during the process: ' + ERROR_MESSAGE();
    END CATCH;
END;

GO
--Assigning Driver to a nearby pending trip 
DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.AssignDriverToTrip 
    @TripRequestID = 'TRIP_00004', 
    @DriverID = 'DRIVE00002',
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';

GO

DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.AssignDriverToTrip 
    @TripRequestID = 'TRIP_00010', 
    @DriverID = 'DRIVE00006',
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';

GO

DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.AssignDriverToTrip 
    @TripRequestID = 'TRIP_00016', 
    @DriverID = 'DRIVE00010',
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';

GO
--Driver not available example 
DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.AssignDriverToTrip 
    @TripRequestID = 'TRIP_00018', 
    @DriverID = 'DRIVE00001',
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';

GO


/******Stored Procedure 2 - Marking a Trip as Completed and generating a subsequent Invoice for the same.******/
CREATE PROCEDURE dbo.CompleteTrip
    @TripRequestID VARCHAR(10),
    @Message VARCHAR(255) OUTPUT
AS
BEGIN
    -- Declare necessary variables
    DECLARE @RiderID VARCHAR(10);
    DECLARE @EstimatedDistance DECIMAL(18,8);
    DECLARE @State VARCHAR(50);
    DECLARE @EstimatedCost DECIMAL(18,2);
    DECLARE @InvoiceID VARCHAR(10);

    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT 
            @RiderID = RiderID,
            @EstimatedDistance = EstimatedDistance,
            @State = State,
            @EstimatedCost = EstimatedCost
        FROM TripRequest
        WHERE TripRequestID = @TripRequestID;

        -- Update the trip status to 'Completed'
        UPDATE TripRequest
        SET Status = 'Completed'
        WHERE TripRequestID = @TripRequestID;

        INSERT INTO Invoice (TripRequestID, Distance, Price)
        VALUES (@TripRequestID, @EstimatedDistance, @EstimatedCost);

        SET @InvoiceID = (SELECT InvoiceID FROM Invoice WHERE TripRequestID = @TripRequestID);

        COMMIT TRANSACTION;
        SET @Message = 'Trip completed. Invoice ID: ' + @InvoiceID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
        
        SET @Message = 'Error occurred during the process: ' + ERROR_MESSAGE();
    END CATCH;
END;

GO 

-- Examples of working Completed Trips
DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.CompleteTrip 
    @TripRequestID = 'TRIP_00004', 
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';

GO 

DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.CompleteTrip 
    @TripRequestID = 'TRIP_00008', 
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';

-- Test with non-existent trip ID
DECLARE @ErrorMessage VARCHAR(255);
EXEC dbo.CompleteTrip 
    @TripRequestID = 'TRIP_99999', -- Non-existent ID
    @Message = @ErrorMessage OUTPUT;
SELECT @ErrorMessage AS 'Error Result';

GO 

/******* Stored Procedure 3 - Updating the Driver's Rating *******/
CREATE PROCEDURE dbo.UpdateDriverRating
    @DriverID VARCHAR(10),
    @Rating DECIMAL(3,1),
    @Message VARCHAR(255) OUTPUT
AS
BEGIN
    
    DECLARE @TotalCompletedRides INT;
    DECLARE @CurrentRating DECIMAL(3,1);
    DECLARE @NewRating DECIMAL(3,1);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @Rating < 0 OR @Rating > 5
        BEGIN
            SET @Message = 'Invalid rating. The rating must be between 0 and 5.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SELECT 
            @TotalCompletedRides = TotalCompletedRides,
            @CurrentRating = Rating
        FROM Driver
        WHERE DriverID = @DriverID;
        -- Calculate the new average rating
        -- For the first ride, use the new rating directly
        -- For subsequent rides, calculate weighted average
        IF @TotalCompletedRides = 0
            SET @NewRating = @Rating;
        ELSE
            SET @NewRating = ((@CurrentRating * @TotalCompletedRides) + @Rating) / (@TotalCompletedRides + 1);
        IF @NewRating < 0 SET @NewRating = 0;
        IF @NewRating > 5 SET @NewRating = 5;

        -- Update the driver's rating
        UPDATE Driver
        SET 
            Rating = @NewRating,
            TotalCompletedRides = @TotalCompletedRides + 1
        WHERE DriverID = @DriverID;

        COMMIT TRANSACTION;
        SET @Message = 'Driver rating updated successfully. New rating: ' + CAST(@NewRating AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
        SET @Message = 'Error occurred during the process: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Examples of Updating overall Rating from a new acquired rating for the driver
DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.UpdateDriverRating 
    @DriverID = 'DRIVE00004',
    @Rating = 1.5,
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';

GO

DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.UpdateDriverRating 
    @DriverID = 'DRIVE00003',
    @Rating = 1.5,
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';

GO

/******* Stored Procedure 4 - Processing Payments for the genareted Invoices *******/
CREATE PROCEDURE dbo.ProcessPayment
    @PaymentID VARCHAR(10),
    @MethodOfPayment VARCHAR(25),
    @Message VARCHAR(255) OUTPUT
AS
BEGIN
    DECLARE @InvoiceID VARCHAR(10);
    DECLARE @Status VARCHAR(15);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @MethodOfPayment NOT IN ('Cash', 'Card', 'OnlineWallet')
        BEGIN
            SET @Message = 'Invalid payment method.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Get the invoice ID and status
        SELECT 
            @InvoiceID = InvoiceID
        FROM PaymentRequest
        WHERE PaymentID = @PaymentID;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @Message = 'Payment request not found with ID: ' + @PaymentID;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE PaymentRequest
        SET Status = 'Completed'
        WHERE PaymentID = @PaymentID;

        IF @MethodOfPayment = 'Card'
        BEGIN
            SET @Message = 'Payment processed by Card. Invoice ID: ' + @InvoiceID;
        END
        ELSE IF @MethodOfPayment = 'OnlineWallet'
        BEGIN
            SET @Message = 'Payment processed by Online Wallet. Invoice ID: ' + @InvoiceID;
        END
        ELSE
        BEGIN
            SET @Message = 'Payment processed by Cash. Invoice ID: ' + @InvoiceID;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
        
        SET @Message = 'Error occurred during the process: ' + ERROR_MESSAGE();
    END CATCH;
END;

GO

-- Declare a variable to capture the output message
DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.ProcessPayment 
    @PaymentID = 'PAY_R00005',
    @MethodOfPayment = 'Card',
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';

GO
-- Declare a variable to capture the output message
DECLARE @ResultMessage VARCHAR(255);
EXEC dbo.ProcessPayment 
    @PaymentID = 'PAY_R00006',
    @MethodOfPayment = 'OnlineWallet',
    @Message = @ResultMessage OUTPUT;
SELECT @ResultMessage AS 'Result';


/**********************VIEWS**********************/
USE Team2_FinalProject_DMDD;
GO
/******* View 1 : Registered Users with Admin details *******/
CREATE VIEW vw_RegisteredUsersWithAdmin AS
SELECT RU.UserID, RU.FirstName, RU.LastName, RU.EmailID, RU.PhoneNumber, RU.Type, 
       A.AdminID, A.FirstName AS AdminFirstName, A.LastName AS AdminLastName
FROM RegisteredUsers RU
JOIN Admin A ON RU.AdminID = A.AdminID;
GO
SELECT * FROM vw_RegisteredUsersWithAdmin;


GO
/******* View 2 : View for Admin user count*******/
CREATE VIEW vw_AdminUserCount AS
SELECT A.AdminID, A.FirstName, A.LastName, COUNT(RU.UserID) AS UserCount
FROM Admin A
LEFT JOIN RegisteredUsers RU ON A.AdminID = RU.AdminID
GROUP BY A.AdminID, A.FirstName, A.LastName;
GO
SELECT * FROM vw_AdminUserCount;
GO

/******* View 3 : View for Active Drivers Overview*******/
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
SELECT * FROM vw_ActiveDriversOverview;
GO



/******* View 4 : For Car Rental Performance*******/
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
SELECT * FROM vw_CarRentalPerformance;
GO

/******* View 5 : For Payment Invoice Summary*******/
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
SELECT * FROM vw_PaymentInvoiceSummary;
GO

/********************** TRIGGERS **********************/
-- Drop conflicting triggers if they exist
DROP TRIGGER IF EXISTS TRG_Prevent_Delete_Car;
GO

DROP TRIGGER IF EXISTS TRG_UpdateDriverLocation;
GO

DROP TRIGGER IF EXISTS TRG_CreateInvoice_OnTripCompletion;
GO

/******* DML Trigger 1: To retrieve the updated driver location details*******/
CREATE TRIGGER TRG_UpdateDriverLocation
ON DriverLocation
AFTER UPDATE
AS
BEGIN
    DECLARE @DriverID VARCHAR(10), @GeohashID VARCHAR(12), @LastUpdated DATETIME;
    SELECT @DriverID = DriverID, @GeohashID = GeohashID, @LastUpdated = LastUpdated
    FROM inserted;

    -- Update the last location of the driver
    UPDATE DriverLocation
    SET LastUpdated = GETDATE()
    WHERE DriverID = @DriverID;
END;

-- Step 1: Check current driver location data
SELECT * FROM DriverLocation
WHERE DriverID = 'DRIVE00002';

-- Step 2: Update the location
UPDATE DriverLocation
SET GeohashID = 'drt2zp2m' 
WHERE DriverID = 'DRIVE00002';

-- Step 3: Verify the LastUpdated timestamp was updated
SELECT * FROM DriverLocation
WHERE DriverID = 'DRIVE00002';

GO

/******* DML Trigger 2: To audit trigger to log all driver status changes*******/
CREATE TRIGGER TRG_Audit_DriverStatusChange
ON Driver
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Only proceed if availability status changed
    IF UPDATE(AvailabilityStatus)
    BEGIN
        -- Insert into audit log
        INSERT INTO DriverStatusAudit (
            DriverID,
            PreviousStatus,
            NewStatus,
            ChangeDate
        )
        SELECT 
            i.DriverID,
            d.AvailabilityStatus,
            i.AvailabilityStatus,
            GETDATE()
        FROM inserted i
        JOIN deleted d ON i.DriverID = d.DriverID
        WHERE i.AvailabilityStatus <> d.AvailabilityStatus;
    END
END;

GO

-- Step 1: Check current driver status
SELECT DriverID, AvailabilityStatus 
FROM Driver
WHERE DriverID = 'DRIVE00004';
GO
-- Step 2: Change the driver's status
UPDATE Driver
SET AvailabilityStatus = 'Out-of-Service'
WHERE DriverID = 'DRIVE00004' AND AvailabilityStatus = 'Available';
GO
-- Step 3: Verify the audit record was created
SELECT * FROM DriverStatusAudit
WHERE DriverID = 'DRIVE00004'
ORDER BY ChangeDate DESC;
GO
-- Step 4: Change the status again to create another audit record
UPDATE Driver
SET AvailabilityStatus = 'Available'
WHERE DriverID = 'DRIVE00004';
GO
-- Step 5: Verify multiple audit records exist for this driver
SELECT * FROM DriverStatusAudit
WHERE DriverID = 'DRIVE00004'
ORDER BY ChangeDate DESC;
GO