USE Team2_FinalProject_DMDD_v2;
GO

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


SELECT * FROM [Admin];

INSERT INTO [RegisteredUsers] (AdminID, FirstName, LastName, Password, EmailID, PhoneNumber, Type)
VALUES
-- Drivers
('ADMIN00001', 'John', 'Doe', 'password123', 'john.doe@email.com', '9876543210', 'Driver'),
('ADMIN00004', 'Emily', 'Brown', 'emily2023', 'emily.b@email.com', '6543210987', 'Driver'),
('ADMIN00002', 'David', 'Miller', 'davidm456', 'david.m@email.com', '3210987654', 'Driver'),
('ADMIN00003', 'Lisa', 'Thomas', 'lisa456', 'lisa.t@email.com', '9087654321', 'Driver'),
('ADMIN00005', 'Daniel', 'Clark', 'daniel456', 'daniel.c@email.com', '6754321098', 'Driver'),
('ADMIN00001', 'Elizabeth', 'Hall', 'elizabeth456', 'elizabeth.h@email.com', '3421098765', 'Driver'),
('ADMIN00002', 'William', 'Scott', 'william456', 'william.s@email.com', '9198765432', 'Driver'),
('ADMIN00003', 'Mark', 'Johnson', 'mark123', 'mark.j@email.com', '8187654321', 'Driver'),
('ADMIN00004', 'Susan', 'Williams', 'susan456', 'susan.w@email.com', '7176543210', 'Driver'),
('ADMIN00005', 'Kevin', 'Brown', 'kevin789', 'kevin.b@email.com', '6165432109', 'Driver'),
('ADMIN00001', 'Laura', 'Jones', 'laura123', 'laura.j@email.com', '5154321098', 'Driver'),
('ADMIN00002', 'Brian', 'Miller', 'brian456', 'brian.m@email.com', '4143210987', 'Driver'),
('ADMIN00003', 'Karen', 'Davis', 'karen789', 'karen.d@email.com', '3132109876', 'Driver'),
('ADMIN00004', 'Edward', 'Wilson', 'edward123', 'edward.w@email.com', '2121098765', 'Driver'),
('ADMIN00005', 'Nancy', 'Taylor', 'nancy456', 'nancy.t@email.com', '1110987654', 'Driver'),
('ADMIN00001', 'Michael', 'Scott', 'drvpass2', 'michael.scott@example.com', '2125550102', 'Driver'),
('ADMIN00002', 'Jim', 'Halpert', 'drvpass3', 'jim.halpert@example.com', '2125550103', 'Driver'),
('ADMIN00003', 'Pam', 'Beesly', 'drvpass4', 'pam.beesly@example.com', '2125550104', 'Driver'),
('ADMIN00004', 'Dwight', 'Schrute', 'drvpass5', 'dwight.schrute@example.com', '2125550105', 'Driver'),
('ADMIN00005', 'Stanley', 'Hudson', 'drvpass6', 'stanley.hudson@example.com', '2125550106', 'Driver'),
('ADMIN00001', 'Phyllis', 'Vance', 'drvpass7', 'phyllis.vance@example.com', '2125550107', 'Driver'),
('ADMIN00002', 'Oscar', 'Martinez', 'drvpass8', 'oscar.martinez@example.com', '2125550108', 'Driver'),
('ADMIN00003', 'Kevin', 'Malone', 'drvpass9', 'kevin.malone@example.com', '2125550109', 'Driver'),
('ADMIN00004', 'Angela', 'Martin', 'drvpass10', 'angela.martin@example.com', '2125550110', 'Driver'),
('ADMIN00005', 'Creed', 'Bratton', 'drvpass11', 'creed.bratton@example.com', '2125550111', 'Driver'),
('ADMIN00001', 'Meredith', 'Palmer', 'drvpass12', 'meredith.palmer@example.com', '2125550112', 'Driver'),
('ADMIN00002', 'Kelly', 'Kapoor', 'drvpass13', 'kelly.kapoor@example.com', '2125550113', 'Driver'),
('ADMIN00003', 'Ryan', 'Howard', 'drvpass14', 'ryan.howard@example.com', '2125550114', 'Driver'),
('ADMIN00004', 'Jim', 'Halpert', 'drvpass15', 'jim.halpert2@example.com', '2125550115', 'Driver'),
('ADMIN00005', 'Pam', 'Beesly', 'drvpass16', 'pam.beesly2@example.com', '2125550116', 'Driver'),
('ADMIN00005', 'Dwight', 'Schrute', 'drvpass17', 'dwight.schrute2@example.com', '2125550117', 'Driver'),

