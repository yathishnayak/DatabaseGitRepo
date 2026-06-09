/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"Country": "TestCountry", "State": "TestState", "City": "", "ZipCode": 1140, "StatusKey": 1}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [InsertUpdateLocation] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[InsertUpdateLocation]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @CityKey INT = 0,
            @City       NVARCHAR(100) = '',
            @Country    NVARCHAR(100) = '',
            @State      NVARCHAR(100) = '',
            @ZipCode    NVARCHAR(100) = '',
            @StatusKey  INT = 0,
            @CreateDate DATETIME = NULL;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parse JSON input
        SELECT  @CityKey    = ISNULL(CityKey, 0),
                @City       = ISNULL(City, ''),
                @Country    = ISNULL(Country, ''),
                @State      = ISNULL([State], ''),
                @ZipCode    = ISNULL(ZipCode, ''),
                @StatusKey  = ISNULL(StatusKey, 0),
                @CreateDate = ISNULL(CreateDate, GETDATE())
        FROM OPENJSON(@JSONString)
        WITH (
            CityKey     INT             '$.CityKey',
            City        NVARCHAR(100)   '$.City',
            Country     NVARCHAR(100)   '$.Country',
            State       NVARCHAR(100)   '$.State',
            ZipCode     NVARCHAR(100)   '$.ZipCode',
            StatusKey   INT             '$.StatusKey',
            CreateDate  DATETIME        '$.CreateDate'
        );

         -- Validate required fields
        IF (LTRIM(RTRIM(@Country)) = '' OR @Country IS NULL)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Country cannot be null or empty';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF (LTRIM(RTRIM(@State)) = '' OR @State IS NULL)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'State cannot be null or empty';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF (LTRIM(RTRIM(@City)) = '' OR @City IS NULL)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'City cannot be null or empty';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF (LTRIM(RTRIM(@ZipCode)) = '' OR @ZipCode IS NULL)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'ZipCode cannot be null or empty';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Insert new location
        IF(@CityKey = 0)
        BEGIN
            DECLARE @Count INT = 0;
            SET @Count = (SELECT COUNT(1) FROM LocationData
                            WHERE City = @City AND 
                                  Country = @Country AND
                                  [State] = @State AND
                                  ZipCode = @ZipCode);
            
            IF(@Count = 0)
            BEGIN
                INSERT INTO LocationData (Country, [State], City, ZipCode, StatusKey, CreateDate, IsActive, IsDelete)
                VALUES(@Country, @State, @City, @ZipCode, @StatusKey, Getdate(), 1, 0);
                
                SET @CityKey = SCOPE_IDENTITY();
                SET @Status = 1;
                SET @Reason = 'Location inserted successfully';
            END
            ELSE
            BEGIN
                SET @Status = 0;
                SET @Reason = 'Location already exists';
            END
        END
        -- Update existing location
        ELSE IF(@CityKey > 0)
        BEGIN
            IF EXISTS(SELECT 1 FROM LocationData WHERE CityKey = @CityKey)
            BEGIN
                UPDATE LocationData
                    SET Country = @Country,
                        [State] = @State,
                        City    = @City,
                        ZipCode = @ZipCode,
                        StatusKey = @StatusKey
                WHERE CityKey = @CityKey;
                
                SET @Status = 1;
                SET @Reason = 'Location updated successfully';
            END
            ELSE
            BEGIN
                SET @Status = 0;
                SET @Reason = 'Location not found for update';
            END
        END
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @Status = 0;
        SET @Reason = 'Error: ' + ERROR_MESSAGE() + ' (Line: ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ')';
        
        IF @IsDebug = 1
        BEGIN
            -- Log error details for debugging
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
            DECLARE @ErrorState INT = ERROR_STATE();
            DECLARE @ErrorLine INT = ERROR_LINE();
            
            PRINT 'Error Message: ' + @ErrorMessage;
            PRINT 'Error Line: ' + CAST(@ErrorLine AS VARCHAR(10));
            PRINT 'Error Severity: ' + CAST(@ErrorSeverity AS VARCHAR(10));
            PRINT 'Error State: ' + CAST(@ErrorState AS VARCHAR(10));
        END
        
    END CATCH
    
END