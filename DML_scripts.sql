INSERT INTO [Admin] (FirstName, LastName, Password)
VALUES 
('Abhinav', 'Gangurde', 'admin'),
('Akshay', 'Veerabhadraiah', 'admin'),
('Neha', 'Suresh', 'admin'),
('Om', 'Raut', 'admin'),
('Poojith', 'Kotipalli', 'admin'),
('Rajesh', 'Kumar', 'admin123'),
('Priya', 'Sharma', 'secure456'),
('Michael', 'Johnson', 'pass789'),
('Sarah', 'Williams', 'adminpwd'),
('David', 'Miller', 'access123'),
('Jessica', 'Brown', 'control789'),
('Robert', 'Davis', 'manager456'),
('Jennifer', 'Wilson', 'admin2022'),
('Daniel', 'Taylor', 'secure2023'),
('Emily', 'Anderson', 'system456'),
('Christopher', 'Thomas', 'admin789'),
('Amanda', 'Jackson', 'control123'),
('Matthew', 'White', 'access789'),
('Olivia', 'Harris', 'manager123'),
('Andrew', 'Martin', 'secure789');
select * from [Admin]


INSERT INTO [RegisteredUsers] (AdminID, FirstName, LastName, Password, EmailID, PhoneNumber, Type)
VALUES
('ADMIN00001', 'John', 'Doe', 'password123', 'john.doe@email.com', '9876543210', 'Driver'),
('ADMIN00002', 'Jane', 'Smith', 'securepass', 'jane.smith@email.com', '8765432109', 'Renter'),
('ADMIN00003', 'Robert', 'Johnson', 'pass1234', 'robert.j@email.com', '7654321098', 'Rider'),
('ADMIN00001', 'Emily', 'Brown', 'emily2023', 'emily.b@email.com', '6543210987', 'Driver'),
('ADMIN00002', 'Michael', 'Davis', 'mikepass', 'michael.d@email.com', '5432109876', 'Renter'),
('ADMIN00003', 'Sarah', 'Wilson', 'sarahw123', 'sarah.w@email.com', '4321098765', 'Rider'),
('ADMIN00004', 'David', 'Miller', 'davidm456', 'david.m@email.com', '3210987654', 'Driver'),
('ADMIN00005', 'Jessica', 'Taylor', 'jess789', 'jessica.t@email.com', '2109876543', 'Renter'),
('ADMIN00001', 'Thomas', 'Anderson', 'thomas123', 'thomas.a@email.com', '1098765432', 'Rider'),
('ADMIN00002', 'Lisa', 'Thomas', 'lisa456', 'lisa.t@email.com', '9087654321', 'Driver'),
('ADMIN00003', 'James', 'White', 'james789', 'james.w@email.com', '8976543210', 'Renter'),
('ADMIN00004', 'Jennifer', 'Harris', 'jennifer123', 'jennifer.h@email.com', '7865432109', 'Rider'),
('ADMIN00005', 'Daniel', 'Clark', 'daniel456', 'daniel.c@email.com', '6754321098', 'Driver'),
('ADMIN00001', 'Patricia', 'Lewis', 'patricia789', 'patricia.l@email.com', '5643210987', 'Renter'),
('ADMIN00002', 'Matthew', 'Walker', 'matthew123', 'matthew.w@email.com', '4532109876', 'Rider'),
('ADMIN00003', 'Elizabeth', 'Hall', 'elizabeth456', 'elizabeth.h@email.com', '3421098765', 'Driver'),
('ADMIN00004', 'Richard', 'Young', 'richard789', 'richard.y@email.com', '2310987654', 'Renter'),
('ADMIN00005', 'Linda', 'Allen', 'linda123', 'linda.a@email.com', '1209876543', 'Rider'),
('ADMIN00001', 'William', 'Scott', 'william456', 'william.s@email.com', '9198765432', 'Driver'),
('ADMIN00002', 'Barbara', 'Green', 'barbara789', 'barbara.g@email.com', '8087654321', 'Renter');
SELECT * FROM [RegisteredUsers];


INSERT INTO [Renter] (UserID, TotalRentedCars, TotalEarnings, TotalRentalTime, CompanyName)
VALUES
('R_USR00002', 5, 2500.00, 120, 'Smith Rentals'),
('R_USR00005', 3, 1800.50, 72, 'Davis Cars'),
('R_USR00008', 7, 3500.75, 168, 'Taylor Vehicles'),
('R_USR00011', 2, 1200.25, 48, 'White Auto'),
('R_USR00014', 4, 2100.50, 96, 'Lewis Motors'),
('R_USR00017', 6, 3000.00, 144, 'Young Rentals'),
('R_USR00020', 8, 4000.25, 192, 'Green Vehicles');
SELECT * FROM [Renter]