-- Renters
('ADMIN00002', 'Jane', 'Smith', 'securepass', 'jane.smith@email.com', '8765432109', 'Renter'),
('ADMIN00003', 'Michael', 'Davis', 'mikepass', 'michael.d@email.com', '5432109876', 'Renter'),
('ADMIN00001', 'Jessica', 'Taylor', 'jess789', 'jessica.t@email.com', '2109876543', 'Renter'),
('ADMIN00004', 'James', 'White', 'james789', 'james.w@email.com', '8976543210', 'Renter'),
('ADMIN00005', 'Patricia', 'Lewis', 'patricia789', 'patricia.l@email.com', '5643210987', 'Renter'),
('ADMIN00001', 'Richard', 'Young', 'richard789', 'richard.y@email.com', '2310987654', 'Renter'),
('ADMIN00002', 'Barbara', 'Green', 'barbara789', 'barbara.g@email.com', '8087654321', 'Renter'),
('ADMIN00003', 'Thomas', 'Moore', 'thomas456', 'thomas.m@email.com', '7076543210', 'Renter'),
('ADMIN00004', 'Jennifer', 'Lee', 'jennifer789', 'jennifer.l@email.com', '6065432109', 'Renter'),
('ADMIN00005', 'Charles', 'Harris', 'charles123', 'charles.h@email.com', '5054321098', 'Renter'),
('ADMIN00001', 'Margaret', 'Clark', 'margaret456', 'margaret.c@email.com', '4043210987', 'Renter'),
('ADMIN00002', 'Joseph', 'Lewis', 'joseph789', 'joseph.l@email.com', '3032109876', 'Renter'),
('ADMIN00003', 'Carol', 'Walker', 'carol123', 'carol.w@email.com', '2021098765', 'Renter'),
('ADMIN00004', 'George', 'Hall', 'george456', 'george.h@email.com', '1010987654', 'Renter'),
('ADMIN00005', 'Ruth', 'Allen', 'ruth789', 'ruth.a@email.com', '9009876543', 'Renter'),
('ADMIN00001', 'Alice', 'Cooper', 'rntpass1', 'alice.cooper@example.com', '3125550101', 'Renter'),
('ADMIN00002', 'Bruce', 'Wayne', 'rntpass2', 'bruce.wayne@example.com', '3125550102', 'Renter'),
('ADMIN00003', 'Clark', 'Kent', 'rntpass3', 'clark.kent@example.com', '3125550103', 'Renter'),
('ADMIN00004', 'Diana', 'Prince', 'rntpass4', 'diana.prince@example.com', '3125550104', 'Renter'),
('ADMIN00005', 'Peter', 'Parker', 'rntpass5', 'peter.parker@example.com', '3125550105', 'Renter'),
('ADMIN00003', 'Tony', 'Stark', 'rntpass6', 'tony.stark@example.com', '3125550106', 'Renter'),
('ADMIN00001', 'Steve', 'Rogers', 'rntpass7', 'steve.rogers@example.com', '3125550107', 'Renter'),
('ADMIN00002', 'Natasha', 'Romanoff', 'rntpass8', 'natasha.romanoff@example.com', '3125550108', 'Renter'),
('ADMIN00003', 'Bruce', 'Banner', 'rntpass9', 'bruce.banner@example.com', '3125550109', 'Renter'),
('ADMIN00004', 'Scott', 'Lang', 'rntpass10', 'scott.lang@example.com', '3125550110', 'Renter'),
('ADMIN00005', 'Wade', 'Wilson', 'rntpass11', 'wade.wilson@example.com', '3125550111', 'Renter'),
('ADMIN00001', 'Peter', 'Quill', 'rntpass12', 'peter.quill@example.com', '3125550112', 'Renter'),
('ADMIN00002', 'Gamora', 'Zen', 'rntpass13', 'gamora.zen@example.com', '3125550113', 'Renter'),
('ADMIN00003', 'Rocket', 'Raccoon', 'rntpass14', 'rocket.raccoon@example.com', '3125550114', 'Renter'),
('ADMIN00004', 'Groot', 'Tree', 'rntpass15', 'groot.tree@example.com', '3125550115', 'Renter'),
('ADMIN00005', 'Stephen', 'Strange', 'rntpass16', 'stephen.strange@example.com', '3125550116', 'Renter'),
('ADMIN00001', 'Barry', 'Allen', 'rntpass17', 'barry.allen@example.com', '3125550117', 'Renter'),

