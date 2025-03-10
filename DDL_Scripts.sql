CREATE DATABASE Team2_FinalProject_DMDD;
GO
USE Team2_FinalProject_DMDD;


-- Table for Admin
DROP TABLE IF EXISTS [Admin]
CREATE TABLE [Admin] (
    [ID] INT IDENTITY(1,1) NOT NULL,
    [AdminID] AS 'ADMIN' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
    [FirstName] varchar(40) NOT NULL,
    [LastName] varchar(40) NOT NULL,
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
  [LastName] varchar(50) NOT NULL,
  [Password] varchar(40) NOT NULL,
  [EmailID] varchar(50) NOT NULL,
  [PhoneNumber] varchar(10) NOT NULL,
  [Type] varchar(30) NOT NULL,
  CONSTRAINT CHK_UserType CHECK ([Type] IN ('Driver', 'Renter', 'Rider')),
  CONSTRAINT [PK_RegisteredUsers] PRIMARY KEY ([UserID]),
  CONSTRAINT [FK_AdminID] FOREIGN KEY (AdminID) REFERENCES Admin(AdminID) 
);

-- Table for Renter
DROP TABLE IF EXISTS [Renter];
CREATE TABLE [Renter] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [RenterID] AS 'RENTR' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [UserID] varchar(10) NOT NULL,
  [TotalRentedCars] decimal(10,2) NOT NULL DEFAULT 0,
  [TotalEarnings] decimal(10,2) NOT NULL DEFAULT 0,
  [TotalRentalTime] int NOT NULL DEFAULT 0,
  [CompanyName] varchar(30),
  CONSTRAINT [PK_RenterID] PRIMARY KEY ([RenterID]),
  CONSTRAINT [FK_RenterUserID] FOREIGN KEY ([UserID]) REFERENCES RegisteredUsers(UserID)
);


-- Table for Driver
DROP TABLE IF EXISTS [Driver];
CREATE TABLE [Driver] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [DriverID] AS 'DRIVE' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [UserID] varchar(10) NOT NULL REFERENCES RegisteredUsers(UserID),
  [LicenseNo] varchar(10) NOT NULL DEFAULT 'NULL',
  [AvailabilityStatus] varchar(15) NOT NULL DEFAULT 'Available',
  [TotalCompletedRides] INT NOT NULL DEFAULT 0,
  [TotalEarnings] INT NOT NULL DEFAULT 0,
  [Rating] INT NOT NULL DEFAULT 0,
  CONSTRAINT [PK_DriverID] PRIMARY KEY ([DriverID]),
  CONSTRAINT CHK_AvailabilityStatus CHECK ([AvailabilityStatus] IN ('In-Transit', 'Available', 'Out-of-Service'))
);


-- Table for Rider
DROP TABLE IF EXISTS [Rider];
CREATE TABLE [Rider] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [RiderID] AS 'RIDER' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [UserID] varchar(10) NOT NULL REFERENCES RegisteredUsers(UserID),
  [TotalPreviousRides] INT NOT NULL DEFAULT 0,
  [AmountDue] decimal(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT [PK_RiderID] PRIMARY KEY ([RiderID])
);


-- Table for Car
DROP TABLE IF EXISTS [Car];
CREATE TABLE [Car] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [CarID] AS 'R_CAR' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [CarType] varchar(20) NOT NULL,
  [CarStatus] varchar(15) NOT NULL,
  [CarModel] varchar(30) NOT NULL,
  [CarYear] int NOT NULL,
  [IsElectric] BIT NOT NULL,
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
  [RentalEndDate] datetime,
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
  [GeohashID] AS dbo.CalculateGeohash(Latitude, Longitude, 6) PERSISTED,
  [Region] VARCHAR(50) NOT NULL,
  [County] VARCHAR(50) NOT NULL,
  [City] VARCHAR(50) NOT NULL,
  [State] VARCHAR(50) NOT NULL,
  CONSTRAINT [PK_LocationID] PRIMARY KEY ([GeohashID])
);

