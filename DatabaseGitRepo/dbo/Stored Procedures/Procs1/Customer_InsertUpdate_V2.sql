/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{
	                            "AchRequired": false,
	                            "AddrKey": 24277,
	                            "BillToAddrKey": 24277,
	                            "CreditCheck": true,
	                            "CreateDate": "2025-04-29T12:22:13.460",
	                            "StatusName": "Active",
	                            "CustomerKey": 3001,
	                            "CustID": "FCF",
	                            "CustName": "1st Choice Freight, LLC (JCT) ",
	                            "Notes": "approved by denim and paperwork sent 12/15",
	                            "PaymentTermsKey": 1,
	                            "StatusKey": 1,
	                            "IsActive": true,
	                            "IsDelete": false,
	                            "StatusDate": "2026-02-24T04:24:29.863",
	                            "CreditLimit": 5000,
	                            "CreditStatus": 1,
	                            "PaymentTermsID": "30 Days",
	                            "IsFactored": true,
	                            "SalesPersonKey": 4,
	                            "CSRManagerKey": 74,
	                            "SalesPersonName": "Derek Kaigle ",
	                            "CSRManagerName": "Ian Weiland Weiland",
	                            "CsrKey": 0,
	                            "MarketLocationKey": 40,
	                            "CustomerCompanyKey": 1,
	                            "RateTypeKey": 1,
	                            "RateType": "Spot",
	                            "CustomerSegmentKey": 2,
	                            "CustomerSegment": "ENT",
	                            "RatePercent": 0,
	                            "IncludeFSF": true,
	                            "IsMaster": true,
	                            "Address": {
		                            "AddrKey": 24277,
		                            "AddrName": "1st Choice Freight, LLC (JCT) ",
		                            "Address1": "30700 Telegraph Rd. Suite 3670",
		                            "Address2": "-",
		                            "City": "Bingham Farms",
		                            "State": "MI",
		                            "Zip": "48025",
		                            "Country": "USA",
		                            "Phone": 123
	                            },
	                            "BillToAddress": {
		                            "AddrKey": 24277,
		                            "AddrName": "1st Choice Freight, LLC (JCT) ",
		                            "Address1": "30700 Telegraph Rd. Suite 3670",
		                            "Address2": "-",
		                            "City": "Bingham Farms",
		                            "State": "MI",
		                            "Zip": "48025",
		                            "Country": "USA",
		                            "Phone": "1"
	                            }
                            }',
    @JSONOutput NVARCHAR(MAX) = '',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
    @IsDebug BIT =1
    EXEC [Customer_InsertUpdate_V2] @UserKey,@JSONString,JSONOutput, @Status OUTPUT,@Reason OUTPUT, @IsDebug
    Select @Status AS Status, @Reason AS Reason
*/

