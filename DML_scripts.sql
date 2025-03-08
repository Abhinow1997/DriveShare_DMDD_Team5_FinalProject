INSERT INTO [Admin] (FirstName, LastName, Password)
VALUES 
('Abhinav', 'Gangurde', 'admin'),
('Akshay', 'Veerabhadraiah', 'admin'),
('Neha', 'Suresh', 'admin'),
('Om', 'Raut', 'admin'),
('Poojith', 'Kotipalli', 'admin');

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



INSERT INTO [Admin] (FirstName, LastName, Password)  
VALUES  
('John', 'Doe', 'AdminPass123'),  
('Alice', 'Smith', 'SecurePass456');

INSERT INTO [RegisteredUsers] (AdminID, FirstName, LastName, Password, EmailID, PhoneNumber, Type)  
VALUES  
('ADMIN00006', 'Mike', 'Johnson', 'UserPass123', 'mike.johnson@email.com', '9876543210', 'Driver'),  
('ADMIN00007', 'Sarah', 'Parker', 'SafePass789', 'sarah.parker@email.com', '9123456789', 'Renter'),  
('ADMIN00006', 'Emily', 'Davis', 'RidePass456', 'emily.davis@email.com', '9234567890', 'Rider');

INSERT INTO [Renter] (UserID, TotalRentedCars, TotalEarnings, TotalRentalTime, CompanyName)  
VALUES  
('User00002', 5, 12000.50, 240, 'City Rentals'),  
('User00004', 3, 7500.00, 120, NULL);
