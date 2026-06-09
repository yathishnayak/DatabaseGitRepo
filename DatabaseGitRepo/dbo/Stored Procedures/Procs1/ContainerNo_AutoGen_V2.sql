/*

DECLARE 
	@UserKey    INT             = 952,
	@JSONString NVARCHAR(MAX)   = '{"CustKey":3615,"OrderTypeKey":1,"UserKey":952}',
	@Status     BIT             = 0,
	@Reason     VARCHAR(100)    = ''
EXEC [ContainerNo_AutoGen_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
SELECT @Status AS Status, @Reason AS Reason

DECLARE 
	@UserKey1    INT             = 953,
	@JSONString1 NVARCHAR(MAX)   = '{"CustKey":3615,"OrderTypeKey":1,"UserKey":952}',
	@Status1     BIT             = 0,
	@Reason1     VARCHAR(100)    = ''
EXEC [ContainerNo_AutoGen_V2] @UserKey1,@JSONString1,@Status1 OUTPUT,@Reason1 OUTPUT
SELECT @Status1 AS Status1, @Reason1 AS Reason1

*/
CREATE PROCEDURE [dbo].[ContainerNo_AutoGen_V2]
(
    @UserKey      INT          = 512,
    @JSONString   NVARCHAR(MAX)= '',
    @Status       BIT          = 0  OUTPUT,
    @Reason       VARCHAR(1000)= '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    SET @Status = 0;
    SET @Reason = 'Failure';

    -- --------------------------------------------------------
    -- 1. Validate JSON input
    -- --------------------------------------------------------
    IF ISNULL(@JSONString, '') = ''
    BEGIN
        SET @Reason = 'JSON parameter is required and cannot be empty';
        RETURN;
    END

    -- --------------------------------------------------------
    -- 2. Parse JSON
    -- --------------------------------------------------------
    DECLARE
        @CustKey      INT = 0,
        @OrderTypeKey INT = 0;

    SELECT
        @CustKey      = CustKey,
        @OrderTypeKey = OrderTypeKey
    FROM OPENJSON(@JSONString, '$')
    WITH (
        CustKey      INT '$.CustKey',
        OrderTypeKey INT '$.OrderTypeKey'
    );

    IF ISNULL(@CustKey, 0) = 0 OR ISNULL(@OrderTypeKey, 0) = 0
    BEGIN
        SET @Reason = 'Error in input data: CustKey and OrderTypeKey are required';
        RETURN;
    END

    -- --------------------------------------------------------
    -- 3. Fetch lookup data (single query per table)
    --    @OrderType only needed for the custom-prefix ELSE branch
    -- --------------------------------------------------------
    DECLARE
        @CustId    VARCHAR(50),
        @CustName  VARCHAR(50),
        @OrderType CHAR(1);

    SELECT
        @CustId   = CustId,
        @CustName = CustName
    FROM dbo.Customer WITH (NOLOCK)
    WHERE CustKey = @CustKey;

    -- Only fetch OrderType when it will actually be used (OrderTypeKey > 5)
    --IF @OrderTypeKey > 5
    --    SELECT @OrderType = OrderType
    --    FROM dbo.OrderType WITH (NOLOCK)
    --    WHERE OrderTypeKey = @OrderTypeKey;

    -- --------------------------------------------------------
    -- 4. Resolve the 4-character prefix via CASE
    -- --------------------------------------------------------
    DECLARE @Prefix VARCHAR(4) =
        CASE @OrderTypeKey
            WHEN 1 THEN 'IMPT'
            WHEN 2 THEN 'UUUU'
            WHEN 3 THEN 'JFTL'
            WHEN 4 THEN 'EMPT'
            WHEN 5 THEN 'BOBT'
            ELSE        -- Custom prefix: first 3 chars of CustId + first char of OrderType
                        LEFT(ISNULL(@CustId, ''), 3) + LEFT(ISNULL(@OrderType, ''), 1)
        END;

    -- --------------------------------------------------------
    -- 5. Generate sequence number and ContainerNo inside a
    --    transaction to prevent duplicates under concurrency
    -- --------------------------------------------------------
    DECLARE
        @CurrentYear  INT  = YEAR(GETDATE()),
        @YearShort    CHAR(2) = RIGHT(YEAR(GETDATE()), 2),
        @SeqNum       INT,
        @ContainerNo  VARCHAR(50),
        @AutoGenKey   INT;

    BEGIN TRY
        BEGIN TRANSACTION;

            -- Insert placeholder; use UPDLOCK + ROWLOCK on the aggregate
            -- to serialise concurrent inserts for the same year
            INSERT INTO dbo.ContainerNum_AutoGen
                (ContainerNo, CustKey, OrderTypeKey, UserKey, GenDateTime)
            VALUES
                ('PENDING', @CustKey, @OrderTypeKey, @UserKey, GETDATE());

            SET @AutoGenKey = SCOPE_IDENTITY();

            -- Sargable year filter using a range predicate (index-friendly)
            -- UPDLOCK prevents two concurrent sessions from reading the same count
            SELECT @SeqNum = COUNT(1)
            FROM dbo.ContainerNum_AutoGen WITH (UPDLOCK, ROWLOCK)
            WHERE GenDateTime >= DATEFROMPARTS(@CurrentYear, 1, 1)
              AND GenDateTime <  DATEFROMPARTS(@CurrentYear + 1, 1, 1);

            -- Build the final container number
            SET @ContainerNo = @Prefix
                              + @YearShort
                              + RIGHT('0000' + CONVERT(VARCHAR(5), @SeqNum), 5);

            -- Single targeted update using the PK
            UPDATE dbo.ContainerNum_AutoGen
            SET    ContainerNo = @ContainerNo
            WHERE  AutoGenKey  = @AutoGenKey;

        COMMIT TRANSACTION;

        SELECT ContainerNo FROM dbo.ContainerNum_AutoGen
            WHERE  AutoGenKey  = @AutoGenKey
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        SET @Status = 1;
        SET @Reason = 'Success';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Status = 0;
        SET @Reason = 'Error [' + CONVERT(VARCHAR, ERROR_NUMBER()) + ']: '
                    + ERROR_MESSAGE();
    END CATCH

END