--Encryption Script

USE Team2_FinalProject_DMDD;
GO

-- STEP 1: Drop Constraints (If They Exist)
IF EXISTS (
  SELECT * FROM sys.objects 
  WHERE name = 'UQ_RegisteredUsers_EmailID' AND type = 'UQ'
)
BEGIN
  ALTER TABLE [RegisteredUsers] DROP CONSTRAINT [UQ_RegisteredUsers_EmailID];
END
GO

IF EXISTS (
  SELECT * FROM sys.objects 
  WHERE name = 'UQ_Driver_LicenseNo' AND type = 'UQ'
)
BEGIN
  ALTER TABLE [Driver] DROP CONSTRAINT [UQ_Driver_LicenseNo];
END
GO

-- STEP 2: Drop Existing Encryption Objects (If They Exist)
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'DriveShareSymmetricKey')
BEGIN
  DROP SYMMETRIC KEY DriveShareSymmetricKey;
END
GO

IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'DriveShareCert')
BEGIN
  DROP CERTIFICATE DriveShareCert;
END
GO

IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
  DROP MASTER KEY;
END
GO

-- STEP 3: Create Encryption Objects
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YourStrongPassword123!';
GO

CREATE CERTIFICATE DriveShareCert  
  WITH SUBJECT = 'DriveShare Sensitive Data Encryption';
GO

CREATE SYMMETRIC KEY DriveShareSymmetricKey  
  WITH ALGORITHM = AES_256  
  ENCRYPTION BY CERTIFICATE DriveShareCert;
GO

-- STEP 4: Encrypt Admin Table
ALTER TABLE [Admin]  
ADD [Password_Encrypted] VARBINARY(256),
    [FirstName_Encrypted] VARBINARY(256),
    [LastName_Encrypted] VARBINARY(256);
GO

OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert;
UPDATE [Admin]  
SET 
  [Password_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [Password]),
  [FirstName_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [FirstName]),
  [LastName_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [LastName]);
CLOSE SYMMETRIC KEY DriveShareSymmetricKey;
GO

ALTER TABLE [Admin] DROP COLUMN [Password], [FirstName], [LastName];
EXEC sp_rename 'Admin.Password_Encrypted', 'Password', 'COLUMN';
EXEC sp_rename 'Admin.FirstName_Encrypted', 'FirstName', 'COLUMN';
EXEC sp_rename 'Admin.LastName_Encrypted', 'LastName', 'COLUMN';
GO

-- STEP 5: Encrypt RegisteredUsers Table
ALTER TABLE [RegisteredUsers]  
ADD [Password_Encrypted] VARBINARY(256),
    [EmailID_Encrypted] VARBINARY(256),
    [PhoneNumber_Encrypted] VARBINARY(256),
    [FirstName_Encrypted] VARBINARY(256),
    [LastName_Encrypted] VARBINARY(256);
GO

OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert;
UPDATE [RegisteredUsers]  
SET 
  [Password_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [Password]),
  [EmailID_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [EmailID]),
  [PhoneNumber_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [PhoneNumber]),
  [FirstName_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [FirstName]),
  [LastName_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [LastName]);
CLOSE SYMMETRIC KEY DriveShareSymmetricKey;
GO

ALTER TABLE [RegisteredUsers] DROP COLUMN [Password], [EmailID], [PhoneNumber], [FirstName], [LastName];
EXEC sp_rename 'RegisteredUsers.Password_Encrypted', 'Password', 'COLUMN';
EXEC sp_rename 'RegisteredUsers.EmailID_Encrypted', 'EmailID', 'COLUMN';
EXEC sp_rename 'RegisteredUsers.PhoneNumber_Encrypted', 'PhoneNumber', 'COLUMN';
EXEC sp_rename 'RegisteredUsers.FirstName_Encrypted', 'FirstName', 'COLUMN';
EXEC sp_rename 'RegisteredUsers.LastName_Encrypted', 'LastName', 'COLUMN';
GO

-- Recreate Unique Constraints
ALTER TABLE [RegisteredUsers] ADD CONSTRAINT [UQ_RegisteredUsers_EmailID] UNIQUE ([EmailID]);
GO

-- STEP 6: Encrypt Driver Table
ALTER TABLE [Driver]  
ADD [LicenseNo_Encrypted] VARBINARY(256);
GO

OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert;
UPDATE [Driver]  
SET [LicenseNo_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [LicenseNo]);
CLOSE SYMMETRIC KEY DriveShareSymmetricKey;
GO

ALTER TABLE [Driver] DROP COLUMN [LicenseNo];
EXEC sp_rename 'Driver.LicenseNo_Encrypted', 'LicenseNo', 'COLUMN';
GO

ALTER TABLE [Driver] ADD CONSTRAINT [UQ_Driver_LicenseNo] UNIQUE ([LicenseNo]);
GO

-- STEP 7: Encrypt Card Table
ALTER TABLE [Card]  
ADD [CardNumber_Encrypted] VARBINARY(256),
    [CardHolder_Encrypted] VARBINARY(256),
    [ExpiryDate_Encrypted] VARBINARY(256),
    [CVV_Encrypted] VARBINARY(256);
GO

OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert;
UPDATE [Card]  
SET 
  [CardNumber_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [CardNumber]),
  [CardHolder_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [CardHolder]),
  [ExpiryDate_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), CONVERT(VARCHAR, [ExpiryDate])),
  [CVV_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [CVV]);
CLOSE SYMMETRIC KEY DriveShareSymmetricKey;
GO

ALTER TABLE [Card] DROP COLUMN [CardNumber], [CardHolder], [ExpiryDate], [CVV];
EXEC sp_rename 'Card.CardNumber_Encrypted', 'CardNumber', 'COLUMN';
EXEC sp_rename 'Card.CardHolder_Encrypted', 'CardHolder', 'COLUMN';
EXEC sp_rename 'Card.ExpiryDate_Encrypted', 'ExpiryDate', 'COLUMN';
EXEC sp_rename 'Card.CVV_Encrypted', 'CVV', 'COLUMN';
GO

-- STEP 8: Encrypt OnlineWallet Table
ALTER TABLE [OnlineWallet]  
ADD [WalletID_Encrypted] VARBINARY(256),
    [AccountEmail_Encrypted] VARBINARY(256);
GO

OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert;
UPDATE [OnlineWallet]  
SET 
  [WalletID_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [WalletID]),
  [AccountEmail_Encrypted] = EncryptByKey(Key_GUID('DriveShareSymmetricKey'), [AccountEmail]);
CLOSE SYMMETRIC KEY DriveShareSymmetricKey;
GO

ALTER TABLE [OnlineWallet] DROP COLUMN [WalletID], [AccountEmail];
EXEC sp_rename 'OnlineWallet.WalletID_Encrypted', 'WalletID', 'COLUMN';
EXEC sp_rename 'OnlineWallet.AccountEmail_Encrypted', 'AccountEmail', 'COLUMN';


GO


--Decryption Script

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
