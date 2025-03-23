USE Team2_FinalProject_DMDD;
GO

-- Open the symmetric key for decryption
OPEN SYMMETRIC KEY DriveShareSymmetricKey 
  DECRYPTION BY CERTIFICATE DriveShareCert;
GO

-- View decrypted Admin data
SELECT 
  AdminID,
  CONVERT(VARCHAR(40), DecryptByKey([Password])) AS DecryptedPassword,
  CONVERT(VARCHAR(40), DecryptByKey([FirstName])) AS DecryptedFirstName,
  CONVERT(VARCHAR(40), DecryptByKey([LastName])) AS DecryptedLastName
FROM [Admin];
GO

-- View decrypted RegisteredUsers data
SELECT 
  UserID,
  CONVERT(VARCHAR(50), DecryptByKey([EmailID])) AS DecryptedEmail,
  CONVERT(VARCHAR(10), DecryptByKey([PhoneNumber])) AS DecryptedPhone,
  CONVERT(VARCHAR(10), DecryptByKey([FirstName])) AS DecryptedFirstName,
  CONVERT(VARCHAR(50), DecryptByKey([LastName])) AS DecryptedLastName
FROM [RegisteredUsers];
GO

-- View decrypted Driver data
SELECT 
  DriverID,
  CONVERT(VARCHAR(10), DecryptByKey([LicenseNo])) AS DecryptedLicenseNo
FROM [Driver];
GO

-- View decrypted Card data (FIXED EXPIRYDATE)
SELECT 
  PaymentID,
  CONVERT(VARCHAR(16), DecryptByKey([CardNumber])) AS DecryptedCardNumber,
  CONVERT(VARCHAR(50), DecryptByKey([CardHolder])) AS DecryptedCardHolder,
  -- Fix: Convert decrypted string to DATE using style 120 (ODBC canonical format)
  CONVERT(DATE, CONVERT(VARCHAR(10), DecryptByKey([ExpiryDate])), 120) AS DecryptedExpiryDate,
  CONVERT(VARCHAR(4), DecryptByKey([CVV])) AS DecryptedCVV
FROM [Card];
GO

-- View decrypted OnlineWallet data
SELECT 
  PaymentID,
  CONVERT(VARCHAR(20), DecryptByKey([WalletID])) AS DecryptedWalletID,
  CONVERT(VARCHAR(50), DecryptByKey([AccountEmail])) AS DecryptedAccountEmail
FROM [OnlineWallet];
GO

-- Close the symmetric key
CLOSE SYMMETRIC KEY DriveShareSymmetricKey;
GO