INSERT INTO [Driver] (UserID, LicenseNo, AvailabilityStatus, TotalCompletedRides, TotalEarnings, Rating)
VALUES
('R_USR00001', 'DL12345678', 'Available', 120, 6000, 4),
('R_USR00004', 'DL23456789', 'In-Transit', 85, 4250, 5),
('R_USR00007', 'DL34567890', 'Available', 150, 7500, 4),
('R_USR00010', 'DL45678901', 'Out-of-Service', 95, 4750, 3),
('R_USR00013', 'DL56789012', 'Available', 200, 10000, 5),
('R_USR00016', 'DL67890123', 'In-Transit', 110, 5500, 4),
('R_USR00019', 'DL78901234', 'Available', 175, 8750, 5);
SELECT * FROM [Driver]


INSERT INTO [Rider] (UserID, TotalPreviousRides, AmountDue)
VALUES
('R_USR00003', 25, 150.75),
('R_USR00006', 15, 85.50),
('R_USR00009', 30, 200.25),
('R_USR00012', 10, 65.00),
('R_USR00015', 35, 225.50),
('R_USR00018', 20, 120.25);
SELECT * FROM [Rider]

INSERT INTO [Car] (CarType, CarStatus, CarModel, CarYear, IsElectric)
VALUES
('Sedan', 'Available', 'Toyota Camry', 2022, 0),
('SUV', 'Rented', 'Honda CR-V', 2021, 0),
('Compact', 'Available', 'Ford Focus', 2020, 0),
('Minivans', 'In-Service', 'Chrysler Pacifica', 2022, 1),
('Hatchbacks', 'Available', 'Volkswagen Golf', 2021, 0),
('Wagon', 'Rented', 'Subaru Outback', 2022, 0),
('Sedan', 'Available', 'Honda Accord', 2021, 0),
('SUV', 'In-Service', 'Toyota RAV4', 2022, 1),
('Compact', 'Rented', 'Chevrolet Spark', 2020, 0),
('Minivans', 'Available', 'Honda Odyssey', 2021, 0),
('Hatchbacks', 'In-Service', 'Mazda 3', 2022, 0),
('Wagon', 'Available', 'Volvo V60', 2021, 1),
('Sedan', 'Rented', 'Nissan Altima', 2022, 0),
('SUV', 'Available', 'Ford Escape', 2020, 0),
('Compact', 'In-Service', 'Toyota Yaris', 2021, 0),
('Minivans', 'Rented', 'Kia Carnival', 2022, 1),
('Hatchbacks', 'Available', 'Hyundai Elantra GT', 2020, 0),
('Wagon', 'In-Service', 'Audi A4 Allroad', 2021, 0),
('Sedan', 'Available', 'Kia K5', 2022, 1),
('SUV', 'Rented', 'Mazda CX-5', 2021, 0);
SELECT * FROM [Car]
SELECT * FROM [Driver]


INSERT INTO [Driver_Car] (DriverID, CarID)
VALUES
('DRIVE00001', 'R_CAR00001'),
('DRIVE00002', 'R_CAR00003'),
('DRIVE00003', 'R_CAR00005'),
('DRIVE00004', 'R_CAR00007'),
('DRIVE00005', 'R_CAR00010'),
('DRIVE00006', 'R_CAR00012'),
('DRIVE00007', 'R_CAR00014');
SELECT * FROM [Driver_Car]


INSERT INTO [Renter_Car] (RenterID, CarID, RentalStartDate, RentalEndDate)
VALUES
('RENTR00009', 'R_CAR00002', '2025-01-01 10:00:00', '2025-01-05 10:00:00'),
('RENTR00010', 'R_CAR00006', '2025-01-02 12:00:00', '2025-01-06 12:00:00'),
('RENTR00011', 'R_CAR00009', '2025-01-03 14:00:00', '2025-01-07 14:00:00'),
('RENTR00012', 'R_CAR00013', '2025-01-04 09:00:00', '2025-01-08 09:00:00'),
('RENTR00013', 'R_CAR00016', '2025-01-05 11:00:00', '2025-01-09 11:00:00'),
('RENTR00014', 'R_CAR00019', '2025-01-06 13:00:00', '2025-01-10 13:00:00'),
('RENTR00015', 'R_CAR00020', '2025-01-07 15:00:00', '2025-01-11 15:00:00');
SELECT * FROM [Renter_Car] 


