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
  [UserID] varchar(10) NOT NULL REFERENCES RegisteredUsers(UserID),
  [TotalRentedCars] decimal(10,2) NOT NULL DEFAULT 0,
  [TotalEarnings] decimal(10,2) NOT NULL DEFAULT 0,
  [TotalRentalTime] int NOT NULL DEFAULT 0,
  [CompanyName] varchar(30),
  CONSTRAINT [PK_RenterID] PRIMARY KEY ([RenterID])
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
DROP TABLE [Location]

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

CREATE TABLE [DriverLocation] (
  [DriverID] VARCHAR(10) NOT NULL,
  [GeohashID] VARCHAR(12) NOT NULL,
  [LastUpdated] DATETIME NOT NULL DEFAULT GETDATE(),
  CONSTRAINT [PK_DriverLocation] PRIMARY KEY ([DriverID]),
  CONSTRAINT [FK_DriverLocation_Driver] FOREIGN KEY ([DriverID]) REFERENCES [Driver]([DriverID]),
  CONSTRAINT [FK_DriverLocation_Location] FOREIGN KEY ([GeohashID]) REFERENCES [Location]([GeohashID])
);

CREATE TABLE [TripRequest] (
  [TripID] INT IDENTITY(1,1) NOT NULL,
  [TripRequestID] AS 'TRIP' + RIGHT('00000' + CAST(TripID AS VARCHAR(5)), 5) PERSISTED,
  [RiderID] VARCHAR(10) NOT NULL,
  [PickupGeohashID] VARCHAR(12) NOT NULL,
  [DropoffGeohashID] VARCHAR(12) NOT NULL,
  [RequestTime] DATETIME NOT NULL DEFAULT GETDATE(),
  [Status] VARCHAR(20) NOT NULL DEFAULT 'Pending',
  CONSTRAINT [PK_TripRequest] PRIMARY KEY ([TripRequestID]),
  CONSTRAINT [FK_TripRequest_Rider] FOREIGN KEY ([RiderID]) REFERENCES [Rider]([RiderID]),
  CONSTRAINT [FK_TripRequest_PickupLocation] FOREIGN KEY ([PickupGeohashID]) REFERENCES [Location]([GeohashID]),
  CONSTRAINT [FK_TripRequest_DropoffLocation] FOREIGN KEY ([DropoffGeohashID]) REFERENCES [Location]([GeohashID])
);