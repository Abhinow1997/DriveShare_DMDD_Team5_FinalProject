/********************** NON-CLUSTERED INDEXING **********************/
USE Team2_FinalProject_DMDD;

GO

CREATE NONCLUSTERED INDEX IX_TripRequest_Status_State
ON TripRequest (Status, State)
INCLUDE (TripRequestID, RiderID, EstimatedCost, RequestTime);

GO

CREATE NONCLUSTERED INDEX IX_Driver_AvailabilityStatus
ON Driver (AvailabilityStatus)
INCLUDE (DriverID, Rating, TotalCompletedRides);

GO

CREATE NONCLUSTERED INDEX IX_Location_State_City
ON Location (State, City)
INCLUDE (GeohashID, Latitude, Longitude);

GO

SELECT * FROM Driver WHERE AvailabilityStatus = 'Available' ORDER BY Rating DESC;
SELECT * FROM TripRequest WHERE Status = 'Pending' AND State = 'New York';
SELECT * FROM Location WHERE State = 'Massachusetts' AND City = 'Boston';