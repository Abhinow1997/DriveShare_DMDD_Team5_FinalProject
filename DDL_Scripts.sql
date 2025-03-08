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

INSERT INTO [Admin] (FirstName, LastName, Password)
VALUES 
('Abhinav', 'Gangurde', 'admin'),
('Akshay', 'Veerabhadraiah', 'admin'),
('Neha', 'Suresh', 'admin'),
('Om', 'Raut', 'admin'),
('Poojith', 'Kotipalli', 'admin');

SELECT * FROM [Admin];

-- Table for RegisteredUsers

DROP TABLE IF EXISTS [RegisteredUsers];

CREATE TABLE [RegisteredUsers] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [UserID] AS 'User' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
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


INSERT INTO [RegisteredUsers] (AdminID, FirstName, LastName, Password, EmailID, PhoneNumber, Type)
VALUES 
('ADMIN00001', 'Rahul', 'Sharma', 'Pass123!', 'rahul.sharma@email.com', '9876543210', 'Driver'),
('ADMIN00001', 'Priya', 'Patel', 'SecureP@ss', 'priya.patel@email.com', '8765432109', 'Renter'),
('ADMIN00003', 'Amit', 'Singh', 'UserA3#2023', 'amit.singh@email.com', '7654321098', 'Rider'),
('ADMIN00004', 'Sneha', 'Reddy', 'Red2023!', 'sneha.reddy@email.com', '6543210987', 'Rider'),
('ADMIN00005', 'Vikram', 'Mehta', 'VM@Pass2023', 'vikram.mehta@email.com', '5432109876', 'Rider'),
('ADMIN00001', 'Anita', 'Desai', 'AnitaD#123', 'anita.desai@email.com', '4321098765', 'Rider'),
('ADMIN00002', 'Rajesh', 'Kumar', 'RajK2023!', 'rajesh.kumar@email.com', '3210987654', 'Renter'),
('ADMIN00003', 'Meera', 'Gupta', 'Gupta@M3', 'meera.gupta@email.com', '2109876543', 'Driver'),
('ADMIN00004', 'Sanjay', 'Joshi', 'SJ#Pass123', 'sanjay.joshi@email.com', '1098765432', 'Driver'),
('ADMIN00005', 'Kavita', 'Rao', 'KR2023@Pass', 'kavita.rao@email.com', '9087654321', 'Driver');

SELECT * FROM [RegisteredUsers] 

-- Table for Renter
CREATE TABLE [Renter] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [RenterID] AS 'RENTER' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [UserID] varchar(15) NOT NULL REFERENCES RegisteredUsers(UserID),
  [TotalRentedCars] decimal(10,2) NOT NULL DEFAULT 0,
  [TotalEarnings] decimal(10,2) NOT NULL DEFAULT 0,
  [TotalRentalTime] int NOT NULL DEFAULT 0,
  [CompanyName] varchar(30),
  CONSTRAINT [PK_RenterID] PRIMARY KEY ([RenterID])
);

-- Table for Driver
CREATE TABLE [Driver] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [DriverID] AS 'Driver' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [UserID] varchar(15) NOT NULL REFERENCES RegisteredUsers(UserID),
  [LicenseNo] varchar(10) NOT NULL DEFAULT '0',
  [AvailabilityStatus] varchar(15) NOT NULL DEFAULT 'Available',
  [TotalCompletedRides] INT NOT NULL DEFAULT 0,
  [TotalEarnings] INT NOT NULL DEFAULT 0,
  [Rating] INT NOT NULL DEFAULT 0,
  CONSTRAINT [PK_DriverID] PRIMARY KEY ([DriverID]),
  CONSTRAINT CHK_AvailabilityStatus CHECK ([AvailabilityStatus] IN ('In-Transit', 'Available', 'Out-of-Service'))
);


-- Table for Rider
CREATE TABLE [Rider] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [RiderID] AS 'Rider' + RIGHT('00000' + CAST(ID AS VARCHAR(5)), 5) PERSISTED,
  [UserID] varchar(15) NOT NULL REFERENCES RegisteredUsers(UserID),
  [TotalPreviousRides] INT NOT NULL DEFAULT 0,
  [AmountDue] decimal(10,2) NOT NULL DEFAULT 0
  CONSTRAINT [PK_RiderID] PRIMARY KEY ([RiderID])
);