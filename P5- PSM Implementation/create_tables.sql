/**********************DATABASE CREATION**********************/
/*STEP 1 : Creation of Database*/
USE master;
GO
CREATE DATABASE Team2_FinalProject_DMDD_v2;
GO
USE Team2_FinalProject_DMDD_v2;
GO 


/**********************User Defined Functions(UDFs)**********************/
/*STEP 2 : Creation of Functions*/
/*Functions are being used to pre calculate some of the required vales for tables*/
--Geohash calculaton script
CREATE FUNCTION dbo.CalculateGeohash(
    @lat DECIMAL(10,8),
    @lon DECIMAL(11,8),
    @precision INT
)
RETURNS VARCHAR(12)
WITH SCHEMABINDING
AS
BEGIN
    -- Base32 character map for geohash encoding
    DECLARE @base32 VARCHAR(32) = '0123456789bcdefghjkmnpqrstuvwxyz';
    -- Variables for the algorithm
    DECLARE @geohash VARCHAR(12) = '';
    DECLARE @bits INT = 0;
    DECLARE @bitsTotal INT = 0;
    DECLARE @hash_index INT = 0;
    
    -- Bounds for latitude and longitude
    DECLARE @lat_min DECIMAL(10,8) = -90.0;
    DECLARE @lat_max DECIMAL(10,8) = 90.0;
    DECLARE @lon_min DECIMAL(11,8) = -180.0;
    DECLARE @lon_max DECIMAL(11,8) = 180.0;
    
    -- Check if precision is valid
    IF @precision < 1 OR @precision > 12
        SET @precision = 5;
    
    -- Main geohash encoding loop
    WHILE LEN(@geohash) < @precision
    BEGIN
        -- Even bits are longitude, odd bits are latitude
        IF @bitsTotal % 2 = 0
        BEGIN
            -- Process longitude
            DECLARE @lon_mid DECIMAL(11,8) = (@lon_min + @lon_max) / 2;
            
            IF @lon >= @lon_mid
            BEGIN
                SET @hash_index = @hash_index * 2 + 1;
                SET @lon_min = @lon_mid;
            END
            ELSE
            BEGIN
                SET @hash_index = @hash_index * 2;
                SET @lon_max = @lon_mid;
            END
        END
        ELSE
        BEGIN
            -- Process latitude
            DECLARE @lat_mid DECIMAL(10,8) = (@lat_min + @lat_max) / 2;
            
            IF @lat >= @lat_mid
            BEGIN
                SET @hash_index = @hash_index * 2 + 1;
                SET @lat_min = @lat_mid;
            END
            ELSE
            BEGIN
                SET @hash_index = @hash_index * 2;
                SET @lat_max = @lat_mid;
            END
        END
        
        -- Increment bit count
        SET @bits = @bits + 1;
        SET @bitsTotal = @bitsTotal + 1;
        
        -- When we've collected 5 bits, convert to a base32 character
        IF @bits = 5
        BEGIN
            SET @geohash = @geohash + SUBSTRING(@base32, @hash_index + 1, 1);
            SET @bits = 0;
            SET @hash_index = 0;
        END
    END
    
    RETURN @geohash;
END;

GO 

-- Distance calculation between two points from pickup and dropoff stops
CREATE FUNCTION dbo.CalculateDistance
(
    @PickupLatitude DECIMAL(10,8),
    @PickupLongitude DECIMAL(11,8),
    @DropoffLatitude DECIMAL(10,8),
    @DropoffLongitude DECIMAL(11,8)
)
RETURNS DECIMAL(18,8)
WITH SCHEMABINDING
AS
BEGIN
    RETURN 6371 * ACOS(
        COS(RADIANS(@PickupLatitude)) * COS(RADIANS(@DropoffLatitude)) *
        COS(RADIANS(@DropoffLongitude) - RADIANS(@PickupLongitude)) +
        SIN(RADIANS(@PickupLatitude)) * SIN(RADIANS(@DropoffLatitude))
    );
END;

GO

-- Trip Cost calculation
CREATE FUNCTION dbo.CalculateTripCost
(
    @Distance DECIMAL(18,8)
)
RETURNS DECIMAL(18,2)
WITH SCHEMABINDING
AS
BEGIN
    RETURN @Distance * 1.50;
END;

GO