-- Riders
('ADMIN00003', 'Robert', 'Johnson', 'pass1234', 'robert.j@email.com', '7654321098', 'Rider'),
('ADMIN00001', 'Sarah', 'Wilson', 'sarahw123', 'sarah.w@email.com', '4321098765', 'Rider'),
('ADMIN00002', 'Thomas', 'Anderson', 'thomas123', 'thomas.a@email.com', '1098765432', 'Rider'),
('ADMIN00004', 'Jennifer', 'Harris', 'jennifer123', 'jennifer.h@email.com', '7865432109', 'Rider'),
('ADMIN00005', 'Matthew', 'Walker', 'matthew123', 'matthew.w@email.com', '4532109876', 'Rider'),
('ADMIN00001', 'Linda', 'Allen', 'linda123', 'linda.a@email.com', '1209876543', 'Rider'),
('ADMIN00002', 'Paul', 'Martin', 'paul456', 'paul.m@email.com', '9098765432', 'Rider'),
('ADMIN00003', 'Betty', 'Thompson', 'betty789', 'betty.t@email.com', '8087654321', 'Rider'),
('ADMIN00004', 'Donald', 'Garcia', 'donald123', 'donald.g@email.com', '7076543210', 'Rider'),
('ADMIN00005', 'Sandra', 'Martinez', 'sandra456', 'sandra.m@email.com', '6065432109', 'Rider'),
('ADMIN00001', 'Andrew', 'Robinson', 'andrew789', 'andrew.r@email.com', '5054321098', 'Rider'),
('ADMIN00002', 'Dorothy', 'Clark', 'dorothy123', 'dorothy.c@email.com', '4043210987', 'Rider'),
('ADMIN00003', 'Steven', 'Rodriguez', 'steven456', 'steven.r@email.com', '3032109876', 'Rider'),
('ADMIN00004', 'Kimberly', 'Lewis', 'kimberly789', 'kimberly.l@email.com', '2021098765', 'Rider'),
('ADMIN00005', 'Kenneth', 'Lee', 'kenneth123', 'kenneth.l@email.com', '1010987654', 'Rider'),
('ADMIN00001', 'Bruce', 'Lee', 'rdrpass1', 'bruce.lee@example.com', '4155550101', 'Rider'),
('ADMIN00002', 'Jackie', 'Chan', 'rdrpass2', 'jackie.chan@example.com', '4155550102', 'Rider'),
('ADMIN00003', 'Chuck', 'Norris', 'rdrpass3', 'chuck.norris@example.com', '4155550103', 'Rider'),
('ADMIN00004', 'Jean', 'Claude', 'rdrpass4', 'jeanclaude@example.com', '4155550104', 'Rider'),
('ADMIN00005', 'Sylvester', 'Stallone', 'rdrpass5', 'sylvester.stallone@example.com', '4155550105', 'Rider'),
('ADMIN00001', 'Arnold', 'Schwarzenegger', 'rdrpass6', 'arnold.s@example.com', '4155550106', 'Rider'),
('ADMIN00005', 'Harrison', 'Ford', 'rdrpass7', 'harrison.ford@example.com', '4155550107', 'Rider'),
('ADMIN00005', 'Clint', 'Eastwood', 'rdrpass8', 'clint.eastwood@example.com', '4155550108', 'Rider'),
('ADMIN00005', 'Morgan', 'Freeman', 'rdrpass9', 'morgan.freeman@example.com', '4155550109', 'Rider'),
('ADMIN00005', 'Leonardo', 'DiCaprio', 'rdrpass10', 'leo@example.com', '4155550110', 'Rider'),
('ADMIN00005', 'Brad', 'Pitt', 'rdrpass11', 'brad.pitt@example.com', '4155550111', 'Rider'),
('ADMIN00005', 'Johnny', 'Depp', 'rdrpass12', 'johnny.depp@example.com', '4155550112', 'Rider'),
('ADMIN00005', 'Tom', 'Cruise', 'rdrpass13', 'tom.cruise@example.com', '4155550113', 'Rider'),
('ADMIN00005', 'Will', 'Smith', 'rdrpass14', 'will.smith@example.com', '4155550114', 'Rider'),
('ADMIN00004', 'Emma', 'Stone', 'rdrpass15', 'emma.stone@example.com', '4155550115', 'Rider'),
('ADMIN00001', 'Scarlett', 'Johansson', 'rdrpass16', 'scarlett.j@example.com', '4155550116', 'Rider');
SELECT * FROM [RegisteredUsers];

-- Renter Users addition 
SELECT * FROM [RegisteredUsers] WHERE Type='Renter';
INSERT INTO [Renter] (UserID, TotalRentedCars, TotalEarnings, TotalRentalTime, CompanyName)
VALUES
('R_USR00032', 4, 2200.75, 96, 'Hall Vehicles'),
('R_USR00033', 6, 3000.00, 144, 'N/A'),
('R_USR00034', 3, 1700.25, 72, 'Allen Motors'),
('R_USR00035', 7, 3600.50, 168, 'Scott Rentals'),
('R_USR00036', 8, 4000.25, 192, 'Allen Motors'),
('R_USR00037', 5, 2400.00, 120, 'N/A'),
('R_USR00038', 9, 4500.75, 216, 'Allen Motors'),
('R_USR00039', 2, 1100.50, 48, 'Hall Vehicles'),
('R_USR00040', 6, 3100.25, 144, 'Clark Motors'),
('R_USR00041', 4, 2300.75, 96, 'N/A'),
('R_USR00042', 7, 3700.00, 168, 'N/A'),
('R_USR00043', 3, 1600.50, 72, 'Hall Motors'),
('R_USR00044', 5, 2700.25, 120, 'Hall Vehicles'),
('R_USR00045', 8, 4200.00, 192, 'N/A'),
('R_USR00046', 4, 2000.50, 96, 'Thompson Motors'),
('R_USR00047', 28, 175.25, 96, 'Hall Vehicles'),
('R_USR00048', 18, 110.50, 72, 'Hall Vehicles'),
('R_USR00049', 33, 215.75, 96, 'Allen Motors'),
('R_USR00050', 12, 75.00, 48, 'Scott Rentals'),
('R_USR00051', 38, 240.50, 120, 'Green Vehicles'),
('R_USR00052', 22, 135.25, 72, 'Allen Motors'),
('R_USR00053', 16, 95.75, 60, 'N/A'),
('R_USR00054', 27, 165.50, 84, 'Hall Vehicles'),
('R_USR00055', 40, 255.25, 96, 'Clark Motors'),
('R_USR00056', 14, 85.00, 48, 'Hall Vehicles'),
('R_USR00057', 31, 195.50, 84, 'Downtown Rentals'),
('R_USR00058', 19, 115.25, 60, 'Hall Vehicles'),
('R_USR00059', 36, 230.75, 96, 'Allen Vehicles'),
('R_USR00060', 24, 145.50, 72, 'Hall Vehicles'),
('R_USR00061', 11, 70.25, 48, 'N/A'),
('R_USR00062', 15, 125.50, 60, 'Downtown Rentals'),
('R_USR00063', 20, 180.00, 72, 'Hall Vehicles');
SELECT * FROM [Renter];

