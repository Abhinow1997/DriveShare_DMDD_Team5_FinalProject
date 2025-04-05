USE Team2_FinalProject_DMDD_v2;

GO

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
        
        IF @@ROWCOUNT = 0
        BEGIN
            SET @Message = 'Driver not found with ID: ' + @DriverID;
            ROLLBACK TRANSACTION;
            RETURN;
        END

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