-- State Identification from the pickup long and lat
CREATE FUNCTION dbo.GetStateFromCoordinates(
    @lat DECIMAL(10,8),
    @lon DECIMAL(11,8)
)
RETURNS VARCHAR(50)
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @state VARCHAR(50);
    IF @lat BETWEEN 41.0 AND 43.0 AND @lon BETWEEN -73.5 AND -69.5
        SET @state = 'Massachusetts';
    ELSE IF @lat BETWEEN 40.0 AND 45.0 AND @lon BETWEEN -80.0 AND -73.5
        SET @state = 'New York';
    ELSE IF @lat BETWEEN 32.0 AND 42.0 AND @lon BETWEEN -124.0 AND -114.0
        SET @state = 'California';
    ELSE
        SET @state = 'Unknown';
        
    RETURN @state;
END;

GO


/**********************DDL SCRIPTS - TABLES CREATION**********************/
USE Team2_FinalProject_DMDD_v2;

-- Table for Admin
DROP TABLE IF EXISTS [Admin]
CREATE TABLE [Admin] (
    [ID] INT IDENTITY(1,1) NOT NULL,
    [AdminID] AS 'ADMIN' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
    [FirstName] varchar(40) NOT NULL,
    [LastName] varchar(40),
    [Password] varchar(40) NOT NULL,
    CONSTRAINT [PK_Admin] PRIMARY KEY (AdminID)
);

-- Table for RegisteredUsers
DROP TABLE IF EXISTS [RegisteredUsers];
CREATE TABLE [RegisteredUsers] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [UserID] AS 'R_USR' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [AdminID] varchar(10),
  [FirstName] varchar(10) NOT NULL,
  [LastName] varchar(50),
  [Password] varchar(40) NOT NULL,
  [EmailID] varchar(50) NOT NULL,
  [PhoneNumber] varchar(10) NOT NULL,
  [Type] varchar(10) NOT NULL,
  CONSTRAINT CHK_UserType CHECK ([Type] IN ('Driver', 'Renter', 'Rider')),
  CONSTRAINT [PK_RegisteredUsers] PRIMARY KEY ([UserID]),
  CONSTRAINT [FK_AdminID] FOREIGN KEY (AdminID) REFERENCES [Admin](AdminID),
  CONSTRAINT [UQ_RegisteredUsers_EmailID] UNIQUE ([EmailID])
  );

-- Table for Renter
DROP TABLE IF EXISTS [Renter];
CREATE TABLE [Renter] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [RenterID] AS 'RENTR' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [UserID] varchar(10) NOT NULL,
  [TotalRentedCars] INT DEFAULT 0,
  [TotalEarnings] DECIMAL(19,2) DEFAULT 0.00,
  [TotalRentalTime] int DEFAULT 0,
  [CompanyName] varchar(30),
  CONSTRAINT [PK_RenterID] PRIMARY KEY ([RenterID]),
  CONSTRAINT [FK_RenterUserID] FOREIGN KEY ([UserID]) REFERENCES RegisteredUsers(UserID)
);


-- Table for Driver
DROP TABLE IF EXISTS [Driver];
CREATE TABLE [Driver] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [DriverID] AS 'DRIVE' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [UserID] varchar(10) NOT NULL,
  [LicenseNo] varchar(10) NOT NULL,
  [AvailabilityStatus] varchar(15) DEFAULT 'Available',
  [TotalCompletedRides] INT DEFAULT 0,
  [TotalEarnings] DECIMAL(19,2) NOT NULL DEFAULT 0.00,
  [Rating] DECIMAL(3,1) NOT NULL DEFAULT 0.0,
  CONSTRAINT [CHK_Rating] CHECK ([Rating] >= 0.0 AND [Rating] <= 5.0),
  CONSTRAINT [PK_DriverID] PRIMARY KEY ([DriverID]),
  CONSTRAINT [CHK_AvailabilityStatus] CHECK ([AvailabilityStatus] IN ('In-Transit', 'Available', 'Out-of-Service')),
  CONSTRAINT [UQ_Driver_LicenseNo] UNIQUE ([LicenseNo]),
  CONSTRAINT [FK_Driver_UserID] FOREIGN KEY (UserID) REFERENCES RegisteredUsers(UserID),
);

-- Table for Rider
DROP TABLE IF EXISTS [Rider];
CREATE TABLE [Rider] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [RiderID] AS 'RIDER' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [UserID] varchar(10) NOT NULL REFERENCES RegisteredUsers(UserID),
  [TotalPreviousRides] INT DEFAULT 0,
  [AmountDue] decimal(19,2) DEFAULT 0,
  CONSTRAINT [PK_RiderID] PRIMARY KEY ([RiderID])
);