-- Driver Users addition
SELECT * FROM [RegisteredUsers] WHERE Type='Driver';
INSERT INTO [Driver] (UserID, LicenseNo, AvailabilityStatus, TotalCompletedRides, TotalEarnings, Rating)
VALUES
('R_USR00001', 'DL10000002', 'In-Transit', 110, 5400, 3.5),
('R_USR00002', 'DL10000003', 'Available', 130, 6100, 5),
('R_USR00003', 'DL10000004', 'Out-of-Service', 100, 5000, 2.5),
('R_USR00004', 'DL10000005', 'Available', 140, 6500, 5),
('R_USR00005', 'DL10000006', 'In-Transit', 115, 5200, 3),
('R_USR00005', 'DL23456790', 'Available', 130, 6500, 4.5),
('R_USR00006', 'DL34567891', 'In-Transit', 95, 4750, 5),
('R_USR00007', 'DL34567890', 'Available', 150, 7500, 4),
('R_USR00008', 'DL45678902', 'Out-of-Service', 105, 5250, 3),
('R_USR00009', 'DL56789013', 'Available', 180, 9000, 5),
('R_USR00010', 'DL45678901', 'Out-of-Service', 95, 4750, 3),
('R_USR00011', 'DL67890124', 'In-Transit', 120, 6000, 4),
('R_USR00012', 'DL78901235', 'Available', 160, 8000, 5),
('R_USR00013', 'DL56789012', 'Available', 200, 10000, 5),
('R_USR00014', 'DL89012346', 'Out-of-Service', 110, 5500, 3),
('R_USR00015', 'DL90123457', 'In-Transit', 140, 7000, 4),
('R_USR00016', 'DL10000001', 'Available', 120, 5800, 4.5),
('R_USR00017', 'DL10000007', 'Available', 150, 7000, 5),
('R_USR00018', 'DL10000008', 'Out-of-Service', 125, 6000, 4),
('R_USR00019', 'DL10000009', 'Available', 135, 6400, 4.5),
('R_USR00020', 'DL10000017', 'Available', 170, 8000, 3.5),
('R_USR00021', 'DL10000018', 'In-Transit', 125, 6100, 2.5),
('R_USR00022', 'DL10000019', 'Available', 135, 6400, 5),
('R_USR00023', 'DL10000020', 'Out-of-Service', 140, 6600, 3),
('R_USR00024', 'DL10000021', 'Available', 150, 7000, 5),
('R_USR00025', 'DL10000010', 'In-Transit', 145, 6800, 4),
('R_USR00026', 'DL10000011', 'Available', 155, 7200, 5),
('R_USR00027', 'DL10000012', 'Out-of-Service', 110, 5300, 3),
('R_USR00028', 'DL10000013', 'Available', 160, 7500, 5),
('R_USR00029', 'DL10000014', 'In-Transit', 120, 5600, 4),
('R_USR00030', 'DL10000015', 'Available', 165, 7800, 5),
('R_USR00031', 'DL10000016', 'Out-of-Service', 130, 6000, 3.5)
SELECT * FROM [Driver];


-- Rider Users addition
SELECT * FROM [RegisteredUsers] WHERE Type='Rider';
INSERT INTO [Rider] (UserID, TotalPreviousRides, AmountDue)
VALUES
('R_USR00064', 28, 120.25),
('R_USR00065', 21, 98.75),
('R_USR00066', 26, 112.50),
('R_USR00067', 32, 135.00),
('R_USR00068', 20, 90.25),
('R_USR00069', 25, 110.00),
('R_USR00070', 29, 125.75),
('R_USR00071', 23, 100.50),
('R_USR00072', 27, 115.00),
('R_USR00073', 31, 130.25),
('R_USR00074', 18, 85.75),
('R_USR00075', 24, 105.00),
('R_USR00076', 29, 120.50),
('R_USR00077', 22, 95.25),
('R_USR00078', 26, 110.75),
('R_USR00079', 30, 125.00),
('R_USR00080', 20, 90.50),
('R_USR00081', 25, 107.25),
('R_USR00082', 29, 122.00),
('R_USR00083', 23, 99.50),
('R_USR00084', 27, 115.75),
('R_USR00085', 31, 130.00),
('R_USR00086', 18, 86.25),
('R_USR00087', 24, 106.50),
('R_USR00088', 29, 121.75),
('R_USR00089', 22, 96.00),
('R_USR00090', 26, 111.25),
('R_USR00091', 30, 126.50),
('R_USR00092', 20, 91.00),
('R_USR00093', 25, 107.75),
('R_USR00094', 29, 123.00);
SELECT * FROM [Rider]