DROP TABLE IF EXISTS [DriverLocation];
CREATE TABLE [DriverLocation] (
  [DriverID] VARCHAR(10) NOT NULL,
  [GeohashID] VARCHAR(12) NOT NULL,
  [LastUpdated] DATETIME NOT NULL DEFAULT GETDATE(),
  CONSTRAINT [PK_DriverLocation] PRIMARY KEY ([DriverID]),
  CONSTRAINT [FK_DriverLocation_Driver] FOREIGN KEY ([DriverID]) REFERENCES [Driver]([DriverID]),
  CONSTRAINT [FK_DriverLocation_Location] FOREIGN KEY ([GeohashID]) REFERENCES [Location]([GeohashID])
);

DROP TABLE IF EXISTS [TripRequest];
CREATE TABLE [TripRequest] (
  [TripID] INT IDENTITY(1,1) NOT NULL,
  [TripRequestID] AS 'TRIP_' + RIGHT('00000' + CAST(TripID AS VARCHAR(5)), 5) PERSISTED,
  [RiderID] VARCHAR(10) NOT NULL,
  [PickupLatitude] DECIMAL(10,8) NOT NULL,
  [PickupLongitude] DECIMAL(11,8) NOT NULL,
  [PickupGeohashID] AS dbo.CalculateGeohash(PickupLatitude, PickupLongitude, 6) PERSISTED,
  [DropoffLatitude] DECIMAL(10,8) NOT NULL,
  [DropoffLongitude] DECIMAL(11,8) NOT NULL,
  [DropoffGeohashID] AS dbo.CalculateGeohash(DropoffLatitude, DropoffLongitude, 6) PERSISTED,
  [RequestTime] DATETIME NOT NULL DEFAULT GETDATE(),
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


DROP TABLE IF EXISTS [Ratecard];
CREATE TABLE [Ratecard] (
  [State] VARCHAR(50) NOT NULL,
  [RatePerMile] DECIMAL(10,2) NOT NULL,
  [StateTax] DECIMAL(10,2) NOT NULL,
  [BaseFare] DECIMAL(10,2) NOT NULL DEFAULT 10.00,
  CONSTRAINT [PK_Ratecard] PRIMARY KEY ([State])
);



DROP TABLE IF EXISTS [Invoice];
CREATE TABLE [Invoice] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [InvoiceID] AS 'INVO_' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [TripRequestID] varchar(10) NOT NULL,
  [Distance] decimal(5,2) NOT NULL,
  [Price] decimal(10,3) NOT NULL,
  CONSTRAINT [PK_Invoice] PRIMARY KEY ([InvoiceID]),
  CONSTRAINT [FK_Invoice] FOREIGN KEY ([TripRequestID]) REFERENCES TripRequest([TripRequestID])
);


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
  CONSTRAINT [CHK_PaymentRequest_Status] CHECK ([Status] IN ('Pending', 'Remaining','Completed','Canceled')),
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
  [Type] varchar(20) NOT NULL,
  CONSTRAINT [PK_Card] PRIMARY KEY ([PaymentID]),
  CONSTRAINT [FK_Card_PaymentRequest] FOREIGN KEY ([PaymentID]) REFERENCES [PaymentRequest]([PaymentID])
);

-- Online Wallet Table
DROP TABLE IF EXISTS [OnlineWallet];
CREATE TABLE [OnlineWallet] (
  [PaymentID] varchar(10) NOT NULL,
  [WalletID] varchar(20) NOT NULL,
  [WalletProvider] varchar(30) NOT NULL,
  [AccountEmail] varchar(50) NOT NULL,
  CONSTRAINT [PK_OnlineWallet] PRIMARY KEY ([PaymentID]),
  CONSTRAINT [FK_OnlineWallet_PaymentRequest] FOREIGN KEY ([PaymentID]) REFERENCES [PaymentRequest]([PaymentID])
);