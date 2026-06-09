CREATE PROCEDURE [dbo].[DriverCarrier_InsertUpdate_V3]
(
    @UserKey        INT = 488,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT OUTPUT,
    @Reason         VARCHAR(1000) OUTPUT,
    @IsDebug        BIT = 0 
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        --------------------------------------------------
        -- ✅ VALIDATION
        --------------------------------------------------
        IF (@UserKey = 0 OR ISNULL(@JSONString,'') = '')
        BEGIN
            SET @Status = 0
            SET @Reason = 'Invalid input'
            RETURN
        END

        --------------------------------------------------
        -- ✅ DECLARE VARIABLES (NO TEMP TABLE)
        --------------------------------------------------
        DECLARE 
            @DriverKey INT,
            @DriverID VARCHAR(20),
            @FirstName VARCHAR(100),
            @LastName VARCHAR(100),
            @AddrKey INT,
            @CarrierKey INT,
            @StatusKey INT,
            @OrgName VARCHAR(100),
            @EmailAddress VARCHAR(200),
            @PayTypeKey INT,
            @NoOfTrucks INT,
            @MarketLocationKey INT,
            @TruckTypeKey INT;

        --------------------------------------------------
        -- ✅ PARSE DRIVER JSON
        --------------------------------------------------
        SELECT
            @DriverKey = DriverKey,
            @DriverID = DriverId,
            @FirstName = FirstName,
            @LastName = LastName,
            @AddrKey = AddrKey,
            @CarrierKey = CarrierKey,
            @StatusKey = StatusKey,
            @OrgName = OrgName,
            @EmailAddress = EmailAddress,
            @PayTypeKey = PayTypeKey,
            @NoOfTrucks = NoOfTrucks,
            @MarketLocationKey = MarketLocationKey,
            @TruckTypeKey = TruckTypeKey
        FROM OPENJSON(@JSONString)
        WITH (
            DriverKey INT,
            DriverId VARCHAR(20),
            FirstName VARCHAR(100),
            LastName VARCHAR(100),
            AddrKey INT,
            CarrierKey INT,
            StatusKey INT,
            OrgName VARCHAR(100),
            EmailAddress VARCHAR(200),
            PayTypeKey INT,
            NoOfTrucks INT,
            MarketLocationKey INT,
            TruckTypeKey INT
        );

        IF (@DriverID IS NULL)
        BEGIN
            SET @Status = 0
            SET @Reason = 'Invalid Driver Data'
            RETURN
        END

        --------------------------------------------------
        -- ✅ PARSE ADDRESS
        --------------------------------------------------
        DECLARE @AddressJSON NVARCHAR(MAX)

        SELECT @AddressJSON = BillingAddress
        FROM OPENJSON(@JSONString)
        WITH (BillingAddress NVARCHAR(MAX) AS JSON)

        DECLARE 
            @NewAddrKey INT,
            @Address1 VARCHAR(255),
            @City VARCHAR(255),
            @State VARCHAR(255),
            @ZipCode VARCHAR(50),
            @Country CHAR(3);

        SELECT
            @NewAddrKey = AddrKey,
            @Address1 = Address1,
            @City = City,
            @State = State,
            @ZipCode = ZipCode,
            @Country = Country
        FROM OPENJSON(@AddressJSON)
        WITH (
            AddrKey INT,
            Address1 VARCHAR(255),
            City VARCHAR(255),
            State VARCHAR(255),
            ZipCode VARCHAR(50),
            Country CHAR(3)
        );

        --------------------------------------------------
        -- ✅ TRANSACTION
        --------------------------------------------------
        BEGIN TRAN

        --------------------------------------------------
        -- ✅ UPSERT ADDRESS (SAFE)
        --------------------------------------------------
        IF (@NewAddrKey IS NULL OR @NewAddrKey = 0)
        BEGIN
            INSERT INTO Address (Address1, City, State, ZipCode, Country)
            VALUES (@Address1, @City, @State, @ZipCode, @Country)

            SET @NewAddrKey = SCOPE_IDENTITY()
        END
        ELSE
        BEGIN
            UPDATE Address
            SET 
                Address1 = @Address1,
                City = @City,
                State = @State,
                ZipCode = @ZipCode
            WHERE AddrKey = @NewAddrKey
        END

        --------------------------------------------------
        -- ✅ UPSERT DRIVER
        --------------------------------------------------
        IF (@DriverKey IS NULL OR @DriverKey = 0)
        BEGIN
            INSERT INTO Driver (
                DriverID, FirstName, LastName,
                AddrKey, CarrierKey, StatusKey,
                OrgName, EmailAddress, PayTypeKey,
                NoOfTrucks, MarketLocationKey, TruckTypeKey
            )
            VALUES (
                @DriverID, @FirstName, @LastName,
                @NewAddrKey, @CarrierKey, @StatusKey,
                @OrgName, @EmailAddress, @PayTypeKey,
                @NoOfTrucks, @MarketLocationKey, @TruckTypeKey
            )

            SET @DriverKey = SCOPE_IDENTITY()
            SET @Reason = 'Driver created successfully'
        END
        ELSE
        BEGIN
            UPDATE Driver
            SET 
                FirstName = @FirstName,
                LastName = @LastName,
                AddrKey = @NewAddrKey,
                OrgName = @OrgName,
                EmailAddress = @EmailAddress,
                PayTypeKey = @PayTypeKey
            WHERE DriverKey = @DriverKey

            SET @Reason = 'Driver updated successfully'
        END

        --------------------------------------------------
        COMMIT TRAN

        SET @Status = 1

    END TRY
    BEGIN CATCH
        ROLLBACK TRAN

        SET @Status = 0
        SET @Reason = ERROR_MESSAGE()
    END CATCH
END