-- Car Table
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
('SUV', 'Rented', 'Mazda CX-5', 2021, 0),
('Sedan', 'Available', 'Toyota Corolla', 2020, 0),
('Sedan', 'Available', 'Toyota Camry', 2022, 0),
('SUV', 'Rented', 'Honda CR-V', 2021, 0),
('Compact', 'Available', 'Ford Focus', 2020, 0),
('Minivans', 'In-Service', 'Chrysler Pacifica', 2022, 1),
('Hatchbacks', 'Available', 'Volkswagen Golf', 2021, 0),
('Wagon', 'Rented', 'Subaru Outback', 2022, 0),
('Sedan', 'Available', 'Honda Accord', 2021, 0),
('SUV', 'In-Service', 'Toyota RAV4', 2022, 1),
('Compact', 'Rented', 'Chevrolet Spark', 2020, 0),
('Minivans', 'Available', 'Honda Odyssey', 2021, 0);
SELECT * FROM [Car];


INSERT INTO [Driver_Car] (DriverID, CarID)
VALUES
('DRIVE00001', 'R_CAR00003'),
('DRIVE00002', 'R_CAR00014'),
('DRIVE00003', 'R_CAR00009'),
('DRIVE00004', 'R_CAR00019'),
('DRIVE00005', 'R_CAR00016'),
('DRIVE00006', 'R_CAR00013'),
--('DRIVE00007', 'R_CAR00032'),
('DRIVE00008', 'R_CAR00008'),
('DRIVE00009', 'R_CAR00029'),
('DRIVE00010', 'R_CAR00004'),
('DRIVE00011', 'R_CAR00005'),
('DRIVE00012', 'R_CAR00012'),
('DRIVE00013', 'R_CAR00002'),
('DRIVE00014', 'R_CAR00001'),
('DRIVE00015', 'R_CAR00027'),
('DRIVE00016', 'R_CAR00011'),
('DRIVE00017', 'R_CAR00028'),
('DRIVE00018', 'R_CAR00007'),
('DRIVE00019', 'R_CAR00022'),
('DRIVE00020', 'R_CAR00021'),
('DRIVE00021', 'R_CAR00018'),
('DRIVE00022', 'R_CAR00026'),
('DRIVE00023', 'R_CAR00023'),
('DRIVE00024', 'R_CAR00031'),
('DRIVE00025', 'R_CAR00015'),
('DRIVE00026', 'R_CAR00025'),
('DRIVE00027', 'R_CAR00030'),
('DRIVE00028', 'R_CAR00006'),
('DRIVE00029', 'R_CAR00024'),
('DRIVE00030', 'R_CAR00017'),
('DRIVE00031', 'R_CAR00020'),
('DRIVE00032', 'R_CAR00010');
SELECT * FROM [Driver_Car];

--Table Renter_Car
INSERT INTO [Renter_Car] (RenterID, CarID, RentalStartDate, RentalEndDate)
VALUES
('RENTR00001', 'R_CAR00003', '2025-03-23 14:00:00', '2025-03-27 18:00:00'),
('RENTR00002', 'R_CAR00014', '2025-05-20 12:00:00', '2025-05-23 13:00:00'),
('RENTR00003', 'R_CAR00009', '2025-05-21 14:00:00', '2025-05-26 16:00:00'),
('RENTR00004', 'R_CAR00019', '2025-05-11 13:00:00', '2025-05-14 16:00:00'),
('RENTR00005', 'R_CAR00016', '2025-04-04 11:00:00', '2025-04-07 12:00:00'),
('RENTR00006', 'R_CAR00013', '2025-03-15 13:00:00', '2025-03-19 14:00:00'),
--('RENTR00007', 'R_CAR00032', '2025-05-03 10:00:00', '2025-05-09 15:00:00'),
('RENTR00008', 'R_CAR00008', '2025-03-25 12:00:00', '2025-03-31 15:00:00'),
('RENTR00009', 'R_CAR00029', '2025-03-01 11:00:00', '2025-03-07 16:00:00'),
('RENTR00010', 'R_CAR00004', '2025-03-20 14:00:00', '2025-03-25 15:00:00'),
('RENTR00011', 'R_CAR00005', '2025-03-10 10:00:00', '2025-03-15 15:00:00'),
('RENTR00012', 'R_CAR00012', '2025-04-16 13:00:00', '2025-04-21 17:00:00'),
('RENTR00013', 'R_CAR00002', '2025-05-24 12:00:00', '2025-05-30 13:00:00'),
('RENTR00014', 'R_CAR00001', '2025-03-21 13:00:00', '2025-03-26 13:00:00'),
('RENTR00015', 'R_CAR00027', '2025-03-12 11:00:00', '2025-03-16 11:00:00'),
('RENTR00016', 'R_CAR00011', '2025-04-19 10:00:00', '2025-04-25 13:00:00'),
('RENTR00017', 'R_CAR00028', '2025-04-17 14:00:00', '2025-04-20 17:00:00'),
('RENTR00018', 'R_CAR00007', '2025-03-03 13:00:00', '2025-03-09 16:00:00'),
('RENTR00019', 'R_CAR00022', '2025-03-29 10:00:00', '2025-04-04 13:00:00'),
('RENTR00020', 'R_CAR00021', '2025-03-13 14:00:00', '2025-03-19 15:00:00'),
('RENTR00021', 'R_CAR00018', '2025-03-30 10:00:00', '2025-04-06 13:00:00'),
('RENTR00022', 'R_CAR00026', '2025-04-17 11:00:00', '2025-04-22 15:00:00'),
('RENTR00023', 'R_CAR00023', '2025-04-06 12:00:00', '2025-04-12 14:00:00'),
('RENTR00024', 'R_CAR00031', '2025-03-13 10:00:00', '2025-03-20 10:00:00'),
('RENTR00025', 'R_CAR00015', '2025-05-04 10:00:00', '2025-05-09 15:00:00'),
('RENTR00026', 'R_CAR00025', '2025-04-11 12:00:00', '2025-04-17 15:00:00'),
('RENTR00027', 'R_CAR00030', '2025-05-12 10:00:00', '2025-05-18 14:00:00'),
('RENTR00028', 'R_CAR00006', '2025-03-05 13:00:00', '2025-03-11 17:00:00'),
('RENTR00029', 'R_CAR00024', '2025-05-22 12:00:00', '2025-05-27 16:00:00'),
('RENTR00030', 'R_CAR00017', '2025-05-01 12:00:00', '2025-05-08 17:00:00'),
('RENTR00031', 'R_CAR00020', '2025-05-19 14:00:00', '2025-05-22 15:00:00'),
('RENTR00032', 'R_CAR00010', '2025-04-29 14:00:00', '2025-05-03 18:00:00');
SELECT * FROM [Renter_Car];



