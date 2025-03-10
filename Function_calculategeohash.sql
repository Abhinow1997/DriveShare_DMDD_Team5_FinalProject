DROP FUNCTION IF EXISTS dbo.CalculateGeohash
GO 

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


DROP FUNCTION IF EXISTS dbo.CalculateDistance
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

DROP FUNCTION IF EXISTS dbo.CalculateTripCost;
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



-- State Identification 
DROP FUNCTION IF EXISTS dbo.GetStateFromCoordinates;
CREATE FUNCTION dbo.GetStateFromCoordinates(
    @lat DECIMAL(10,8),
    @lon DECIMAL(11,8)
)
RETURNS VARCHAR(50)
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @state VARCHAR(50);
    
    -- Check Massachusetts first
    IF @lat BETWEEN 41.0 AND 43.0 AND @lon BETWEEN -73.5 AND -69.5
        SET @state = 'Massachusetts';
    -- Then check New York with adjusted boundaries
    ELSE IF @lat BETWEEN 40.0 AND 45.0 AND @lon BETWEEN -80.0 AND -73.5
        SET @state = 'New York';
    ELSE IF @lat BETWEEN 32.0 AND 42.0 AND @lon BETWEEN -124.0 AND -114.0
        SET @state = 'California';
    ELSE IF @lat BETWEEN 26.0 AND 31.0 AND @lon BETWEEN -98.0 AND -80.0
        SET @state = 'Florida';
    ELSE
        SET @state = 'Unknown';
        
    RETURN @state;
END;

GO
