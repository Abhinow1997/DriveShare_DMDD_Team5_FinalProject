USE Team2_FinalProject_DMDD_v2;
GO

-- Drop conflicting triggers if they exist
DROP TRIGGER IF EXISTS TRG_Prevent_Delete_Car;
GO

DROP TRIGGER IF EXISTS TRG_UpdateDriverLocation;
GO

DROP TRIGGER IF EXISTS TRG_CreateInvoice_OnTripCompletion;
GO

-- Trigger to generate Invoice on trip Completion
CREATE TRIGGER TRG_CreateInvoice_OnTripCompletion
ON [TripRequest]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Check if status changed from 'Ride-In-Process' to 'Completed'
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN deleted d ON i.TripRequestID = d.TripRequestID
        WHERE i.Status = 'Completed' AND d.Status = 'Ride-In-Process'
    )
    BEGIN
        -- Insert new invoice record
        INSERT INTO Invoice (TripRequestID, Distance, Price)
        SELECT 
            i.TripRequestID,
            i.EstimatedDistance,
            i.EstimatedCost
        FROM inserted i
        WHERE i.Status = 'Completed'
        AND NOT EXISTS (
            SELECT 1 FROM Invoice 
            WHERE TripRequestID = i.TripRequestID
        );
    END
END;
GO

-- Trigger to prevent car removal from system
CREATE TRIGGER TRG_Prevent_Delete_Car
ON Car
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Renter_Car WHERE CarID IN (SELECT CarID FROM deleted))
    BEGIN
        RAISERROR ('Cannot delete car from system. It is currently assigned to a renter.', 16, 1);
        RETURN;
    END;
    DELETE FROM Car WHERE CarID IN (SELECT CarID FROM deleted);
END;
GO

-- Trigger to retrieve the updated driver location details
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
GO