-- Table for Car
DROP TABLE IF EXISTS [Car];
CREATE TABLE [Car] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [CarID] AS 'R_CAR' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [CarType] varchar(20) NOT NULL,
  [CarStatus] varchar(15) NOT NULL,
  [CarModel] varchar(30),
  [CarYear] int,
  [IsElectric] BIT DEFAULT 0,
  [NumberOfSeats] AS (
    CASE 
      WHEN [CarType] IN ('Sedan','Hatchbacks') THEN 4
      WHEN [CarType] = 'Minivans' THEN 7
      WHEN [CarType] = 'Compact' THEN 3
      WHEN [CarType] IN ('Wagon','SUV') THEN 5
      ELSE 0
    END
  ) PERSISTED,
  CONSTRAINT [PK_CarID] PRIMARY KEY ([CarID]),
  CONSTRAINT [CHK_CarType] CHECK ([CarType] IN ('Compact','Sedan','SUV','Hatchbacks','Minivans','Wagon')),
  CONSTRAINT [CHK_CarStatus] CHECK ([CarStatus] IN ('Available', 'Rented', 'In-Service'))
);


DROP TABLE IF EXISTS [Renter_Car],[Driver_Car];
CREATE TABLE [Renter_Car] (
  [RenterID] varchar(10) NOT NULL REFERENCES Renter(RenterID),
  [CarID] varchar(10) NOT NULL REFERENCES Car(CarID),
  [RentalStartDate] datetime NOT NULL,
  [RentalEndDate] datetime NOT NULL,
  CONSTRAINT [PK_RenterCar] PRIMARY KEY ([RenterID], [CarID])
);
CREATE TABLE [Driver_Car] (
  [DriverID] varchar(10) NOT NULL REFERENCES Driver(DriverID),
  [CarID] varchar(10) NOT NULL REFERENCES Car(CarID),
  CONSTRAINT [PK_DriverCar] PRIMARY KEY ([DriverID], [CarID])
);


-- Table for Location 
DROP TABLE IF EXISTS [Location];
CREATE TABLE [Location] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [Latitude] DECIMAL(10,8) NOT NULL,
  [Longitude] DECIMAL(11,8) NOT NULL,
  [GeohashID] AS dbo.CalculateGeohash(Latitude, Longitude, 8) PERSISTED,
  [Region] VARCHAR(50),
  [County] VARCHAR(50),
  [City] VARCHAR(50) NOT NULL,
  [State] VARCHAR(50) NOT NULL,
  CONSTRAINT [PK_LocationID] PRIMARY KEY ([GeohashID])
);

-- Table for DriverLocation 
DROP TABLE IF EXISTS [DriverLocation];
CREATE TABLE [DriverLocation] (
  [DriverID] VARCHAR(10) NOT NULL,
  [GeohashID] VARCHAR(12) NOT NULL,
  [LastUpdated] DATETIME DEFAULT GETDATE(),
  CONSTRAINT [PK_DriverLocation] PRIMARY KEY ([DriverID]),
  CONSTRAINT [FK_DriverLocation_Driver] FOREIGN KEY ([DriverID]) REFERENCES [Driver]([DriverID]),
  CONSTRAINT [FK_DriverLocation_Location] FOREIGN KEY ([GeohashID]) REFERENCES [Location]([GeohashID])
);


-- Table for Ratecard 
DROP TABLE IF EXISTS [Ratecard];
CREATE TABLE [Ratecard] (
  [State] VARCHAR(50) NOT NULL,
  [RatePerMile] DECIMAL(10,2) NOT NULL,
  [StateTax] DECIMAL(10,2) NOT NULL,
  [BaseFare] DECIMAL(10,2) NOT NULL DEFAULT 10.00,
  CONSTRAINT [PK_Ratecard] PRIMARY KEY ([State])
);


