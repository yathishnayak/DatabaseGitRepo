/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CityKey":44700}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [DeleteCity_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[DeleteCity_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"CityKey": 0}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @CityKey INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parse JSON input
        SELECT @CityKey = ISNULL(CityKey, 0)
        FROM OPENJSON(@JSONString)
        WITH (
            CityKey INT '$.CityKey'
        );
        
        -- Validate CityKey
        IF (@CityKey = 0 OR @CityKey IS NULL)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'CityKey cannot be null or zero';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if record exists
        DECLARE @CNT INT = 0;
        SET @CNT = (SELECT COUNT(1) FROM LocationData WHERE CityKey = @CityKey);
        
        IF (@CNT = 0)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'No record found for the given City data';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Soft delete the record
        UPDATE LocationData
        SET IsActive = 0, 
            IsDelete = 1
        WHERE CityKey = @CityKey;
        
        SET @Status = 1;
        SET @Reason = 'City deleted successfully';
        
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