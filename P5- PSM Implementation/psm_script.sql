USE Team2_FinalProject_DMDD_v2;

GO

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
            SET @Message = 'Driver assigned to the trip successfully.';
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
/**Stored Procedure - AssignDriverToTrip Working Example**/
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