INSERT INTO [Location] (Latitude, Longitude, Region, County, City, State)
VALUES
(40.7128, -74.0060, 'Northeast', 'New York', 'New York City', 'New York'),
(34.0522, -118.2437, 'West', 'Los Angeles', 'Los Angeles', 'California'),
(42.3601, -71.0589, 'Northeast', 'Suffolk', 'Boston', 'Massachusetts'),
(37.7749, -122.4194, 'West', 'San Francisco', 'San Francisco', 'California'),
(32.7157, -117.1611, 'West', 'San Diego', 'San Diego', 'California'),
(42.2373, -71.0022, 'Northeast', 'Norfolk', 'Quincy', 'Massachusetts'),
(42.3876, -71.0995, 'Northeast', 'Middlesex', 'Cambridge', 'Massachusetts'),
(42.4928, -71.0753, 'Northeast', 'Middlesex', 'Medford', 'Massachusetts'),
(42.3751, -71.1056, 'Northeast', 'Middlesex', 'Somerville', 'Massachusetts'),
(40.6782, -73.9442, 'Northeast', 'Kings', 'Brooklyn', 'New York'),
(40.7831, -73.9712, 'Northeast', 'New York', 'Manhattan', 'New York'),
(40.7282, -73.7949, 'Northeast', 'Queens', 'Queens', 'New York'),
(40.8448, -73.8648, 'Northeast', 'Bronx', 'Bronx', 'New York'),
(37.3382, -121.8863, 'West', 'Santa Clara', 'San Jose', 'California'),
(38.5816, -121.4944, 'West', 'Sacramento', 'Sacramento', 'California')
SELECT * FROM [Location]

INSERT INTO [DriverLocation] (DriverID, GeohashID, LastUpdated)
VALUES
('DRIVE00001', (SELECT GeohashID FROM Location WHERE City = 'New York City'), '2025-03-09 14:30:00'),
('DRIVE00002', (SELECT GeohashID FROM Location WHERE City = 'Boston'), '2025-03-09 15:45:00'),
('DRIVE00003', (SELECT GeohashID FROM Location WHERE City = 'Los Angeles'), '2025-03-09 16:20:00'),
('DRIVE00004', (SELECT GeohashID FROM Location WHERE City = 'San Francisco'), '2025-03-09 17:10:00'),
('DRIVE00005', (SELECT GeohashID FROM Location WHERE City = 'Brooklyn'), '2025-03-10 08:15:00'),
('DRIVE00006', (SELECT GeohashID FROM Location WHERE City = 'Cambridge'), '2025-03-10 09:30:00'),
('DRIVE00007', (SELECT GeohashID FROM Location WHERE City = 'San Diego'), '2025-03-10 10:45:00');
SELECT * FROM [DriverLocation]


INSERT INTO [Ratecard] (State, RatePerMile, StateTax, BaseFare)
VALUES
('New York', 2.50, 8.875, 12.00),
('California', 2.25, 7.25, 10.00),
('Massachusetts', 2.40, 6.25, 11.00),
('Texas', 1.75, 6.25, 8.00),
('Arizona', 1.80, 5.60, 8.50),
('Pennsylvania', 2.10, 6.00, 9.50),
('Colorado', 2.00, 4.75, 9.00),
('Washington', 2.20, 6.50, 10.00),
('District of Columbia', 2.30, 6.00, 10.50),
('North Carolina', 1.70, 4.75, 8.00),
('Tennessee', 1.65, 7.00, 7.50),
('Ohio', 1.80, 5.75, 8.50),
('Georgia', 1.75, 4.00, 8.00),
('Michigan', 1.90, 6.00, 9.00),
('Nevada', 1.85, 6.85, 8.75),
('Florida', 1.70, 6.00, 8.00),
('Oregon', 2.10, 0.00, 9.50),
('Minnesota', 1.95, 6.88, 9.00),
('Wisconsin', 1.85, 5.00, 8.75),
('Illinois', 2.00, 6.25, 9.00);
SELECT * FROM [Ratecard]


INSERT INTO [TripRequest] (
  [RiderID], 
  [PickupLatitude], [PickupLongitude],
  [DropoffLatitude], [DropoffLongitude],
  [RequestTime], [Status]
)
VALUES
-- California trips
('RIDER00001', 34.05220000, -118.24370000, 32.71570000, -117.16110000, '2025-03-08 09:30:00', 'Completed'),
('RIDER00002', 37.77490000, -122.41940000, 37.33820000, -121.88630000, '2025-03-08 11:45:00', 'Completed'),
('RIDER00003', 38.58160000, -121.49440000, 37.77490000, -122.41940000, '2025-03-08 14:20:00', 'Completed'),
('RIDER00001', 32.71570000, -117.16110000, 34.05220000, -118.24370000, '2025-03-09 08:15:00', 'Completed'),
('RIDER00002', 37.33820000, -121.88630000, 38.58160000, -121.49440000, '2025-03-09 10:30:00', 'Completed'),