CREATE PROC [dbo].[Customer_InsertUpdate_V2]
(
    @UserKey            INT,
    @JSONString         NVARCHAR(MAX),
    @JSONOutput         NVARCHAR(MAX) = '' OUTPUT,
    @Status             BIT = 0 OUTPUT,
    @Reason             VARCHAR(100) = '' OUTPUT,
    @IsDebug            BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    -- Input validation
    IF (ISNULL(@JSONString, '') = '')
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Customer Data not received';
        RETURN;
    END

    SET @Status = 0;
    SET @Reason = 'Failure';

    DECLARE @CustomerKey INT = 0;
    DECLARE
        @ReturnAddrKey NVARCHAR(100) = '',
        @ReturnBillToAddrKey NVARCHAR(100) = '';

    DECLARE
        @CustKey            INT             = 0,
        @CustID             VARCHAR(100)    = '',
        @CustName           VARCHAR(100)    = '',
        @AddrKey            INT             = 0,
        @CustomerGroup      SMALLINT        = 0,
        @StatusKey          SMALLINT        = 0,
        @CreditCheck        BIT             = 0,
        @CreditLimit        DECIMAL(18,2)   = 0,
        @CreditStatus       SMALLINT        = 0,
        @Ach_Required       BIT             = 0,
        @PaymentTermsKey    SMALLINT        = 0,
        @CompanyKey         SMALLINT        = 0,
        @BillToAddrKey      INT             = 0,
        @IsFactored         BIT             = 0,
        @Notes              VARCHAR(1000)   = '',
        @SalesPersonKey     INT             = 0,
        @CSRKey             INT             = 0,
        @CSRManagerKey      INT             = 0,
        @MarketLocationKey  INT             = 0, 
        @MasterCustKey      INT             = 0, 
        @RateTypeKey        INT             = 0, 
        @CustomerSegmentKey INT             = 0, 
        @IsMaster           BIT             = 0, 
        @IncludeFSF         BIT             = 0,
        @AddressData        NVARCHAR(MAX)   = '',
        @BillToAddress      NVARCHAR(MAX)   = '';
    
    -- Parse JSON
    SELECT 
        @CustKey            = CustKey, 
        @CustID             = CustID, 
        @CustName           = CustName, 
        @AddrKey            = AddrKey, 
        @CustomerGroup      = CustomerGroup, 
        @StatusKey          = StatusKey, 
        @CreditCheck        = CreditCheck, 
        @CreditLimit        = CreditLimit,  -- FIX: Was @CreditCheck = CreditLimit
        @CreditStatus       = CreditStatus, 
        @Ach_Required       = Ach_Required, 
        @PaymentTermsKey    = PaymentTermsKey, 
        @CompanyKey         = CompanyKey, 
        @BillToAddrKey      = BillToAddrKey, 
        @IsFactored         = IsFactored, 
        @Notes              = Notes,
        @SalesPersonKey     = SalesPersonKey, 
        @CSRKey             = CSRKey, 
        @CSRManagerKey      = CSRManagerKey, 
        @MarketLocationKey  = MarketLocationKey, 
        @MasterCustKey      = MasterCustKey, 
        @RateTypeKey        = RateTypeKey, 
        @CustomerSegmentKey = CustomerSegmentKey, 
        @IsMaster           = IsMaster, 
        @IncludeFSF         = IncludeFSF,
        @AddressData        = AddressData,
        @BillToAddress      = BillToAddress
    FROM OPENJSON(@JSONString, '$')
    WITH (
        CustKey             INT             '$.CustKey',
        CustID              VARCHAR(100)    '$.CustID',
        CustName            VARCHAR(100)    '$.CustName',
        AddrKey             INT             '$.AddrKey',
        CustomerGroup       SMALLINT        '$.CustomerGroup',
        StatusKey           SMALLINT        '$.StatusKey',
        CreditCheck         BIT             '$.CreditCheck',
        CreditLimit         DECIMAL(18,2)   '$.CreditLimit',
        CreditStatus        SMALLINT        '$.CreditStatus',
        Ach_Required        BIT             '$.AchRequired',
        PaymentTermsKey     SMALLINT        '$.PaymentTermsKey',
        CompanyKey          SMALLINT        '$.CustomerCompanyKey',
        BillToAddrKey       INT             '$.BillToAddrKey',
        IsFactored          BIT             '$.IsFactored',
        Notes               VARCHAR(1000)   '$.Notes',
        SalesPersonKey      INT             '$.SalesPersonKey',
        CSRKey              INT             '$.CsrKey',
        CSRManagerKey       INT             '$.CSRManagerKey',
        MarketLocationKey   INT             '$.MarketLocationKey',
        MasterCustKey       INT             '$.MasterCustKey',
        RateTypeKey         INT             '$.RateTypeKey',
        CustomerSegmentKey  INT             '$.CustomerSegmentKey',
        IsMaster            BIT             '$.IsMaster',
        IncludeFSF          BIT             '$.IncludeFSF',
        AddressData         NVARCHAR(MAX)   '$.Address' AS JSON,
        BillToAddress       NVARCHAR(MAX)   '$.BillToAddress' AS JSON
    );

    SET @CustomerKey = @CustKey;

    IF (@IsDebug = 1)
    BEGIN
        PRINT 'CustomerKey: ' + CAST(@CustomerKey AS VARCHAR(10));
        PRINT 'CustID: ' + @CustID;
    END

    -- Validate UserKey first
    IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE UserKey = @UserKey)
    BEGIN
        SET @Reason = 'Invalid UserKey - User does not exist';
        SET @Status = 0;
        RETURN;
    END

    -- Validate required fields
    IF (ISNULL(@CustID, '') = '')
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Customer ID is required';
        RETURN;
    END

    IF (ISNULL(@CustName, '') = '')
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Customer Name is required';
        RETURN;
    END

    -- Check duplicate CustID (exclude current record on UPDATE)
    IF (ISNULL(@CustomerKey, 0) = 0)
    BEGIN
        -- INSERT mode: check if CustID exists
        IF EXISTS (SELECT 1 FROM dbo.Customer WHERE CustID = @CustID)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Customer ID already exists';
            RETURN;
        END
    END
    ELSE
    BEGIN
        -- UPDATE mode: check if customer exists
        IF NOT EXISTS (SELECT 1 FROM dbo.Customer WHERE CustKey = @CustomerKey)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Customer does not exist';
            RETURN;
        END

        -- Check duplicate CustID excluding current record
        IF EXISTS (SELECT 1 FROM dbo.Customer WHERE CustID = @CustID AND CustKey <> @CustomerKey AND StatusKey = 1 AND IsActive = 1 AND IsDelete = 0)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'In update => Customer ID already exists';
            RETURN;
        END
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Process Address (inside transaction)
        IF (ISNULL(@AddressData, '') <> '')
        BEGIN
            EXEC dbo.Address_InsertUpdate @UserKey, @AddressData, @ReturnAddrKey OUTPUT, 0, '';
            
            IF (@IsDebug = 1)
                SELECT '@AddressData', @AddressData;

            IF (@IsDebug = 1) PRINT '@ReturnAddrKey: ' + ISNULL(@ReturnAddrKey, 'NULL');

            SELECT @AddrKey = AddressKey
            FROM OPENJSON(@ReturnAddrKey, '$')
            WITH (AddressKey INT '$.AddrKey');

            IF (ISNULL(@AddrKey, 0) = 0)
            BEGIN
                SET @Status = 0;
                SET @Reason = 'Failed to create or retrieve customer Address';
                ROLLBACK;
                RETURN;
            END
        END

        -- Process BillTo Address (inside transaction)
        IF (ISNULL(@BillToAddress, '') <> '')
        BEGIN
            EXEC dbo.Address_InsertUpdate @UserKey, @BillToAddress, @ReturnBillToAddrKey OUTPUT, 0, '';
            
            IF (@IsDebug = 1)
                SELECT '@BillToAddress', @BillToAddress;

            IF (@IsDebug = 1) PRINT '@ReturnBillToAddrKey: ' + ISNULL(@ReturnBillToAddrKey, 'NULL');

            SELECT @BillToAddrKey = BillAddressKey
            FROM OPENJSON(@ReturnBillToAddrKey, '$')
            WITH (BillAddressKey INT '$.AddrKey');

            IF (ISNULL(@BillToAddrKey, 0) = 0)
            BEGIN
                SET @Status = 0;
                SET @Reason = 'Failed to create or retrieve BillTo Address';
                ROLLBACK;
                RETURN;
            END
        END

        IF (ISNULL(@CustomerKey, 0) = 0)
        BEGIN
            -- INSERT
            INSERT INTO dbo.Customer
                (CustID, CustName, AddrKey, CustomerGroup, StatusKey, StatusDate, CreditCheck, CreditLimit,
                CreditStatus, Ach_Required, PaymentTermsKey, CompanyKey, CustomerCompanyKey, BillToAddrKey, 
                IsFactored, Notes, CSRKey, CSRManagerKey, SalesPersonKey, MarketLocationKey, MasterCustKey, 
                RateTypeKey, CustomerSegmentKey, IsMaster, IncludeFSF, CreateDate)
            VALUES
                (@CustID, @CustName, @AddrKey, @CustomerGroup, @StatusKey, GETDATE(), @CreditCheck, @CreditLimit,
                @CreditStatus, @Ach_Required, @PaymentTermsKey, 1, @CompanyKey, @BillToAddrKey, 
                @IsFactored, @Notes, @CSRKey, @CSRManagerKey, @SalesPersonKey, @MarketLocationKey, @MasterCustKey, 
                @RateTypeKey, @CustomerSegmentKey, @IsMaster, @IncludeFSF, GETDATE());

            SET @CustomerKey = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- UPDATE
            UPDATE dbo.Customer 
            SET
                CustID              = @CustID,
                CustName            = @CustName,
                AddrKey             = @AddrKey,
                CustomerGroup       = @CustomerGroup,
                StatusKey           = @StatusKey,
                StatusDate          = GETDATE(),
                CreditCheck         = @CreditCheck,
                CreditLimit         = @CreditLimit,
                CreditStatus        = @CreditStatus,
                Ach_Required        = @Ach_Required,
                PaymentTermsKey     = @PaymentTermsKey,
                CustomerCompanyKey  = @CompanyKey,
                BillToAddrKey       = @BillToAddrKey,
                IsFactored          = @IsFactored,
                Notes               = @Notes,
                CSRKey              = @CSRKey,
                CSRManagerKey       = @CSRManagerKey,
                SalesPersonKey      = @SalesPersonKey,
                MarketLocationKey   = @MarketLocationKey,
                MasterCustKey       = @MasterCustKey,
                RateTypeKey         = @RateTypeKey,
                CustomerSegmentKey  = @CustomerSegmentKey,
                IsMaster            = @IsMaster,
                IncludeFSF          = @IncludeFSF
            WHERE CustKey = @CustomerKey;

            IF @@ROWCOUNT = 0
            BEGIN
                SET @Status = 0;
                SET @Reason = 'No records were updated';
                ROLLBACK;
                RETURN;
            END
        END

        COMMIT;

        --SET @JSONOutput = (SELECT @CustomerKey AS CustomerKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        --SELECT @JSONOutput;
        SELECT (
				SELECT @CustomerKey AS CustKey
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			) AS JSONOutput
        SET @Status = 1;
        SET @Reason = 'Customer Saved Successfully';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        IF (@IsDebug = 1) PRINT ERROR_MESSAGE();

        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();
    END CATCH
END