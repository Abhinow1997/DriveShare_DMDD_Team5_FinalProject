USE Team2_FinalProject_DMDD_v2;
GO

CREATE PROCEDURE dbo.AssignDriverToTrip
    @TripRequestID VARCHAR(10),
    @DriverID VARCHAR(10)
AS
BEGIN
    -- Declare necessary variables
    DECLARE @TripStatus VARCHAR(20);
    DECLARE @PickupGeohash VARCHAR(12);
    DECLARE @DropoffGeohash VARCHAR(12);
    DECLARE @State VARCHAR(50);

    -- Get the current trip status, pickup and dropoff geohash, and state
    SELECT 
        @TripStatus = Status, 
        @PickupGeohash = PickupGeohashID, 
        @DropoffGeohash = DropoffGeohashID,
        @State = State
    FROM TripRequest
    WHERE TripRequestID = @TripRequestID;

    -- Ensure the trip is in 'Pending' status before assigning a driver
    IF @TripStatus = 'Pending'
    BEGIN
        -- Update the trip status to 'Ride-In-Process'
        UPDATE TripRequest
        SET Status = 'Ride-In-Process'
        WHERE TripRequestID = @TripRequestID;

        -- Assign the driver to the trip and set their availability to 'In-Transit'
        UPDATE Driver
        SET AvailabilityStatus = 'In-Transit'
        WHERE DriverID = @DriverID;

        -- Insert the driver's location for tracking purposes
        INSERT INTO DriverLocation (DriverID, GeohashID)
        VALUES (@DriverID, @PickupGeohash);

        -- Return a success message
        PRINT 'Driver assigned to the trip successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Trip is not in Pending status.';
    END
END;
GO


CREATE PROCEDURE dbo.CompleteTrip
    @TripRequestID VARCHAR(10)
AS
BEGIN
    -- Declare necessary variables
    DECLARE @RiderID VARCHAR(10);
    DECLARE @EstimatedDistance DECIMAL(18,8);
    DECLARE @State VARCHAR(50);
    DECLARE @EstimatedCost DECIMAL(18,2);
    DECLARE @InvoiceID VARCHAR(10);

    -- Get the details of the trip
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

    -- Insert an invoice for the completed trip
    INSERT INTO Invoice (TripRequestID, Distance, Price)
    VALUES (@TripRequestID, @EstimatedDistance, @EstimatedCost);

    -- Retrieve the Invoice ID
    SET @InvoiceID = (SELECT InvoiceID FROM Invoice WHERE TripRequestID = @TripRequestID);

    -- Return the Invoice ID for further processing
    PRINT 'Trip completed. Invoice ID: ' + @InvoiceID;
END;
GO



CREATE PROCEDURE dbo.UpdateDriverRating
    @DriverID VARCHAR(10),
    @Rating DECIMAL(3,1)
AS
BEGIN
    -- Declare a variable for the total rating count and total rating score
    DECLARE @TotalCompletedRides INT;
    DECLARE @TotalRatingScore DECIMAL(19,2);

    -- Ensure the rating is between 0 and 5
    IF @Rating < 0 OR @Rating > 5
    BEGIN
        PRINT 'Invalid rating. The rating must be between 0 and 5.';
        RETURN;
    END

    -- Get the current total completed rides and total rating score for the driver
    SELECT 
        @TotalCompletedRides = TotalCompletedRides, 
        @TotalRatingScore = TotalEarnings
    FROM Driver
    WHERE DriverID = @DriverID;

    -- Calculate the new total rating score
    SET @TotalRatingScore = @TotalRatingScore + @Rating;

    -- Update the driver's rating
    UPDATE Driver
    SET 
        Rating = @TotalRatingScore / (@TotalCompletedRides + 1),  -- Average rating
        TotalCompletedRides = @TotalCompletedRides + 1  -- Increment completed rides count
    WHERE DriverID = @DriverID;

    PRINT 'Driver rating updated successfully.';
END;
GO


CREATE PROCEDURE dbo.ProcessPayment
    @PaymentID VARCHAR(10),
    @MethodOfPayment VARCHAR(25),
    @Amount DECIMAL(10,2)
AS
BEGIN
    -- Declare necessary variables
    DECLARE @InvoiceID VARCHAR(10);
    DECLARE @Status VARCHAR(15);

    -- Ensure valid payment method
    IF @MethodOfPayment NOT IN ('Cash', 'Card', 'OnlineWallet')
    BEGIN
        PRINT 'Invalid payment method.';
        RETURN;
    END

    -- Get the invoice ID and status
    SELECT 
        @InvoiceID = InvoiceID
    FROM PaymentRequest
    WHERE PaymentID = @PaymentID;

    -- Process the payment
    UPDATE PaymentRequest
    SET Status = 'Completed', Amount = @Amount
    WHERE PaymentID = @PaymentID;

    -- Check the method of payment and log accordingly
    IF @MethodOfPayment = 'Card'
    BEGIN
        PRINT 'Payment processed by Card. Invoice ID: ' + @InvoiceID;
    END
    ELSE IF @MethodOfPayment = 'OnlineWallet'
    BEGIN
        PRINT 'Payment processed by Online Wallet. Invoice ID: ' + @InvoiceID;
    END
    ELSE
    BEGIN
        PRINT 'Payment processed by Cash. Invoice ID: ' + @InvoiceID;
    END
END;
GO