INSERT INTO [Location] (Latitude, Longitude, Region, County, City, State)
VALUES
(42.3601, -71.0589, 'Northeast', 'Suffolk', 'Boston', 'Massachusetts'),
(42.3751, -71.1056, 'Northeast', 'Middlesex', 'Somerville', 'Massachusetts'),
(42.3876, -71.0995, 'Northeast', 'Middlesex', 'Cambridge', 'Massachusetts'),
(42.4928, -71.0753, 'Northeast', 'Middlesex', 'Medford', 'Massachusetts'),
(42.2373, -71.0022, 'Northeast', 'Norfolk', 'Quincy', 'Massachusetts'),
(42.4668, -70.9495, 'Northeast', 'Essex', 'Lynn', 'Massachusetts'),
(42.6334, -70.7829, 'Northeast', 'Essex', 'Gloucester', 'Massachusetts'),
(42.5195, -70.8967, 'Northeast', 'Essex', 'Salem', 'Massachusetts'),
(42.0834, -72.5914, 'Northeast', 'Hampden', 'Springfield', 'Massachusetts'),
(42.1015, -72.5898, 'Northeast', 'Hampden', 'West Springfield', 'Massachusetts'),
(42.3251, -72.6412, 'Northeast', 'Hampshire', 'Northampton', 'Massachusetts'),
(41.6589, -70.2804, 'Northeast', 'Barnstable', 'Barnstable Town', 'Massachusetts'),
(41.6362, -70.9342, 'Northeast', 'Bristol', 'New Bedford', 'Massachusetts'),
(41.7015, -70.3106, 'Northeast', 'Barnstable', 'Falmouth', 'Massachusetts'),
(41.9900, -70.9727, 'Northeast', 'Plymouth', 'Brockton', 'Massachusetts'),
(41.8459, -70.9717, 'Northeast', 'Plymouth', 'Plymouth Town', 'Massachusetts'),
(42.4584, -71.1402, 'Northeast', 'Middlesex', 'Waltham', 'Massachusetts'),
(42.5584, -71.8803, 'Northeast', 'Worcester', 'Leominster', 'Massachusetts'),
(42.2626,-71.8023,'Northeast','Worcester','Worcester','Massachusetts'),
(40.7831, -73.9712, 'Northeast', 'New York', 'Upper West Side', 'New York'),
(40.7488, -73.9857, 'Northeast', 'New York', 'Midtown Manhattan', 'New York'),
(40.7306, -73.9866, 'Northeast', 'New York', 'East Village', 'New York'),
(40.7075, -74.0113, 'Northeast', 'New York', 'Financial District', 'New York'),
(40.8021, -73.9524, 'Northeast', 'New York', 'Harlem', 'New York'),
(40.6782, -73.9442, 'Northeast', 'Kings', 'Brooklyn Heights', 'New York'),
(40.6501, -73.9496, 'Northeast', 'Kings', 'Flatbush', 'New York'),
(40.5749, -73.9840, 'Northeast', 'Kings', 'Coney Island', 'New York'),
(40.6934, -73.9533, 'Northeast', 'Kings', 'Williamsburg', 'New York'),
(40.6788, -73.9419, 'Northeast', 'Kings', 'Bedford-Stuyvesant', 'New York'),
(40.7421, -73.9193, 'Northeast', 'Queens', 'Astoria', 'New York'),
(40.7480, -73.8654, 'Northeast', 'Queens', 'Flushing Meadows-Corona Park', 'New York'),
(40.7295, -73.7962, 'Northeast', 'Queens', 'Jamaica Estates', 'New York'),
(40.7557, -73.8831, 'Northeast', 'Queens', 'Elmhurst', 'New York'),
(40.6895, -73.7962, 'Northeast', 'Queens', 'Howard Beach', 'New York');
SELECT * FROM [Driver]