-- New York trips
('RIDER00003', 40.71280000, -74.00600000, 40.67820000, -73.94420000, '2025-03-09 13:45:00', 'Completed'),
('RIDER00001', 40.78310000, -73.97120000, 40.84480000, -73.86480000, '2025-03-09 16:20:00', 'Completed'),
('RIDER00002', 40.72820000, -73.79490000, 40.71280000, -74.00600000, '2025-03-09 18:30:00', 'Completed'),
('RIDER00003', 40.67820000, -73.94420000, 40.78310000, -73.97120000, '2025-03-10 07:45:00', 'Completed'),
('RIDER00001', 40.84480000, -73.86480000, 40.72820000, -73.79490000, '2025-03-10 09:15:00', 'Ride-In-Process'),

-- Massachusetts trips
('RIDER00002', 42.36010000, -71.05890000, 42.37510000, -71.10560000, '2025-03-10 10:30:00', 'Ride-In-Process'),
('RIDER00003', 42.38760000, -71.09950000, 42.49280000, -71.07530000, '2025-03-10 11:45:00', 'Pending'),
('RIDER00001', 42.23730000, -71.00220000, 42.36010000, -71.05890000, '2025-03-10 13:00:00', 'Completed'),
('RIDER00002', 42.37510000, -71.10560000, 42.38760000, -71.09950000, '2025-03-10 14:15:00', 'Pending'),
('RIDER00003', 42.49280000, -71.07530000, 42.23730000, -71.00220000, '2025-03-10 15:30:00', 'Canceled');
SELECT * FROM [TripRequest]



INSERT INTO [Invoice] (TripRequestID, Distance, Price)
VALUES
('TRIP_00001', 179.41, 269.120),
('TRIP_00002', 67.57, 101.360),
('TRIP_00003', 120.76, 181.140),
('TRIP_00004', 179.41, 269.120),
('TRIP_00005', 142.46, 213.700),
('TRIP_00006', 6.48, 9.720),
('TRIP_00007', 11.28, 16.920),
('TRIP_00008', 17.87, 26.810),
('TRIP_00009', 11.88, 17.830),
('TRIP_00013', 14.43, 21.640);
SELECT * FROM [Invoice]


INSERT INTO [PaymentRequest] (InvoiceID, RiderID, MethodOfPayment, Amount, Status)
VALUES
('INVO_00001', 'RIDER00001', 'Card', 269.12, 'Completed'),
('INVO_00002', 'RIDER00002', 'OnlineWallet', 101.36, 'Completed'),
('INVO_00003', 'RIDER00003', 'Cash', 181.14, 'Completed'),
('INVO_00004', 'RIDER00001', 'Card', 269.12, 'Completed'),
('INVO_00005', 'RIDER00002', 'OnlineWallet', 213.70, 'Completed'),
('INVO_00006', 'RIDER00003', 'Cash', 9.72, 'Completed'),
('INVO_00007', 'RIDER00001', 'OnlineWallet', 16.92, 'Pending'),
('INVO_00008', 'RIDER00002', 'OnlineWallet', 26.81, 'Pending'),
('INVO_00009', 'RIDER00003', 'OnlineWallet', 17.83, 'Completed'),
('INVO_00010', 'RIDER00001', 'Card', 21.64, 'Completed');
SELECT * FROM [PaymentRequest]


INSERT INTO [Card] (PaymentID, CardNumber, CardHolder, ExpiryDate, CVV, Type)
VALUES
('PAY_R00001', '4111111111111111', 'John Doe', '2027-05-31', '123', 'Visa'),
('PAY_R00004', '5555555555554444', 'John Doe', '2026-08-31', '321', 'Mastercard'),
('PAY_R00010', '6011111111111117', 'John Doe', '2026-12-31', '432', 'Discover');
SELECT * FROM [Card]


INSERT INTO [OnlineWallet] (PaymentID, WalletID, WalletProvider, AccountEmail)
VALUES
('PAY_R00002', 'WALLET123456', 'PayPal', 'jane.smith@email.com'),
('PAY_R00005', 'WALLET789012', 'Venmo', 'jane.smith@email.com'),
('PAY_R00007', 'WALLET345678', 'Apple Pay', 'john.doe@email.com'),
('PAY_R00008', 'WALLET456789', 'Google Pay', 'jane.smith@email.com'),
('PAY_R00009', 'WALLET567890', 'PayPal', 'robert.j@email.com');
SELECT * FROM [OnlineWallet] 