-- Table for TripRequest
DROP TABLE IF EXISTS [TripRequest];
CREATE TABLE [TripRequest] (
  [TripID] INT IDENTITY(1,1) NOT NULL,
  [TripRequestID] AS 'TRIP_' + RIGHT('00000' + CAST(TripID AS VARCHAR(5)), 5) PERSISTED,
  [RiderID] VARCHAR(10) NOT NULL,
  [PickupLatitude] DECIMAL(10,8) NOT NULL,
  [PickupLongitude] DECIMAL(11,8) NOT NULL,
  [PickupGeohashID] AS dbo.CalculateGeohash(PickupLatitude, PickupLongitude, 8) PERSISTED,
  [DropoffLatitude] DECIMAL(10,8) NOT NULL,
  [DropoffLongitude] DECIMAL(11,8) NOT NULL,
  [DropoffGeohashID] AS dbo.CalculateGeohash(DropoffLatitude, DropoffLongitude, 8) PERSISTED,
  [RequestTime] DATETIME DEFAULT GETDATE(),
  [EstimatedDistance] AS dbo.CalculateDistance(PickupLatitude, PickupLongitude, DropoffLatitude, DropoffLongitude) PERSISTED,
  [State] AS dbo.GetStateFromCoordinates(PickupLatitude, PickupLongitude) PERSISTED,
  [EstimatedCost] AS dbo.CalculateTripCost(dbo.CalculateDistance(PickupLatitude, PickupLongitude, DropoffLatitude, DropoffLongitude)) PERSISTED,
  [Status] VARCHAR(20) NOT NULL DEFAULT 'Pending',
  CONSTRAINT [PK_TripRequest] PRIMARY KEY ([TripRequestID]),
  CONSTRAINT [FK_TripRequest_State] FOREIGN KEY ([State]) REFERENCES [Ratecard]([State]),
  CONSTRAINT [FK_TripRequest_Rider] FOREIGN KEY ([RiderID]) REFERENCES [Rider]([RiderID]),
  CONSTRAINT [FK_TripRequest_PickupLocation] FOREIGN KEY ([PickupGeohashID]) REFERENCES [Location]([GeohashID]),
  CONSTRAINT [FK_TripRequest_DropoffLocation] FOREIGN KEY ([DropoffGeohashID]) REFERENCES [Location]([GeohashID]),
  CONSTRAINT [CHK_Status] CHECK ([Status] IN ('Pending', 'Ride-In-Process','Completed','Canceled'))
);


-- Table for Invoice
DROP TABLE IF EXISTS [Invoice];
CREATE TABLE [Invoice] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [InvoiceID] AS 'INVO_' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [TripRequestID] varchar(10) NOT NULL,
  [Distance] decimal(5,2) NOT NULL,
  [Price] decimal(10,2) NOT NULL,
  CONSTRAINT [PK_Invoice] PRIMARY KEY ([InvoiceID]),
  CONSTRAINT [FK_Invoice] FOREIGN KEY ([TripRequestID]) REFERENCES TripRequest([TripRequestID])
);


-- Table for Invoice
DROP TABLE IF EXISTS [PaymentRequest];
CREATE TABLE [PaymentRequest] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [PaymentID] AS 'PAY_R' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [InvoiceID] varchar(10) NOT NULL,
  [RiderID] varchar(10) NOT NULL,
  [MethodOfPayment] varchar(25) NOT NULL,
  [Amount] decimal(10,2) NOT NULL,
  [Status] varchar(15) NOT NULL
  CONSTRAINT [PK_PaymentRequest] PRIMARY KEY ([PaymentID]),
  CONSTRAINT [FK_PaymentRequest_Invoice] FOREIGN KEY ([InvoiceID]) REFERENCES [Invoice]([InvoiceID]),
  CONSTRAINT [FK_PaymentRequest_Rider] FOREIGN KEY ([RiderID]) REFERENCES [Rider]([RiderID]),
  CONSTRAINT [CHK_PaymentRequest_Status] CHECK ([Status] IN ('Pending','Completed','Canceled')),
  CONSTRAINT [CHK_PaymentRequest_MethodOfPayment] CHECK ([MethodOfPayment] IN ('Cash', 'Card','OnlineWallet'))
);

-- Card Payment Table
DROP TABLE IF EXISTS [Card];
CREATE TABLE [Card] (
  [PaymentID] varchar(10) NOT NULL,
  [CardNumber] varchar(16) NOT NULL,
  [CardHolder] varchar(50) NOT NULL,
  [ExpiryDate] date NOT NULL,
  [CVV] varchar(4) NOT NULL,
  [Type] varchar(20),
  CONSTRAINT [PK_Card] PRIMARY KEY ([PaymentID]),
  CONSTRAINT [FK_Card_PaymentRequest] FOREIGN KEY ([PaymentID]) REFERENCES [PaymentRequest]([PaymentID])
);

-- Online Wallet Table
DROP TABLE IF EXISTS [OnlineWallet];
CREATE TABLE [OnlineWallet] (
  [PaymentID] varchar(10) NOT NULL,
  [WalletID] char(20) NOT NULL,
  [WalletProvider] varchar(30),
  [AccountEmail] varchar(50),
  CONSTRAINT [PK_OnlineWallet] PRIMARY KEY ([PaymentID]),
  CONSTRAINT [FK_OnlineWallet_PaymentRequest] FOREIGN KEY ([PaymentID]) REFERENCES [PaymentRequest]([PaymentID])
);

-- Driver status audit/logging
CREATE TABLE DriverStatusAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    DriverID VARCHAR(10) NOT NULL,
    PreviousStatus VARCHAR(15) NOT NULL,
    NewStatus VARCHAR(15) NOT NULL,
    ChangeDate DATETIME NOT NULL
);