INSERT INTO [DriverLocation] (DriverID, GeohashID, LastUpdated)
VALUES
('DRIVE00001', (SELECT GeohashID FROM Location WHERE City = 'Financial District'), '2025-03-09 14:30:00'),
('DRIVE00002', (SELECT GeohashID FROM Location WHERE City = 'Boston'), '2025-03-09 15:45:00'),
('DRIVE00003', (SELECT GeohashID FROM Location WHERE City = 'Boston'), '2025-03-09 16:20:00'),
('DRIVE00004', (SELECT GeohashID FROM Location WHERE City = 'Upper West Side'), '2025-03-09 17:10:00'),
('DRIVE00005', (SELECT GeohashID FROM Location WHERE City = 'Jamaica Estates'), '2025-03-10 08:15:00'),
('DRIVE00006', (SELECT GeohashID FROM Location WHERE City = 'Cambridge'), '2025-03-10 09:30:00'),
('DRIVE00007', (SELECT GeohashID FROM Location WHERE City = 'Howard Beach'), '2025-03-10 10:45:00'),
('DRIVE00008', (SELECT GeohashID FROM Location WHERE City = 'Financial District'), '2025-03-10 10:45:00'),
('DRIVE00009', (SELECT GeohashID FROM Location WHERE City = 'Cambridge'), '2025-03-10 10:45:00'),
('DRIVE00010', (SELECT GeohashID FROM Location WHERE City = 'Medford'), '2025-03-10 10:45:00'),
('DRIVE00011', (SELECT GeohashID FROM Location WHERE City = 'Quincy'), '2025-03-10 10:45:00'),
('DRIVE00012', (SELECT GeohashID FROM Location WHERE City = 'Howard Beach'), '2025-07-25 10:00:00'),
('DRIVE00013', (SELECT GeohashID FROM Location WHERE City = 'Financial District'), '2025-07-25 10:15:00'),
('DRIVE00014', (SELECT GeohashID FROM Location WHERE City = 'Quincy'), '2025-07-25 10:30:00'),
('DRIVE00015', (SELECT GeohashID FROM Location WHERE City = 'Boston'), '2025-07-25 10:45:00'),
('DRIVE00016', (SELECT GeohashID FROM Location WHERE City = 'Cambridge'), '2025-07-25 11:00:00'),
('DRIVE00017', (SELECT GeohashID FROM Location WHERE City = 'Boston'), '2025-07-25 11:15:00'),
('DRIVE00018', (SELECT GeohashID FROM Location WHERE City = 'Coney Island'), '2025-07-25 11:30:00'),
('DRIVE00019', (SELECT GeohashID FROM Location WHERE City = 'Quincy'), '2025-07-25 11:45:00'),
('DRIVE00020', (SELECT GeohashID FROM Location WHERE City = 'Quincy'), '2025-07-25 12:00:00'),
('DRIVE00021', (SELECT GeohashID FROM Location WHERE City = 'Boston'), '2025-07-25 12:15:00'),
('DRIVE00022', (SELECT GeohashID FROM Location WHERE City = 'Cambridge'), '2025-07-25 12:30:00'),
('DRIVE00023', (SELECT GeohashID FROM Location WHERE City = 'Worcester'), '2025-07-25 12:45:00'),
('DRIVE00024', (SELECT GeohashID FROM Location WHERE City = 'Cambridge'), '2025-07-25 13:00:00'),
('DRIVE00025', (SELECT GeohashID FROM Location WHERE City = 'Howard Beach'), '2025-07-25 13:15:00'),
('DRIVE00026', (SELECT GeohashID FROM Location WHERE City = 'Quincy'), '2025-07-25 13:30:00'),
('DRIVE00027', (SELECT GeohashID FROM Location WHERE City = 'Quincy'), '2025-07-25 13:45:00'),
('DRIVE00028', (SELECT GeohashID FROM Location WHERE City = 'Worcester'), '2025-07-25 14:00:00'),
('DRIVE00029', (SELECT GeohashID FROM Location WHERE City = 'Cambridge'), '2025-07-25 14:15:00'),
('DRIVE00030', (SELECT GeohashID FROM Location WHERE City = 'Worcester'), '2025-07-25 14:30:00'),
('DRIVE00031', (SELECT GeohashID FROM Location WHERE City = 'Howard Beach'), '2025-07-25 14:45:00'),
('DRIVE00032', (SELECT GeohashID FROM Location WHERE City = 'Somerville'), '2025-07-25 15:00:00');
SELECT * FROM [DriverLocation];


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
SELECT * FROM [Ratecard];


SELECT * FROM Rider


