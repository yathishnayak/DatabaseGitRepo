/*
    DECLARE @UserKey    INT             = 488,
    @JsonString         VARCHAR(MAX)    = '{"CompanyKey":1,"Address":{"AddrName":"dsge","Address1":"gbhst","Zip":"57401","City":"Aberdeen","CityKey":26845,"State":"SD","Country":"USA","Phone":"54121"},"AddrKey":0,"StatusKey":1,"WarehouseID":"amrutha","WarehouseKey":0}',
    @IsDebug            BIT             = 1,
    @Status             BIT             = 0,
    @Reason             NVARCHAR(1000)  = ''
    
    EXEC InsertUpdate_Warehouse_V2 @UserKey, @JsonString, @IsDebug, @Status OUTPUT, @Reason OUTPUT
    SELECT @Status, @Reason
*/
CREATE PROCEDURE [dbo].[InsertUpdate_Warehouse_V2]
(
    @UserKey    INT = 488,
    @JsonString NVARCHAR(MAX) = N'',
    @IsDebug    BIT = 1,
    @Status     BIT = 0 OUTPUT,
    @Reason     NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;
    SET ARITHABORT ON;

    -- Validate input JSON
    IF (ISNULL(@JsonString, '') = '')
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Parameter not found';
        RETURN;
    END;

    DECLARE
        @ReturnAddrKey  NVARCHAR(100)   = '',
        @AddressKey     INT             = 0;

    DECLARE
        @WarehouseKey   INT,
        @WarehouseID    VARCHAR(100),
        @AddrKey        INT,
        @StatusKey      SMALLINT,
        @CompanyKey     SMALLINT,
        @AddressData    NVARCHAR(MAX);

    -- Parse JSON
    SELECT
        @WarehouseKey   = WarehouseKey,
        @WarehouseID    = WarehouseID,
        @AddrKey        = AddrKey,
        @StatusKey      = StatusKey,
        @CompanyKey     = CompanyKey,
        @AddressData    = AddressData
    FROM OPENJSON(@JsonString, '$')
    WITH
    (
        WarehouseKey    INT             '$.WarehouseKey',
        WarehouseID     VARCHAR(100)    '$.WarehouseID',
        AddrKey         INT             '$.AddrKey',
        StatusKey       SMALLINT        '$.StatusKey',
        CompanyKey      SMALLINT        '$.CompanyKey',
        AddressData     NVARCHAR(MAX)   '$.Address' AS JSON
    );

    -- Normalize AddrKey
    IF @AddrKey = 0
    BEGIN
        SET @AddrKey = NULL;
    END;

    BEGIN TRY
        -- Create or retrieve address
        EXEC dbo.Address_InsertUpdate @UserKey, @AddressData, @ReturnAddrKey OUTPUT, 0, '';

        SELECT @AddressKey = AddressKey
        FROM OPENJSON(@ReturnAddrKey, '$')
        WITH
        (
            AddressKey INT '$.AddrKey'
        );

        -- Validate returned AddressKey
        IF (ISNULL(@AddressKey, 0) = 0)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Failed to create or retrieve Address';
            RETURN;
        END;

        -- Validate WarehouseID uniqueness
        IF EXISTS
        (
            SELECT 1 FROM dbo.Warehouse
            WHERE WarehouseID   = @WarehouseID
              AND CompanyKey    = @CompanyKey
              AND WarehouseKey  <> ISNULL(@WarehouseKey, 0)
        )
        BEGIN
            SET @Status = 0;
            SET @Reason = 'WarehouseID already exists.';
            RETURN;
        END;

        BEGIN TRAN;

            IF (ISNULL(@WarehouseKey, 0) = 0)
            BEGIN
                -- INSERT new Warehouse
                INSERT INTO dbo.Warehouse
                    (WarehouseID, AddrKey, StatusKey, CompanyKey)
                VALUES
                    (@WarehouseID, @AddressKey, @StatusKey, @CompanyKey);

                SET @WarehouseKey   = SCOPE_IDENTITY();
                SET @Status         = 1;
                SET @Reason         = 'Inserted Successfully';
            END
            ELSE
            BEGIN
                -- UPDATE existing Warehouse
                UPDATE dbo.Warehouse
                SET
                    WarehouseID = @WarehouseID,
                    AddrKey     = @AddressKey,
                    StatusKey   = @StatusKey,
                    CompanyKey  = @CompanyKey
                WHERE WarehouseKey = @WarehouseKey;

                SET @Status = 1;
                SET @Reason = 'Updated Successfully';
            END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();

        IF @IsDebug = 1
        BEGIN
            SELECT
                ERROR_NUMBER()      AS ErrorNumber,
                ERROR_SEVERITY()    AS ErrorSeverity,
                ERROR_STATE()       AS ErrorState,
                ERROR_PROCEDURE()   AS ErrorProcedure,
                ERROR_LINE()        AS ErrorLine,
                ERROR_MESSAGE()     AS ErrorMessage;
        END;
    END CATCH;
END;