INSERT INTO [TripRequest] ( [RiderID],[PickupLatitude], [PickupLongitude],[DropoffLatitude], [DropoffLongitude],[RequestTime], [Status]) 
VALUES
 ('RIDER00001', 40.5749, -73.9840, 40.7075, -74.0113, '2025-03-31 08:00:00', 'Completed'),
 ('RIDER00002', 40.6501, -73.9496, 40.6782, -73.9442, '2025-03-31 08:15:00', 'Ride-In-Process'),
 ('RIDER00003', 40.6788, -73.9419, 40.7306, -73.9866, '2025-03-31 08:30:00', 'Completed'),
 ('RIDER00004', 40.6934, -73.9533, 40.7488, -73.9857, '2025-03-31 08:45:00', 'Pending'),
 ('RIDER00005', 40.7421, -73.9193, 40.7557, -73.8831, '2025-03-31 09:00:00', 'Canceled'),
 ('RIDER00006', 40.7480, -73.8654, 40.6895, -73.7962, '2025-03-31 09:15:00', 'Completed'),
 ('RIDER00007', 40.7295, -73.7962, 40.7831, -73.9712, '2025-03-31 09:30:00', 'Completed'),
 ('RIDER00008', 40.8021, -73.9524, 42.0834, -72.5914, '2025-03-31 09:45:00', 'Ride-In-Process'),
 ('RIDER00009', 42.1015, -72.5898, 41.6362, -70.9342, '2025-03-31 10:00:00', 'Completed'),
 ('RIDER00010', 41.8459, -70.9717, 41.9900, -70.9727, '2025-03-31 10:15:00', 'Pending'),
 ('RIDER00011', 41.6589, -70.2804, 41.7015, -70.3106, '2025-03-31 10:30:00', 'Completed'),
 ('RIDER00012', 42.3251, -72.6412, 42.2626, -71.8023, '2025-03-31 10:45:00', 'Completed'),
 ('RIDER00013', 42.5584, -71.8803, 42.3601, -71.0589, '2025-03-31 11:00:00', 'Ride-In-Process'),
 ('RIDER00014', 42.3751, -71.1056, 42.3876, -71.0995, '2025-03-31 11:15:00', 'Completed'),
 ('RIDER00015', 42.4584, -71.1402, 42.4928, -71.0753, '2025-03-31 11:30:00', 'Completed'),
 ('RIDER00016', 42.2373, -71.0022, 42.4668, -70.9495, '2025-03-31 11:45:00', 'Pending'),
 ('RIDER00017', 42.5195, -70.8967, 42.6334, -70.7829, '2025-03-31 12:00:00', 'Completed');
SELECT * FROM [TripRequest]

SELECT * FROM [TripRequest] WHERE Status='Completed'

INSERT INTO [Invoice] (TripRequestID, Distance, Price)
VALUES
('TRIP_00001', 145.80, 218.50),
('TRIP_00003', 180.20, 270.30),
('TRIP_00006', 220.10, 330.15),
('TRIP_00007', 190.50, 285.75),
('TRIP_00009', 210.00, 315.00),
('TRIP_00011', 230.25, 345.50),
('TRIP_00012', 175.90, 263.85),
('TRIP_00014', 250.75, 376.10),
('TRIP_00015', 210.30, 315.45),
('TRIP_00017', 235.60, 353.40);
SELECT * FROM [Invoice];


INSERT INTO [PaymentRequest] (InvoiceID, RiderID, MethodOfPayment, Amount, Status)
VALUES
('INVO_00031', 'RIDER00002', 'OnlineWallet', 218.50, 'Completed'),
('INVO_00032', 'RIDER00003', 'OnlineWallet', 270.30, 'Completed'),
('INVO_00033', 'RIDER00004', 'OnlineWallet', 330.15, 'Completed'),
('INVO_00034', 'RIDER00005', 'OnlineWallet', 285.75, 'Completed'),
('INVO_00035', 'RIDER00006', 'Card', 315.00, 'Completed'),
('INVO_00036', 'RIDER00007', 'Card', 345.50, 'Completed'),
('INVO_00037', 'RIDER00008', 'Card', 263.85, 'Completed'),
('INVO_00038', 'RIDER00009', 'Card', 376.10, 'Completed'),
('INVO_00039', 'RIDER00010', 'Card', 315.45, 'Completed'),
('INVO_00040', 'RIDER00011', 'Card', 353.40, 'Completed');
SELECT * FROM [PaymentRequest];


INSERT INTO [Card] (PaymentID, CardNumber, CardHolder, ExpiryDate, CVV, Type)
VALUES
('PAY_R00005', '1234567812345678', 'RIDER00012', '2027-05-31', '123', 'Visa'),
('PAY_R00006', '2345678923456789', 'RIDER00013', '2025-11-04', '234', 'MasterCard'),
('PAY_R00007', '3456789034567890', 'RIDER00014', '2028-05-29', '345', 'American Express'),
('PAY_R00008', '4567890145678901', 'RIDER00015', '2029-01-09', '456', 'Visa'),
('PAY_R00009', '5678901256789012', 'RIDER00016', '2025-05-14', '567', 'MasterCard'),
('PAY_R00010', '6789012367890123', 'RIDER00017', '2028-08-06', '678', 'Visa');
SELECT * FROM [Card];

INSERT INTO [OnlineWallet] (PaymentID, WalletID, WalletProvider, AccountEmail)
VALUES
('PAY_R00001', 'WALLET001', 'PayPal', 'rider00002@example.com'),
('PAY_R00002', 'WALLET002', 'Venmo', 'rider00003@example.com'),
('PAY_R00003', 'WALLET003', 'ApplePay', 'rider00004@example.com'),
('PAY_R00004', 'WALLET004', 'GooglePay', 'rider00005@example.com');
SELECT * FROM [OnlineWallet];